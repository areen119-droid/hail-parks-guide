import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paleBrown,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'هل تعلم؟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.lightbulb, color: AppColors.darkBrown, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              HailData.facts[_index],
              key: ValueKey(_index),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
                height: 1.6,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _nextFact,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('معلومة أخرى'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mediumBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
