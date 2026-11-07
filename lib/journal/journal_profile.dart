import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/widgets/confirmation_dialog.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/features/settings/screens/about_us_screen.dart';
import 'package:hail_parks_guide/journal/journal_place.dart';
import 'package:hail_parks_guide/journal/journal_plants.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/providers/design_provider.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

/// "My journal": the account, saved places and plants, and settings
/// (including switching back to the classic design).
class JournalProfile extends StatefulWidget {
  const JournalProfile({super.key});

  @override
  State<JournalProfile> createState() => _JournalProfileState();
}

class _JournalProfileState extends State<JournalProfile> {
  bool _plants = false;

  Future<void> _clear() async {
    final favorites = context.read<FavoritesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final count = favorites.favoritePlaces.length + favorites.favoritePlants.length;
    if (count == 0) {
      messenger.showSnackBar(const SnackBar(content: Text('لا توجد محفوظات لمسحها')));
      return;
    }
    final ok = await showConfirmationDialog(
      context,
      title: 'مسح المحفوظات',
      message: 'ستُزال ${J.digits('$count')} عناصر من محفوظاتك. لا يمكن التراجع عن ذلك.',
      confirmLabel: 'مسح الكل',
    );
    if (!ok) return;
    await favorites.clearAll();
    messenger.showSnackBar(const SnackBar(content: Text('مُسحت المحفوظات')));
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final designs = context.watch<DesignProvider>();
    const user = HailData.currentUser;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ملفي', style: J.label),
                Text(user.name, style: J.display.copyWith(fontSize: 38)),
                Text('@${user.username} · ${user.city}', textDirection: TextDirection.rtl, style: J.meta),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(user.bio, style: J.text),
                ],
                const SizedBox(height: 16),
                const JRule(color: J.ink),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _count(favorites.favoritePlaces.length, 'مكانًا محفوظًا'),
                      Container(width: 1, color: J.rule),
                      const SizedBox(width: 16),
                      _count(favorites.favoritePlants.length, 'نباتًا محفوظًا'),
                    ],
                  ),
                ),
                const JRule(),
              ],
            ),
          ),
          JTabs<bool>(
            tabs: const [(false, 'الأماكن'), (true, 'النباتات')],
            selected: _plants,
            onSelected: (v) => setState(() => _plants = v),
          ),
          if (!_plants)
            ..._list(
              favorites.favoritePlaces.map((p) => (
                    p.name,
                    p.category.label,
                    JPhoto(place: p, width: 52, height: 52),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalPlace(place: p))),
                    () => favorites.togglePlace(p.id),
                  )),
              empty: 'لم تحفظ أماكن بعد. احفظ ما يعجبك من صفحة أي مكان.',
            )
          else
            ..._list(
              favorites.favoritePlants.map((p) => (
                    p.name,
                    p.type,
                    SmartImage(imageData: p.image, width: 52, height: 52),
                    () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => JournalPlantDetail(plant: p))),
                    () => favorites.togglePlant(p.id),
                  )),
              empty: 'لم تحفظ نباتات بعد.',
            ),
          const JSection(number: 1, title: 'الإعدادات'),
          Padding(
            padding: const EdgeInsets.fromLTRB(J.gutter, 12, J.gutter, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شكل التطبيق', style: J.label),
                const SizedBox(height: 6),
                for (final d in AppDesign.values)
                  InkWell(
                    onTap: () => designs.setDesign(d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
                      child: Row(children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: designs.design == d ? J.ink : Colors.transparent,
                            border: Border.all(color: J.ink, width: 1.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(d.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                _settingsRow('عن التطبيق', () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AboutUsScreen()))),
                _settingsRow('مسح المحفوظات', _clear, color: J.ochre),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _count(int n, String label) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(J.digits('$n'), style: J.display.copyWith(fontSize: 36, height: 1.1)),
              Text(label, style: J.meta),
            ],
          ),
        ),
      );

  List<Widget> _list(
    Iterable<(String, String, Widget, VoidCallback, VoidCallback)> items, {
    required String empty,
  }) {
    final rows = items.toList();
    if (rows.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(J.gutter, 16, J.gutter, 0),
          child: Text(empty, style: J.meta),
        ),
      ];
    }
    return [
      for (final (name, kind, image, open, remove) in rows)
        InkWell(
          onTap: open,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: J.gutter),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
            child: Row(children: [
              image,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: J.entry.copyWith(fontSize: 16)),
                    Text(kind, style: J.meta),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'أزل',
                onPressed: remove,
                icon: const Icon(Icons.close, color: J.inkSoft, size: 20),
              ),
            ]),
          ),
        ),
    ];
  }

  Widget _settingsRow(String title, VoidCallback onTap, {Color color = J.ink}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(children: [
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          ),
          Icon(Icons.arrow_forward, size: 16, color: color),
        ]),
      ),
    );
  }
}
