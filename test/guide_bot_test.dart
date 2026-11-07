import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hail_parks_guide/services/guide_bot.dart';
import 'package:hail_parks_guide/services/guide_model.dart';

void main() {
  final intents =
      jsonDecode(File('ml/intents.json').readAsStringSync()) as Map<String, dynamic>;
  final places = [
    for (final p in (intents['outside_hail']['places'] as List).cast<String>())
      GuideFeatures.normalize(p),
  ];

  test('questions about other cities are caught', () {
    for (final q in ['وين احسن مطعم في الرياض', 'كافيه حلو بجدة', 'مطاعم دبي', 'اماكن في أبها']) {
      expect(GuideBot.mentionsOnlyOtherPlace(q, places), isTrue, reason: q);
    }
  });

  test('Hail questions, and trips from other cities to Hail, are not caught', () {
    for (final q in ['وين احسن مطعم', 'كم المسافة من الرياض الى حائل', 'وين اروح مع عيالي',
        'منتزه الأمير سعود', 'ابي اطلع مع جدتي']) {
      expect(GuideBot.mentionsOnlyOtherPlace(q, places), isFalse, reason: q);
    }
  });

  test('no training example is mistaken for another city', () {
    for (final intent in intents['intents'] as List) {
      if (intent['tag'] == 'out_of_scope') continue;
      for (final q in (intent['examples'] as List).cast<String>()) {
        expect(GuideBot.mentionsOnlyOtherPlace(q, places), isFalse, reason: q);
      }
    }
  });
}
