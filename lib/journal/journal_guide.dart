import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/guide/widgets/planner_sheet.dart' show PlannerRequest;
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_planner.dart';
import 'package:hail_parks_guide/journal/journal_plants.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/guide_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// The guide in the journal design: the conversation reads like a transcript,
/// and trip plans like a timetable.
class JournalGuide extends StatefulWidget {
  const JournalGuide({super.key});

  @override
  State<JournalGuide> createState() => _JournalGuideState();
}

class _JournalGuideState extends State<JournalGuide> {
  static const _questions = [
    'وين أروح مع عيالي؟',
    'وين أشوف الغروب؟',
    'أبي مطعم حلو',
    'وش مواقع اليونسكو في حائل؟',
    'وش أفضل وقت لزيارة حائل؟',
  ];

  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _shown = 0;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    final nav = context.read<NavigationProvider>();
    final action = await context.read<GuideProvider>().ask(question);
    if (!mounted) return;
    switch (action) {
      case GuideAction.openPlanner:
        _openPlanner();
      case GuideAction.openMap:
        nav.selectTab(NavigationProvider.mapTab);
      case GuideAction.none:
        break;
    }
  }

  Future<void> _openPlanner() async {
    final guide = context.read<GuideProvider>();
    final request = await Navigator.push<PlannerRequest>(
        context, MaterialPageRoute(builder: (_) => const JournalPlanner()));
    if (request != null) guide.planTrip(request.answers, shownText: request.shownText);
  }

  void _handlePending(NavigationProvider nav) {
    if (nav.tabIndex != NavigationProvider.guideTab) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (nav.takePlannerRequest()) _openPlanner();
      final question = nav.takeGuideQuestion();
      if (question != null) _send(question);
    });
  }

  void _scrollIfNew(int count) {
    if (count == _shown) return;
    _shown = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _handlePending(context.watch<NavigationProvider>());
    final messages = context.watch<GuideProvider>().messages;
    _scrollIfNew(messages.length);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المرشد', style: J.title),
                      const Text('يعرف حائل، ويعمل بدون إنترنت', style: J.meta),
                    ],
                  ),
                ),
                if (messages.isNotEmpty)
                  TextButton(
                    onPressed: () => context.read<GuideProvider>().clear(),
                    child: const Text('صفحة جديدة'),
                  ),
                TextButton(
                  onPressed: _openPlanner,
                  style: TextButton.styleFrom(foregroundColor: J.ochre),
                  child: const Text('خطة رحلة'),
                ),
              ],
            ),
          ),
          const JRule(color: J.ink),
          Expanded(
            child: messages.isEmpty
                ? _welcome()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(J.gutter, 8, J.gutter, 20),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _Entry(
                      message: messages[i],
                      onSuggestion: _send,
                      onEditPlan: _openPlanner,
                    ),
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _welcome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(J.gutter, 24, J.gutter, 20),
      children: [
        const Ibex(size: 52),
        const SizedBox(height: 12),
        Text('اسألني عن حائل', style: J.heading),
        const SizedBox(height: 4),
        const Text(
          'حدائقها، وأماكن العائلة، والغروب، والآثار، والمطاعم. أو دعني أجهّز لك أيام رحلتك.',
          style: J.text,
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: _openPlanner, child: const Text('جهّز لي خطة رحلة')),
        const SizedBox(height: 28),
        const Text('أسئلة يمكنك طرحها', style: J.label),
        const SizedBox(height: 4),
        for (var i = 0; i < _questions.length; i++)
          InkWell(
            onTap: () => _send(_questions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
              child: Row(
                children: [
                  SizedBox(width: 34, child: Text(J.index(i + 1), style: J.number)),
                  Expanded(child: Text(_questions[i], style: const TextStyle(fontSize: 16))),
                  const Icon(Icons.arrow_forward, size: 16, color: J.inkSoft),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _inputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: J.paper,
        border: Border(top: BorderSide(color: J.ink, width: 1.2)),
      ),
      padding: const EdgeInsets.fromLTRB(J.gutter, 6, 10, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'اكتب سؤالك',
                hintStyle: TextStyle(color: J.inkSoft),
                border: InputBorder.none,
              ),
            ),
          ),
          JSquareButton(icon: Icons.send, tooltip: 'أرسل', filled: true, onPressed: _send),
        ],
      ),
    );
  }
}

/// One entry of the transcript: who spoke, what was said, and any places,
/// plants, follow-up questions or trip plan that came with it.
class _Entry extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onSuggestion;
  final VoidCallback onEditPlan;

  const _Entry({required this.message, required this.onSuggestion, required this.onEditPlan});

  @override
  Widget build(BuildContext context) {
    if (message.plan != null) {
      return _Timetable(plan: message.plan!, onEdit: onEditPlan);
    }
    final places = [
      for (final id in message.placeIds) ...HailData.places.where((p) => p.id == id),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.fromUser ? 'أنت' : 'المرشد',
              style: J.label.copyWith(color: message.fromUser ? J.inkSoft : J.ochre)),
          const SizedBox(height: 4),
          if (message.fromUser)
            Container(
              width: double.infinity,
              color: J.paperDeep,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(message.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            )
          else
            SelectableText(
              message.text,
              style: J.text.copyWith(fontSize: 16, color: message.isError ? J.ochre : J.ink),
            ),
          if (places.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (var i = 0; i < places.length; i++) _placeLine(context, i, places[i]),
          ],
          if (message.showPlants) ...[
            const SizedBox(height: 8),
            for (final plant in HailData.plants)
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => JournalPlantDetail(plant: plant))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
                  child: Row(children: [
                    Expanded(child: Text(plant.name, style: J.entry.copyWith(fontSize: 16))),
                    Text(plant.type, style: J.meta),
                  ]),
                ),
              ),
          ],
          if (message.suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in message.suggestions)
                  OutlinedButton(
                    onPressed: () => onSuggestion(s),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: const BorderSide(color: J.ink),
                      textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                    ),
                    child: Text(s),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          const JRule(),
        ],
      ),
    );
  }

  Widget _placeLine(BuildContext context, int i, PlaceModel place) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => JournalPlace(place: place))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(
          children: [
            SizedBox(width: 30, child: Text(J.index(i + 1), style: J.number)),
            JCategoryMark(place.category),
            const SizedBox(width: 8),
            Expanded(child: Text(place.name, style: J.entry.copyWith(fontSize: 16))),
            Text(place.category.label, style: J.meta),
          ],
        ),
      ),
    );
  }
}

/// A trip plan as a timetable: times down one side, places down the other.
class _Timetable extends StatelessWidget {
  final TripPlan plan;
  final VoidCallback onEdit;

  const _Timetable({required this.plan, required this.onEdit});

  void _saveAll(BuildContext context) {
    final favorites = context.read<FavoritesProvider>();
    final nav = context.read<NavigationProvider>();
    final ids = {for (final d in plan.days) for (final s in d.stops) s.placeId};
    final fresh = ids.where((id) => !favorites.isFavoritePlace(id)).toList();
    for (final id in fresh) {
      favorites.togglePlace(id);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(fresh.isEmpty
            ? 'كل أماكن الخطة في دفترك'
            : 'حُفظت ${J.digits('${fresh.length}')} أماكن في دفترك'),
        action: SnackBarAction(
          label: 'افتح دفتري',
          onPressed: () => nav.selectTab(NavigationProvider.profileTab),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المرشد', style: J.label),
          Text(plan.title, style: J.title),
          Text(plan.summary, style: J.meta),
          for (final day in plan.days) ...[
            const SizedBox(height: 18),
            Text(day.label, style: J.heading),
            const SizedBox(height: 6),
            const JRule(color: J.ink),
            for (final stop in day.stops) _row(context, stop),
          ],
          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('ملاحظات', style: J.label),
            for (var i = 0; i < plan.tips.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 30, child: Text(J.index(i + 1), style: J.number)),
                    Expanded(child: Text(plan.tips[i], style: J.meta.copyWith(color: J.ink))),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(onPressed: () => _saveAll(context), child: const Text('احفظ أماكن الخطة')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onEdit, child: const Text('غيّر إجاباتي')),
          const SizedBox(height: 16),
          const JRule(),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, TripStop stop) {
    final place = HailData.places.where((p) => p.id == stop.placeId).firstOrNull;
    if (place == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => JournalPlace(place: place))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(stop.time, style: J.number.copyWith(fontSize: 14.5)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    JCategoryMark(place.category),
                    const SizedBox(width: 6),
                    Flexible(child: Text(place.name, style: J.entry.copyWith(fontSize: 16.5))),
                  ]),
                  const SizedBox(height: 2),
                  Text(stop.note, style: J.meta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
