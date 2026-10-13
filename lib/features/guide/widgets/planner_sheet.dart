import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';

/// What the planner form produces: the full request for the AI, and a short
/// version to show in the chat.
class PlannerRequest {
  final String prompt;
  final String shownText;
  const PlannerRequest(this.prompt, this.shownText);
}

/// Opens the trip planner form; returns null if the user closes it.
Future<PlannerRequest?> showPlannerSheet(BuildContext context) {
  return showModalBottomSheet<PlannerRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const _PlannerSheet(),
  );
}

class _PlannerSheet extends StatefulWidget {
  const _PlannerSheet();

  @override
  State<_PlannerSheet> createState() => _PlannerSheetState();
}

class _PlannerSheetState extends State<_PlannerSheet> {
  static const _durations = ['نصف يوم', 'يوم كامل', 'يومان', 'ثلاثة أيام'];
  static const _companions = ['عائلة مع أطفال', 'أصدقاء', 'بمفردي', 'كبار السن'];
  static const _interests = [
    'الطبيعة والجبال',
    'التراث والتاريخ',
    'الحدائق',
    'التصوير',
    'المشي',
    'النباتات',
  ];
  static const _times = ['الصباح', 'المساء', 'مرن'];

  String _duration = 'يوم كامل';
  String _companion = 'عائلة مع أطفال';
  final Set<String> _selectedInterests = {'الطبيعة والجبال', 'التراث والتاريخ'};
  String _time = 'مرن';
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final interests =
        _selectedInterests.isEmpty ? 'كل شيء' : _selectedInterests.join('، ');
    final notes = _notes.text.trim();

    final prompt = '''
خطط لي رحلة في منطقة حائل باستخدام الأماكن الموجودة في التطبيق فقط.
- مدة الرحلة: $_duration
- الرفقة: $_companion
- الاهتمامات: $interests
- الوقت المفضل: $_time
${notes.isEmpty ? '' : '- ملاحظات: $notes'}

رتّب المحطات بترتيب منطقي حسب القرب الجغرافي، واجعل عدد المحطات واقعيًا للمدة مع مراعاة المسافات بين الأماكن. سمِّ كل يوم مثل "اليوم الأول"، واكتب وقتًا تقريبيًا لكل محطة مثل "٩:٠٠ صباحًا"، ونبذة قصيرة لماذا تناسب هذه المحطة الزائر. اكتب كل النصوص بالعربية.''';

    final shownText =
        'خطط لي رحلة: $_duration · $_companion · $interests${notes.isEmpty ? '' : ' · $notes'}';

    Navigator.pop(context, PlannerRequest(prompt, shownText));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.chip,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('خطط رحلتك إلى حائل', style: AppText.title),
              const Text(
                'أخبرنا عن رحلتك وسيقترح المرشد خطة من أماكن حائل',
                style: AppText.caption,
              ),
              _section('مدة الرحلة'),
              _singleChoice(_durations, _duration, (v) => _duration = v),
              _section('من سيرافقك؟'),
              _singleChoice(_companions, _companion, (v) => _companion = v),
              _section('ما الذي يهمك؟'),
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
              _section('الوقت المفضل'),
              _singleChoice(_times, _time, (v) => _time = v),
              _section('ملاحظات (اختياري)'),
              TextField(
                controller: _notes,
                decoration: InputDecoration(
                  hintText: 'مثلًا: لا نملك سيارة، نحب الأماكن الهادئة...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.sandLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'خطط رحلتي',
                icon: Icons.auto_awesome,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(title, style: AppText.section),
      );

  Widget _singleChoice(
      List<String> options, String selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          PillChip(
            label: option,
            selected: option == selected,
            onTap: () => setState(() => onSelect(option)),
          ),
      ],
    );
  }
}
