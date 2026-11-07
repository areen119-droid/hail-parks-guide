import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/data/initiative_data.dart';
import 'package:hail_parks_guide/journal/journal_initiative.dart';
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_plants.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// Home of the journal design: masthead, place of the day, the planner, an
/// index of places, our Ghars Nation initiative, where to eat, plant of the day.
class JournalHome extends StatefulWidget {
  const JournalHome({super.key});

  @override
  State<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  PlaceCategory? _category = PlaceCategory.park;
  String _query = '';

  final _featured = PageController();
  int _featuredPage = 0;

  @override
  void dispose() {
    _featured.dispose();
    super.dispose();
  }

  int get _dayOfYear {
    final now = DateTime.now();
    return now.difference(DateTime(now.year)).inDays;
  }

  /// Today's three places: one with a photo from each main category (a park,
  /// a nature spot, a heritage site), changing every day.
  List<PlaceModel> get _placesOfTheDay => [
        for (final category in PlaceCategory.main)
          if (HailData.places
              .where((p) => p.category == category && p.image.isNotEmpty)
              .toList()
              case final options when options.isNotEmpty)
            options[_dayOfYear % options.length],
      ];

  void _showFeatured(int page, int count) => _featured.animateToPage(
        page % count,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

  void _open(PlaceModel place) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => JournalPlace(place: place)));

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();
    final places = HailData.places.where((p) =>
        !p.category.isFood &&
        (_category == null || p.category == _category) &&
        p.name.contains(query)).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _masthead(),
          _featuredPlaces(_placesOfTheDay),
          _plannerBlock(),
          const JSection(number: 1, title: 'أخبار'),
          _newsTeaser(),
          JSection(
            number: 2,
            title: 'فهرس الأماكن',
            action: 'على الخريطة',
            onAction: () => context.read<NavigationProvider>().selectTab(NavigationProvider.mapTab),
          ),
          const SizedBox(height: 4),
          JTabs<PlaceCategory?>(
            tabs: [for (final c in PlaceCategory.main) (c, c.label), (null, 'الكل')],
            selected: _category,
            onSelected: (c) => setState(() => _category = c),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(J.gutter, 4, J.gutter, 4),
            child: JSearchField(
              hint: 'ابحث عن مكان',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (places.isEmpty)
            const Padding(
              padding: EdgeInsets.all(J.gutter),
              child: Text('لا يوجد مكان بهذا الاسم في الفهرس', style: J.meta),
            ),
          for (var i = 0; i < places.length; i++)
            _IndexRow(number: i + 1, place: places[i], onTap: () => _open(places[i])),
          const JSection(number: 3, title: 'أين تأكل؟'),
          _foodColumns(),
          const JSection(number: 4, title: 'نبتة اليوم'),
          _plantOfTheDay(),
          _fact(),
        ],
      ),
    );
  }

  Widget _masthead() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(J.gutter, 14, J.gutter, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('دليل حدائق حائل', style: J.label.copyWith(color: J.inkSoft)),
              const Spacer(),
              Text(journalDate(DateTime.now()), style: J.label.copyWith(color: J.inkSoft)),
            ],
          ),
          const SizedBox(height: 6),
          const JRule(color: J.ink),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('حائل', style: J.display.copyWith(fontSize: 64, height: 1.1))),
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Ibex(size: 56),
              ),
            ],
          ),
          Text('حدائقها وجبالها وآثارها، ومن أين تبدأ.', style: J.text.copyWith(color: J.inkSoft)),
        ],
      ),
    );
  }

  /// Today's places as a slideshow: swipe, or use the arrows on either side.
  Widget _featuredPlaces(List<PlaceModel> places) {
    if (places.isEmpty) return const SizedBox.shrink();
    final page = _featuredPage.clamp(0, places.length - 1);
    final place = places[page];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _featured,
                itemCount: places.length,
                onPageChanged: (i) => setState(() => _featuredPage = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _open(places[i]),
                  child: JPhoto(place: places[i]),
                ),
              ),
              if (places.length > 1) ...[
                // Pages run right to left, so the next place is on the left.
                PositionedDirectional(
                  start: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: JSquareButton(
                      icon: Icons.arrow_back,
                      tooltip: 'السابق',
                      onPressed: () => _showFeatured(page - 1 + places.length, places.length),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: JSquareButton(
                      icon: Icons.arrow_forward,
                      tooltip: 'التالي',
                      onPressed: () => _showFeatured(page + 1, places.length),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  bottom: 12,
                  child: Container(
                    color: J.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      J.digits('${page + 1} / ${places.length}'),
                      style: const TextStyle(color: J.onInk, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        _featuredText(place),
      ],
    );
  }

  Widget _featuredText(PlaceModel place) {
    return InkWell(
      onTap: () => _open(place),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(J.gutter, 14, J.gutter, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('أماكن اليوم', style: J.label),
                  const Text('  ·  ', style: J.meta),
                  JCategoryMark(place.category),
                  const SizedBox(width: 6),
                  Text(place.category.label, style: J.meta),
                ]),
                const SizedBox(height: 2),
                Text(place.name, style: J.title),
                const SizedBox(height: 4),
                Text(
                  place.description.split(RegExp(r'[.]')).first,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: J.text,
                ),
                JLink(label: 'اقرأ عنه', onTap: () => _open(place)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plannerBlock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(J.gutter, 24, J.gutter, 0),
      padding: const EdgeInsets.all(22),
      color: J.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('خطط أيامك في حائل', style: J.title.copyWith(color: J.onInk)),
          const SizedBox(height: 6),
          const Text(
            'أربعة أسئلة، ثم جدول لكل يوم: نشاط، وغداء، وقهوة، وعشاء.',
            style: TextStyle(color: J.onInkSoft, fontSize: 14.5, height: 1.6),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: J.ochre, foregroundColor: J.onInk),
              onPressed: () => context.read<NavigationProvider>().openGuide(planner: true),
              child: const Text('ابدأ التخطيط'),
            ),
          ),
        ],
      ),
    );
  }

  /// The Ghars Nation story as a news teaser: kicker, headline, standfirst,
  /// byline and a thumbnail, like the front page of a paper.
  Widget _newsTeaser() {
    final photo = InitiativeData.photos.isNotEmpty ? InitiativeData.photos.first.$1 : null;
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const JournalInitiative())),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(J.gutter, 16, J.gutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(InitiativeData.kicker, style: J.label),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(InitiativeData.headline,
                      style: J.heading.copyWith(fontSize: 22, height: 1.4)),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 96,
                  height: 96,
                  color: Colors.white,
                  padding: photo == null ? const EdgeInsets.all(8) : null,
                  child: photo == null
                      ? Image.asset(InitiativeData.logo)
                      : Image.asset(photo, fit: BoxFit.cover),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(InitiativeData.standfirst, style: J.meta),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: Text(
                  J.digits([InitiativeData.byline, ?InitiativeData.date].join(' · ')),
                  style: J.meta.copyWith(fontSize: 12.5),
                ),
              ),
              const JLink(label: 'اقرأ الخبر'),
            ]),
            const JRule(),
          ],
        ),
      ),
    );
  }

  Widget _foodColumns() {
    Widget column(String title, PlaceCategory category) {
      final items = HailData.places.where((p) => p.category == category).toList();
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              JCategoryMark(category),
              const SizedBox(width: 6),
              Text(title, style: J.label.copyWith(color: J.ink)),
            ]),
            const SizedBox(height: 6),
            for (final p in items)
              InkWell(
                onTap: () => _open(p),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: J.rule)),
                  ),
                  child: Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(J.gutter, 16, J.gutter, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          column('مطاعم', PlaceCategory.restaurant),
          const SizedBox(width: 20),
          column('مقاهي', PlaceCategory.cafe),
        ],
      ),
    );
  }

  Widget _plantOfTheDay() {
    final plant = HailData.plants[_dayOfYear % HailData.plants.length];
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => JournalPlantDetail(plant: plant))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(J.gutter, 16, J.gutter, 0),
        child: Row(
          children: [
            SmartImage(imageData: plant.image, width: 104, height: 104),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name, style: J.title),
                  Text(plant.scientificName,
                      textDirection: TextDirection.ltr,
                      style: J.meta.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(plant.type, style: J.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fact() {
    final fact = HailData.facts[_dayOfYear % HailData.facts.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(J.gutter, 40, J.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const JRule(color: J.ink),
          const SizedBox(height: 14),
          const Text('هل تعلم', style: J.label),
          const SizedBox(height: 4),
          Text(fact, style: J.heading.copyWith(fontWeight: FontWeight.w500, height: 1.6)),
          const SizedBox(height: 14),
          const JRule(color: J.ink),
        ],
      ),
    );
  }
}

/// One line of the places index: number, name, kind and distance, thumbnail.
class _IndexRow extends StatelessWidget {
  final int number;
  final PlaceModel place;
  final VoidCallback onTap;

  const _IndexRow({required this.number, required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final distance = distanceFromHailLabel(place);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: J.gutter),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(
          children: [
            SizedBox(width: 34, child: Text(J.index(number), style: J.number)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: J.entry),
                  const SizedBox(height: 2),
                  Row(children: [
                    JCategoryMark(place.category),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        J.digits([place.category.label, ?distance].join(' · ')),
                        style: J.meta,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 12),
            JPhoto(place: place, width: 64, height: 64),
          ],
        ),
      ),
    );
  }
}
