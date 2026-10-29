import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/confirmation_dialog.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/guide/widgets/planner_sheet.dart';
import 'package:hail_parks_guide/features/guide/widgets/trip_plan_card.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/features/places/food_card.dart';
import 'package:hail_parks_guide/features/plants/plant_detail_screen.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/guide_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// The guide: a chatbot trained on Hail questions (runs on the device),
/// plus the trip planner.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  static const _suggestions = [
    'وين أروح مع عيالي؟',
    'وين أشوف الغروب؟',
    'أبي مطعم حلو',
    'وش مواقع اليونسكو في حائل؟',
  ];

  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _shownCount = 0;

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
    final request = await showPlannerSheet(context);
    if (request != null) {
      guide.planTrip(request.answers, shownText: request.shownText);
    }
  }

  Future<void> _clearChat() async {
    final guide = context.read<GuideProvider>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'محادثة جديدة',
      message: 'هل تريد مسح المحادثة الحالية والبدء من جديد؟',
      confirmLabel: 'مسح',
    );
    if (confirmed) guide.clear();
  }

  /// Handles "plan my trip" or "ask the guide" requests from other screens.
  void _handlePendingRequests(NavigationProvider nav) {
    if (nav.tabIndex != NavigationProvider.guideTab) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (nav.takePlannerRequest()) _openPlanner();
      final question = nav.takeGuideQuestion();
      if (question != null) _send(question);
    });
  }

  void _scrollToBottomIfNew(int count) {
    if (count == _shownCount) return;
    _shownCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _handlePendingRequests(context.watch<NavigationProvider>());
    final messages = context.watch<GuideProvider>().messages;
    _scrollToBottomIfNew(messages.length);

    // The nav bar is hidden behind the keyboard, so only leave room for it
    // when the keyboard is closed.
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;

    return Container(
      decoration: AppDecorations.screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(messages.isNotEmpty),
            Expanded(
              child: messages.isEmpty
                  ? _buildWelcome()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) => _MessageBubble(
                        message: messages[index],
                        onEditPlan: _openPlanner,
                        onSuggestion: _send,
                      ),
                    ),
            ),
            _buildInputBar(keyboardOpen ? 8 : kNavBarSpace - 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasMessages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المرشد', style: AppText.title),
                Text('اسأل عن حائل أو خطط رحلتك', style: AppText.caption),
              ],
            ),
          ),
          if (hasMessages) ...[
            CircleIconButton(
              icon: Icons.refresh,
              tooltip: 'محادثة جديدة',
              onPressed: _clearChat,
            ),
            const SizedBox(width: 8),
          ],
          CircleIconButton(
            icon: Icons.route_outlined,
            tooltip: 'خطط رحلتي',
            onPressed: _openPlanner,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: [
        GestureDetector(
          onTap: _openPlanner,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خطط رحلتي',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '٤ أسئلة عن مدة رحلتك ومن معك واهتماماتك، ثم جدول زيارة بالأماكن والأوقات.',
                        style: TextStyle(color: AppColors.chip, height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: AppColors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('أو اسأل المرشد', style: AppText.section),
        const SizedBox(height: 12),
        for (final suggestion in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _send(suggestion),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(suggestion, style: const TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputBar(double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك للمرشد...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cream,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _send,
              child: const SizedBox(
                width: 52,
                height: 52,
                // Icons.send mirrors in RTL so it points the right way.
                child: Icon(Icons.send, color: AppColors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onEditPlan;
  final ValueChanged<String> onSuggestion;

  const _MessageBubble({
    required this.message,
    required this.onEditPlan,
    required this.onSuggestion,
  });

  /// Adds every place in the plan to favorites and says how many were new.
  void _savePlan(BuildContext context, TripPlan plan) {
    final favorites = context.read<FavoritesProvider>();
    final nav = context.read<NavigationProvider>();
    final ids = {
      for (final day in plan.days)
        for (final stop in day.stops) stop.placeId,
    };
    final newIds = ids.where((id) => !favorites.isFavoritePlace(id)).toList();
    for (final id in newIds) {
      favorites.togglePlace(id);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(newIds.isEmpty
            ? 'كل أماكن الخطة موجودة في مفضلتك'
            : 'حُفظت ${newIds.length} أماكن في مفضلتك'),
        action: SnackBarAction(
          label: 'عرض المفضلة',
          onPressed: () => nav.selectTab(NavigationProvider.profileTab),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    if (message.plan != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TripPlanCard(
          plan: message.plan!,
          onSaveAll: () => _savePlan(context, message.plan!),
          onEditAnswers: onEditPlan,
        ),
      );
    }

    final fromUser = message.fromUser;
    final places = [
      for (final id in message.placeIds)
        ...HailData.places.where((p) => p.id == id),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          // The guide's replies start on the reading side; the user's on the other.
          alignment: fromUser
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: fromUser
                  ? AppColors.primary
                  : message.isError
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.cream,
              borderRadius: BorderRadiusDirectional.only(
                topStart: const Radius.circular(20),
                topEnd: const Radius.circular(20),
                bottomStart: Radius.circular(fromUser ? 20 : 6),
                bottomEnd: Radius.circular(fromUser ? 6 : 20),
              ),
            ),
            child: SelectableText(
              message.text,
              style: TextStyle(
                color: fromUser
                    ? AppColors.white
                    : message.isError
                        ? AppColors.error
                        : AppColors.textPrimary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
        if (places.isNotEmpty)
          _horizontal(places.length, (i) => FoodCard(place: places[i])),
        if (message.showPlants)
          _horizontal(HailData.plants.length, (i) {
            final plant = HailData.plants[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant)),
              ),
              child: SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SmartImage(imageData: plant.image, width: 110, height: 90),
                    ),
                    const SizedBox(height: 4),
                    Text(plant.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          }),
        if (message.suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in message.suggestions)
                  PillChip(label: s, selected: false, onTap: () => onSuggestion(s)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _horizontal(int count, Widget Function(int) itemBuilder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => itemBuilder(i),
        ),
      ),
    );
  }
}
