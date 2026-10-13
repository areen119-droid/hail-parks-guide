import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hail_parks_guide/data/guide_prompt.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/chat_message.dart';

void main() {
  test('guide prompt includes every place and plant', () {
    final prompt = buildGuideSystemPrompt();
    for (final place in HailData.places) {
      expect(prompt, contains('id: ${place.id}'));
      expect(prompt, contains(place.name));
    }
    for (final plant in HailData.plants) {
      expect(prompt, contains(plant.name));
    }
  });

  test('place ids are unique', () {
    final ids = HailData.places.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('trip plan JSON parses into days and stops', () {
    final json = jsonDecode('''
{
  "title": "يوم في حائل",
  "summary": "جولة بين التراث والطبيعة",
  "days": [
    {"label": "اليوم الأول", "stops": [
      {"place_id": "aarif", "time": "٩:٠٠ صباحًا", "note": "إطلالة على المدينة"},
      {"place_id": "samra", "time": "٥:٠٠ مساءً", "note": "غروب الشمس"}
    ]}
  ],
  "tips": ["احمل الماء"]
}''') as Map<String, dynamic>;

    final plan = TripPlan.fromJson(json);
    expect(plan.title, 'يوم في حائل');
    expect(plan.days.single.stops.map((s) => s.placeId), ['aarif', 'samra']);
    expect(plan.tips, ['احمل الماء']);
  });
}
