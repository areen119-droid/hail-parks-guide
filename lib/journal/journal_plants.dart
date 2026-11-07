import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/core/widgets/favorite_feedback.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/journal/journal_widgets.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';

/// The region's plants as herbarium entries: number, specimen photo, Arabic
/// and scientific names.
class JournalPlants extends StatefulWidget {
  const JournalPlants({super.key});

  @override
  State<JournalPlants> createState() => _JournalPlantsState();
}

class _JournalPlantsState extends State<JournalPlants> {
  String? _type;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final types = {for (final p in HailData.plants) p.type}.toList();
    final plants = HailData.plants
        .where((p) => (_type == null || p.type == _type) && p.name.contains(_query.trim()))
        .toList();

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
                Text('المعشبة', style: J.display.copyWith(fontSize: 40)),
                Text(J.digits('${HailData.plants.length} نباتات من حائل وحدائقها'), style: J.meta),
                const SizedBox(height: 12),
                const JRule(color: J.ink),
              ],
            ),
          ),
          JTabs<String?>(
            tabs: [(null, 'الكل'), for (final t in types) (t, t)],
            selected: _type,
            onSelected: (t) => setState(() => _type = t),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: J.gutter),
            child: JSearchField(hint: 'ابحث عن نبات', onChanged: (v) => setState(() => _query = v)),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < plants.length; i++) _entry(context, i + 1, plants[i]),
          if (plants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(J.gutter),
              child: Text('لا يوجد نبات بهذا الاسم', style: J.meta),
            ),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, int n, Plant plant) {
    final saved = context.watch<FavoritesProvider>().isFavoritePlant(plant.id);
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => JournalPlantDetail(plant: plant))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: J.gutter),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: J.rule))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 34, child: Text(J.index(n), style: J.number)),
            SmartImage(imageData: plant.image, width: 92, height: 92),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name, style: J.heading),
                  Text(plant.scientificName,
                      textDirection: TextDirection.ltr,
                      style: J.meta.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 6),
                  Text(plant.type, style: J.label),
                ],
              ),
            ),
            IconButton(
              tooltip: saved ? 'أزل من دفتري' : 'احفظ في دفتري',
              onPressed: () => toggleFavoritePlant(context, plant),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                  color: saved ? J.ochre : J.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// A plant's page in the journal design.
class JournalPlantDetail extends StatelessWidget {
  final Plant plant;
  const JournalPlantDetail({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<FavoritesProvider>().isFavoritePlant(plant.id);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 10, J.gutter, 14),
              child: Row(children: [
                JSquareButton(
                    icon: Icons.arrow_back, tooltip: 'رجوع', onPressed: () => Navigator.pop(context)),
                const Spacer(),
                Text('المعشبة', style: J.label.copyWith(color: J.inkSoft)),
              ]),
            ),
            AspectRatio(aspectRatio: 1, child: SmartImage(imageData: plant.image)),
            Padding(
              padding: const EdgeInsets.fromLTRB(J.gutter, 18, J.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.type, style: J.label),
                  Text(plant.name, style: J.title.copyWith(fontSize: 34)),
                  Text(plant.scientificName,
                      textDirection: TextDirection.ltr,
                      style: J.meta.copyWith(fontStyle: FontStyle.italic, fontSize: 15)),
                  const SizedBox(height: 14),
                  const JRule(color: J.ink),
                  const SizedBox(height: 14),
                  Text(plant.description, style: J.text.copyWith(fontSize: 16)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => toggleFavoritePlant(context, plant),
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 20),
                    label: Text(saved ? 'في دفتري' : 'احفظ في دفتري'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
