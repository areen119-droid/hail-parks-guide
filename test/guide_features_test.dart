import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hail_parks_guide/services/guide_model.dart';

void main() {
  test('Dart features match the features the model was trained on', () {
    final intents =
        jsonDecode(File('ml/intents.json').readAsStringSync()) as Map<String, dynamic>;
    final vocab = jsonDecode(File('assets/ml/vocab.json').readAsStringSync())
        as Map<String, dynamic>;

    final dartFeatures = <String>{
      for (final intent in intents['intents'] as List)
        for (final example in (intent['examples'] as List).cast<String>())
          ...GuideFeatures.extract(example),
    };
    final trained = (vocab['features'] as List).cast<String>().toSet();

    expect(vocab['feature_version'], GuideFeatures.version);
    expect(dartFeatures.difference(trained), isEmpty,
        reason: 'Dart makes features Python never made');
    expect(trained.difference(dartFeatures), isEmpty,
        reason: 'Python made features Dart never makes');
  });

  test('normalize unifies Arabic letter forms', () {
    expect(GuideFeatures.normalize('أَهلاً بِكم في حائلْ!'), 'اهلا بكم في حايل');
    expect(GuideFeatures.normalize('مكتبة إسلامية'), 'مكتبه اسلاميه');
  });
}
