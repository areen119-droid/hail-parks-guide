import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/journal/journal_guide.dart';
import 'package:hail_parks_guide/journal/journal_home.dart';
import 'package:hail_parks_guide/journal/journal_map.dart';
import 'package:hail_parks_guide/journal/journal_plants.dart';
import 'package:hail_parks_guide/journal/journal_profile.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// The journal design's tabs, with a flat ink strip of text labels at the
/// bottom (same tab order as the classic design).
class JournalShell extends StatelessWidget {
  const JournalShell({super.key});

  static const _labels = ['الدفتر', 'الخريطة', 'المرشد', 'المعشبة', 'دفتري'];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Scaffold(
      body: IndexedStack(
        index: nav.tabIndex,
        children: const [
          JournalHome(),
          JournalMap(),
          JournalGuide(),
          JournalPlants(),
          JournalProfile(),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: J.ink,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => nav.selectTab(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // A short ochre bar marks the open tab.
                          Container(
                            width: 18,
                            height: 3,
                            color: nav.tabIndex == i ? J.ochre : Colors.transparent,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: nav.tabIndex == i ? FontWeight.w700 : FontWeight.w500,
                              color: nav.tabIndex == i ? J.onInk : J.onInkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
