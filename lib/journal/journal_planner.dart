import 'package:flutter/material.dart';
import 'package:hail_parks_guide/features/guide/widgets/planner_sheet.dart' show PlannerRequest;
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/services/trip_planner.dart';

/// The trip planner as a full page, one question at a time. Returns a
/// [PlannerRequest], or null if closed.
class JournalPlanner extends StatefulWidget {
  const JournalPlanner({super.key});

  @override
  State<JournalPlanner> createState() => _JournalPlannerState();
}

class _JournalPlannerState extends State<JournalPlanner> {
  static const _durations = ['نصف يوم', 'يوم كامل', 'يومان', 'ثلاثة أيام'];
  static const _companions = ['عائلة مع أطفال', 'أصدقاء', 'بمفردي', 'كبار السن'];
  static const _interests = [
    'الحدائق', 'الطبيعة والجبال', 'التراث والتاريخ', 'المطاعم والمقاهي',
    'التصوير', 'المشي', 'النباتات',
  ];
  static const _times = ['الصباح', 'المساء', 'لا يهم'];
  static const _steps = 4;

  int _step = 0;
  String _duration = 'يوم كامل';
  String _companion = 'عائلة مع أطفال';
  final Set<String> _chosen = {'الحدائق', 'الطبيعة والجبال'};
  String _time = 'المساء';
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps - 1) {
      setState(() => _step++);
      return;
    }
    final notes = _notes.text.trim();
    final interests = _chosen.isEmpty ? 'كل شيء' : _chosen.join('، ');
    Navigator.pop(
      context,
      PlannerRequest(
        TripAnswers(
          duration: _duration,
          companion: _companion,
          interests: {..._chosen},
          time: _time,
          notes: notes,
        ),
        'خطط لي رحلة: $_duration، $_companion، $interests${notes.isEmpty ? '' : '، $notes'}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (question, hint) = switch (_step) {
      0 => ('كم يومًا ستقضي في حائل؟', null),
      1 => ('من معك في الرحلة؟', 'نختار أماكن ومطاعم تناسبهم'),
      2 => ('ما الذي يهمك؟', 'اختر ما تشاء'),
      _ => ('متى تفضّل أن يبدأ يومك؟', null),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 10, J.gutter, 0),
              child: Row(
                children: [
                  Text(J.digits('${_step + 1} من $_steps'), style: J.number.copyWith(fontSize: 18)),
                  const Spacer(),
                  JSquareButton(icon: Icons.close, tooltip: 'إغلاق', onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 14, J.gutter, 0),
              child: Row(
                children: [
                  for (var i = 0; i < _steps; i++) ...[
                    Expanded(child: Container(height: 4, color: i <= _step ? J.ochre : J.rule)),
                    if (i < _steps - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(J.gutter, 28, J.gutter, 20),
                children: [
                  Text(question, style: J.title.copyWith(fontSize: 30)),
                  if (hint != null) Text(hint, style: J.meta),
                  const SizedBox(height: 18),
                  const JRule(color: J.ink),
                  ..._options(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 0, J.gutter, 12),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_step == _steps - 1 ? 'اعرض خطتي' : 'التالي'),
                  ),
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('السؤال السابق'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _options() {
    switch (_step) {
      case 0:
        return [for (final d in _durations) _row(d, d == _duration, () => _duration = d)];
      case 1:
        return [for (final c in _companions) _row(c, c == _companion, () => _companion = c)];
      case 2:
        return [
          for (final i in _interests)
            _row(i, _chosen.contains(i), () {
              if (!_chosen.remove(i)) _chosen.add(i);
            }, multiple: true),
        ];
      default:
        return [
          for (final t in _times) _row(t, t == _time, () => _time = t),
          const SizedBox(height: 24),
          const Text('أي شيء آخر؟ (اختياري)', style: J.label),
          TextField(
            controller: _notes,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'مثلًا: لا نملك سيارة',
              hintStyle: TextStyle(color: J.inkSoft),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: J.ink, width: 1.2)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: J.ochre, width: 2)),
            ),
          ),
        ];
    }
  }

  /// An answer line with a square mark: filled when chosen.
  Widget _row(String label, bool selected, VoidCallback select, {bool multiple = false}) {
    return InkWell(
      onTap: () => setState(select),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? J.ink : Colors.transparent,
                border: Border.all(color: J.ink, width: 1.6),
              ),
              child: selected && multiple ? const Icon(Icons.check, size: 15, color: J.onInk) : null,
            ),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(fontSize: 17, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
