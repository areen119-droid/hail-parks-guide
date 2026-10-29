import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/confirmation_dialog.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/features/guide/widgets/planner_sheet.dart';
import 'package:hail_parks_guide/features/guide/widgets/trip_plan_card.dart';
import 'package:hail_parks_guide/features/navigation/bottom_nav_bar.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/guide_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// AI guide: chat about Hail's places and plan trips.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  static const _suggestions = [
    'ما أفضل مكان للعائلات مع الأطفال؟',
    'أين أشاهد غروب الشمس في حائل؟',
    'ما المواقع المسجلة في اليونسكو؟',
    'ما النباتات التي قد أراها في الجبال؟',
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

  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    context.read<GuideProvider>().ask(question);
  }

  Future<void> _openPlanner() async {
    final guide = context.read<GuideProvider>();
    if (!guide.hasApiKey) return; // the screen already explains how to enable it
    final request = await showPlannerSheet(context);
    if (request != null) {
      guide.planTrip(request.prompt, shownText: request.shownText);
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
    final guide = context.watch<GuideProvider>();
    final messages = guide.messages;
    _scrollToBottomIfNew(messages.length + (guide.loading ? 1 : 0));

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
              child: !guide.hasApiKey
                  ? _buildMissingKey()
                  : messages.isEmpty
                      ? _buildWelcome()
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: messages.length + (guide.loading ? 1 : 0),
                          itemBuilder: (context, index) => index == messages.length
                              ? const _TypingBubble()
                              : _MessageBubble(
                                  message: messages[index],
                                  onEditPlan: _openPlanner,
                                  onFollowUp: _send,
                                ),
                        ),
            ),
            if (guide.hasApiKey)
              _buildInputBar(guide.loading, keyboardOpen ? 8 : kNavBarSpace - 8),
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

  Widget _buildMissingKey() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.key_off_outlined, size: 44, color: AppColors.accent),
              SizedBox(height: 12),
              Text('المرشد غير مفعّل', style: AppText.section),
              SizedBox(height: 8),
              Text(
                'لتفعيل المرشد، ضع مفتاح Claude API في ملف api_keys.json '
                'وشغّل التطبيق مع:',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              SizedBox(height: 6),
              Text(
                '--dart-define-from-file=api_keys.json',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool loading, double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              enabled: !loading,
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
            color: loading ? AppColors.chip : AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: loading ? null : _send,
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
  final ValueChanged<String> onFollowUp;

  const _MessageBubble({
    required this.message,
    required this.onEditPlan,
    required this.onFollowUp,
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
          onFollowUp: onFollowUp,
        ),
      );
    }

    final fromUser = message.fromUser;
    final background = fromUser
        ? AppColors.primary
        : message.isError
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.cream;
    final textColor = fromUser
        ? AppColors.white
        : message.isError
            ? AppColors.error
            : AppColors.textPrimary;

    return Align(
      // The guide's replies start on the reading side; the user's on the other.
      alignment:
          fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(20),
            topEnd: const Radius.circular(20),
            bottomStart: Radius.circular(fromUser ? 22 : 6),
            bottomEnd: Radius.circular(fromUser ? 6 : 22),
          ),
        ),
        child: SelectableText(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accent),
            ),
            SizedBox(width: 10),
            Text('المرشد يفكر...', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
