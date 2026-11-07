import 'package:flutter/material.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/data/initiative_data.dart';
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';

/// Our Ghars Nation planting initiative, in the journal design.
class JournalInitiative extends StatelessWidget {
  const JournalInitiative({super.key});

  @override
  Widget build(BuildContext context) {
    final park = HailData.places.where((p) => p.id == InitiativeData.parkId).firstOrNull;
    final numbers = <(String, String)>[
      if (InitiativeData.date != null) ('التاريخ', InitiativeData.date!),
      if (InitiativeData.participants != null)
        ('المشاركون', J.digits('${InitiativeData.participants}')),
      if (InitiativeData.seedlings != null) ('الشتلات', J.digits('${InitiativeData.seedlings}')),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 10, J.gutter, 0),
              child: Row(
                children: [
                  JSquareButton(
                    icon: Icons.arrow_back,
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text('من أعمالنا', style: J.label.copyWith(color: J.inkSoft)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(J.gutter, 18, J.gutter, 0),
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(InitiativeData.logo, height: 130),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 18, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${InitiativeData.appName} · ${InitiativeData.appNameLatin}', style: J.label),
                  const SizedBox(height: 4),
                  Text(InitiativeData.title, style: J.title),
                  const SizedBox(height: 12),
                  Text(InitiativeData.summary, style: J.text.copyWith(fontSize: 16)),
                  if (numbers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const JRule(color: J.ink),
                    Row(
                      children: [
                        for (final (label, value) in numbers)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(value, style: J.title),
                                  Text(label, style: J.meta),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const JRule(),
                  ],
                ],
              ),
            ),
            const JSection(number: 1, title: 'القصة'),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 14, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final paragraph in InitiativeData.story)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(paragraph, style: J.text),
                    ),
                ],
              ),
            ),
            const JSection(number: 2, title: 'كيف شارك الزوار'),
            for (var i = 0; i < InitiativeData.steps.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: J.gutter),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 34, child: Text(J.index(i + 1), style: J.number)),
                    Expanded(child: Text(InitiativeData.steps[i], style: J.text)),
                  ],
                ),
              ),
            if (InitiativeData.team.isNotEmpty) ...[
              const JSection(number: 3, title: 'الفريق'),
              Padding(
                padding: const EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 0),
                child: Text(InitiativeData.team.join('، '), style: J.text),
              ),
            ],
            if (park != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(J.gutter, 28, J.gutter, 0),
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => JournalPlace(place: park))),
                  child: Text('عن ${park.name}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
