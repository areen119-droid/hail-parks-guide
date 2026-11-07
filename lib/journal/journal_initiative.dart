import 'package:flutter/material.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/data/initiative_data.dart';
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';

/// Our Ghars Nation initiative laid out as a newspaper article: kicker,
/// headline, standfirst, byline, photo with caption, body, pull quote.
class JournalInitiative extends StatelessWidget {
  const JournalInitiative({super.key});

  @override
  Widget build(BuildContext context) {
    final park = HailData.places.where((p) => p.id == InitiativeData.parkId).firstOrNull;
    final numbers = <(String, String)>[
      if (InitiativeData.participants != null)
        ('مشاركًا', J.digits('${InitiativeData.participants}')),
      if (InitiativeData.seedlings != null) ('شتلة', J.digits('${InitiativeData.seedlings}')),
    ];
    final byline = [
      InitiativeData.byline,
      'حائل',
      if (InitiativeData.date != null) InitiativeData.date!,
    ].join(' · ');
    final story = InitiativeData.story;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            // Masthead strip, like the top of a newspaper page.
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
                  Text('أخبار الدليل', style: J.kufiStyle(18)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 0),
              child: Column(children: [
                JRule(color: J.ink),
                SizedBox(height: 3),
                JRule(color: J.ink),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 22, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(InitiativeData.kicker, style: J.label),
                  const SizedBox(height: 6),
                  Text(InitiativeData.headline, style: J.title.copyWith(fontSize: 31, height: 1.35)),
                  const SizedBox(height: 12),
                  Text(
                    InitiativeData.standfirst,
                    style: J.text.copyWith(fontSize: 17.5, color: J.inkSoft, height: 1.65),
                  ),
                  const SizedBox(height: 16),
                  const JRule(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Image.asset(InitiativeData.logo, width: 30),
                      const SizedBox(width: 10),
                      Expanded(child: Text(J.digits(byline), style: J.meta.copyWith(color: J.ink))),
                    ]),
                  ),
                  const JRule(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._photos(),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 18, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The lead paragraph is set a little larger, as in print.
                  Text(InitiativeData.summary,
                      style: J.text.copyWith(fontSize: 17, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 14),
                  for (final paragraph in story.take(story.length - 1))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(paragraph, style: J.text.copyWith(fontSize: 16)),
                    ),
                  _pullQuote(),
                  Text('كيف شارك الزوار', style: J.heading),
                  const SizedBox(height: 6),
                  for (var i = 0; i < InitiativeData.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 30, child: Text(J.digits('${i + 1}.'), style: J.number)),
                          Expanded(child: Text(InitiativeData.steps[i], style: J.text.copyWith(fontSize: 16))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(story.last, style: J.text.copyWith(fontSize: 16)),
                  if (numbers.isNotEmpty) _numbers(numbers),
                  if (InitiativeData.team.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('الفريق: ${InitiativeData.team.join('، ')}', style: J.meta),
                  ],
                  const SizedBox(height: 26),
                  // End mark, as at the end of an article.
                  const Center(child: Ibex(size: 30)),
                  const SizedBox(height: 26),
                  if (park != null) ...[
                    const JRule(color: J.ink),
                    const SizedBox(height: 10),
                    const Text('عن المكان', style: J.label),
                    InkWell(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => JournalPlace(place: park))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          JPhoto(place: park, width: 64, height: 64),
                          const SizedBox(width: 12),
                          Expanded(child: Text(park.name, style: J.entry)),
                          const Icon(Icons.arrow_forward, size: 16),
                        ]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Photos from the day with captions; the logo until there are photos.
  List<Widget> _photos() {
    final photos = InitiativeData.photos.isNotEmpty
        ? InitiativeData.photos
        : const [(InitiativeData.logo, 'شعار تطبيق غرس نيشن')];
    return [
      for (final (src, caption) in photos) ...[
        Container(
          color: src == InitiativeData.logo ? Colors.white : null,
          padding: src == InitiativeData.logo ? const EdgeInsets.symmetric(vertical: 24) : null,
          child: src == InitiativeData.logo
              ? Image.asset(src, height: 150)
              : AspectRatio(aspectRatio: 3 / 2, child: Image.asset(src, fit: BoxFit.cover)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(J.gutter, 6, J.gutter, 0),
          child: Text(caption, style: J.meta.copyWith(fontSize: 12.5)),
        ),
      ],
    ];
  }

  Widget _pullQuote() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 48, height: 4, color: J.ochre),
          const SizedBox(height: 12),
          Text('«${InitiativeData.quote}»',
              style: J.kufiStyle(22, weight: 600).copyWith(height: 1.55)),
          const SizedBox(height: 8),
          Text(InitiativeData.quoteSource, style: J.label.copyWith(color: J.inkSoft)),
        ],
      ),
    );
  }

  Widget _numbers(List<(String, String)> numbers) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      color: J.paperDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('بالأرقام', style: J.label),
          Row(children: [
            for (final (label, value) in numbers)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: J.display.copyWith(fontSize: 36)),
                    const SizedBox(width: 6),
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: J.meta)),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }
}
