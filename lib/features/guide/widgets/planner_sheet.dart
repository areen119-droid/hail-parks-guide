import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';
import 'package:hail_parks_guide/services/trip_planner.dart';

/// What the planner form produces: the answers, and a short summary of
/// them to show in the chat.
class PlannerRequest {
  final TripAnswers answers;
  final String shownText;
  const PlannerRequest(this.answers, this.shownText);
}

/// Opens the trip planner; returns null if the user closes it.
Future<PlannerRequest?> showPlannerSheet(BuildContext context) {
  return showModalBottomSheet<PlannerRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _PlannerSheet(),
  );
}

/// Asks one question at a time, each with a sensible answer preselected.
class _PlannerSheet extends StatefulWidget {
  const _PlannerSheet();

  @override
  State<_PlannerSheet> createState() => _PlannerSheetState();
}

class _PlannerSheetState extends State<_PlannerSheet> {
  static const _durations = ['نصف يوم', 'يوم كامل', 'يومان', 'ثلاثة أيام'];
  static const _companions = ['عائلة مع أطفال', 'أصدقاء', 'بمفردي', 'كبار السن'];
  static const _interests = [
    'الحدائق',
    'الطبيعة والجبال',
    'التراث والتاريخ',
    'المطاعم والمقاهي',
    'التصوير',
    'المشي',
    'النباتات',
  ];
  static const _times = ['الصباح', 'المساء', 'لا يهم'];
  static const _stepCount = 4;

  int _step = 0;
  String _duration = 'يوم كامل';
  String _companion = 'عائلة مع أطفال';
  final Set<String> _selectedInterests = {'الحدائق', 'الطبيعة والجبال'};
  String _time = 'المساء';
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _submit() {
    final interests =
        _selectedInterests.isEmpty ? 'كل شيء' : _selectedInterests.join('، ');
    final notes = _notes.text.trim();

    final answers = TripAnswers(
      duration: _duration,
      companion: _companion,
      interests: {..._selectedInterests},
      time: _time,
      notes: notes,
    );
    final shownText =
        'خطط لي رحلة: $_duration، $_companion، $interests${notes.isEmpty ? '' : '، $notes'}';

    Navigator.pop(context, PlannerRequest(answers, shownText));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == _stepCount - 1;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'السؤال ${_step + 1} من $_stepCount',
                    style: AppText.caption,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'إغلاق',
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _stepCount,
                  minHeight: 4,
                  color: AppColors.primary,
                  backgroundColor: AppColors.chip,
                ),
              ),
              const SizedBox(height: 20),
              ..._buildStep(),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isLast ? 'اعرض خطتي' : 'التالي',
                onPressed: _next,
              ),
              if (_step > 0)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _step--),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                    child: const Text('رجوع'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep() {
    switch (_step) {
      case 0:
        return [
          const Text('كم مدة رحلتك؟', style: AppText.title),
          const SizedBox(height: 14),
          ..._options(_durations, (o) => o == _duration, (o) => _duration = o),
        ];
      case 1:
        return [
          const Text('من سيرافقك؟', style: AppText.title),
          const Text('نقترح أماكن تناسب من معك', style: AppText.caption),
          const SizedBox(height: 14),
          ..._options(_companions, (o) => o == _companion, (o) => _companion = o),
        ];
      case 2:
        return [
          const Text('ما الذي يهمك؟', style: AppText.title),
          const Text('يمكنك اختيار أكثر من خيار', style: AppText.caption),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in _interests)
                PillChip(
                  label: interest,
                  selected: _selectedInterests.contains(interest),
                  onTap: () => setState(() {
                    if (!_selectedInterests.remove(interest)) {
                      _selectedInterests.add(interest);
                    }
                  }),
                ),
            ],
          ),
        ];
      default:
        return [
          const Text('متى تفضّل الخروج؟', style: AppText.title),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in _times)
                PillChip(
                  label: time,
                  selected: time == _time,
                  onTap: () => setState(() => _time = time),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('أي شيء آخر؟ (اختياري)', style: AppText.section),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            decoration: InputDecoration(
              hintText: 'مثلًا: لا نملك سيارة، أو نفضّل الأماكن الهادئة',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.sandLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ];
    }
  }

  /// Full-width answer rows; the selected one is filled green.
  List<Widget> _options(List<String> options, bool Function(String) isSelected,
      void Function(String) select) {
    return [
      for (final option in options)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected(option) ? AppColors.primary : AppColors.sandLight,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => select(option)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected(option)
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected(option))
                      const Icon(Icons.check, color: AppColors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }
}
