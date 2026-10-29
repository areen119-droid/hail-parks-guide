import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/data/hail_data.dart';

/// "Did you know?" card that cycles through facts about Hail.
class FactsWidget extends StatefulWidget {
  const FactsWidget({super.key});

  @override
  State<FactsWidget> createState() => _FactsWidgetState();
}

class _FactsWidgetState extends State<FactsWidget> {
  // Start on a different fact each day.
  int _index = DateTime.now().day % HailData.facts.length;

  void _nextFact() =>
      setState(() => _index = (_index + 1) % HailData.facts.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      // Light card so the planner banner stays the one dark block on Home.
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('هل تعلم؟', style: AppText.section),
          const SizedBox(height: 6),
          Text(
            HailData.facts[_index],
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _nextFact,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('معلومة أخرى'),
            ),
          ),
        ],
      ),
    );
  }
}
