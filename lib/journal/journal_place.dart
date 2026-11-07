import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/core/widgets/favorite_feedback.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// A place's page in the journal design: photo plate, fact sheet, text,
/// actions, and the nearest restaurants and cafés.
class JournalPlace extends StatefulWidget {
  final PlaceModel place;
  const JournalPlace({super.key, required this.place});

  @override
  State<JournalPlace> createState() => _JournalPlaceState();
}

class _JournalPlaceState extends State<JournalPlace> {
  int _photo = 0;

  PlaceModel get place => widget.place;

  List<String> get _photos =>
      place.gallery.isNotEmpty ? place.gallery : [if (place.image.isNotEmpty) place.image];

  void _backToTabs(void Function(NavigationProvider) action) {
    final nav = context.read<NavigationProvider>();
    Navigator.popUntil(context, (route) => route.isFirst);
    action(nav);
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<FavoritesProvider>().isFavoritePlace(place.id);
    final distance = distanceFromHailLabel(place);
    final food = place.category.isFood ? const <(PlaceModel, double)>[] : nearbyFood(place);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 10, J.gutter, 14),
              child: Row(
                children: [
                  JSquareButton(
                    icon: Icons.arrow_back, // mirrored in right-to-left
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  JCategoryMark(place.category),
                  const SizedBox(width: 6),
                  Text(place.category.label, style: J.label.copyWith(color: J.ink)),
                ],
              ),
            ),
            _plate(),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 18, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: J.title.copyWith(fontSize: 32)),
                  const SizedBox(height: 2),
                  Text(place.location, style: J.meta),
                  const SizedBox(height: 18),
                  const JRule(color: J.ink),
                  _fact('النوع', place.category.label),
                  if (distance != null) _fact('من وسط حائل', distance),
                  if (place.openingHours.isNotEmpty) _fact('أوقات العمل', place.openingHours),
                  if (place.facilities.isNotEmpty) _fact('المرافق', place.facilities.join('، ')),
                  const SizedBox(height: 20),
                  Text(place.description, style: J.text.copyWith(fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (place.hasLocation) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _backToTabs((nav) => nav.showPlaceOnMap(place.id)),
                            child: const Text('على الخريطة'),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => toggleFavoritePlace(context, place),
                          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 20),
                          label: Text(saved ? 'في دفتري' : 'احفظ'),
                        ),
                      ),
                    ],
                  ),
                  JLink(
                    label: 'اسأل المرشد عن هذا المكان',
                    color: J.ochre,
                    onTap: () => _backToTabs((nav) => nav.openGuide(
                        question: 'أخبرني عن ${place.name}: ما الذي يميزه، وما أفضل وقت لزيارته، وبماذا تنصحني؟')),
                  ),
                ],
              ),
            ),
            if (food.isNotEmpty) ...[
              const JSection(number: 1, title: 'قريب منه للأكل'),
              for (var i = 0; i < food.length; i++)
                InkWell(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => JournalPlace(place: food[i].$1))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: J.gutter),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
                    child: Row(
                      children: [
                        SizedBox(width: 34, child: Text(J.index(i + 1), style: J.number)),
                        JCategoryMark(food[i].$1.category),
                        const SizedBox(width: 8),
                        Expanded(child: Text(food[i].$1.name, style: J.entry.copyWith(fontSize: 16))),
                        Text(J.digits(formatKm(food[i].$2)), style: J.meta),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _plate() {
    final photos = _photos;
    if (photos.length <= 1) {
      return AspectRatio(aspectRatio: 4 / 3, child: JPhoto(place: place));
    }
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _photo = i),
            itemBuilder: (_, i) => JPhoto(place: place, image: photos[i]),
          ),
          PositionedDirectional(
            start: 12,
            bottom: 12,
            child: Container(
              color: J.ink,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                J.digits('${_photo + 1} / ${photos.length}'),
                style: const TextStyle(color: J.onInk, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fact(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: J.meta)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
