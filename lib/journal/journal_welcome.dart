import 'package:flutter/material.dart';
import 'package:hail_parks_guide/journal/journal_shell.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';

/// First screen of the journal design: a photo plate and the title page.
class JournalWelcome extends StatelessWidget {
  const JournalWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Image.asset('assets/images/welcome_bg.jpg', fit: BoxFit.cover),
          ),
          Expanded(
            flex: 9,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Ibex(size: 44),
                        const Spacer(),
                        Text('دفتر الرحلة', style: J.label.copyWith(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('دليل حدائق حائل', style: J.display.copyWith(fontSize: 40)),
                    const SizedBox(height: 6),
                    const Text(
                      'حدائق المدينة وجبالها وآثارها في دفتر واحد، ومرشد يجهّز لك أيام رحلتك.',
                      style: J.text,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const JournalShell()),
                      ),
                      child: const Text('افتح الدفتر'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
