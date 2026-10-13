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
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.star, size: 20),
              SizedBox(width: 6),
              Text(
                'هل تعلم؟',
                style: TextStyle(
                  fontFamily: AppText.headingFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              HailData.facts[_index],
              key: ValueKey(_index),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.sandLight,
                height: 1.7,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _nextFact,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('معلومة أخرى'),
              style: TextButton.styleFrom(foregroundColor: AppColors.star),
            ),
          ),
        ],
      ),
    );
  }
}
