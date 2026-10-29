import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Text features for the chatbot model. These must match ml/features.py
/// exactly, because the model was trained on features made by that code.
class GuideFeatures {
  static const int version = 1;

  static final RegExp _diacritics = RegExp('[ً-ْٰـ]');
  static final RegExp _alefForms = RegExp('[إأآٱ]');
  static final RegExp _notLetter = RegExp('[^ء-يa-z0-9]+');

  /// Lowercase, strip diacritics, unify letter forms, keep letters/digits.
  static String normalize(String text) {
    var t = text.toLowerCase();
    t = t.replaceAll(_diacritics, '');
    t = t.replaceAll(_alefForms, 'ا');
    t = t
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');
    t = t.replaceAll(_notLetter, ' ');
    return t.trim();
  }

  /// Whole words plus 3-letter pieces of each word.
  static Set<String> extract(String text) {
    final feats = <String>{};
    final normalized = normalize(text);
    if (normalized.isEmpty) return feats;
    for (final word in normalized.split(RegExp(r'\s+'))) {
      feats.add('w:$word');
      final padded = '#$word#';
      for (var i = 0; i + 3 <= padded.length; i++) {
        feats.add('c:${padded.substring(i, i + 3)}');
      }
    }
    return feats;
  }
}

/// What the model thinks a question is about.
class IntentPrediction {
  final String label;
  final double confidence;
  const IntentPrediction(this.label, this.confidence);
}

/// Runs the trained intent model (assets/ml) on the device.
class GuideModel {
  final Interpreter _interpreter;
  final Map<String, int> _featureIndex;
  final List<String> _labels;

  GuideModel._(this._interpreter, this._featureIndex, this._labels);

  static Future<GuideModel> load() async {
    final vocab = jsonDecode(await rootBundle.loadString('assets/ml/vocab.json'))
        as Map<String, dynamic>;
    if (vocab['feature_version'] != GuideFeatures.version) {
      throw StateError('Model was trained with different text features; retrain it.');
    }
    final features = (vocab['features'] as List).cast<String>();
    final labels =
        (jsonDecode(await rootBundle.loadString('assets/ml/labels.json')) as List)
            .cast<String>();
    final interpreter =
        await Interpreter.fromAsset('assets/ml/hail_guide_model.tflite');
    return GuideModel._(
      interpreter,
      {for (var i = 0; i < features.length; i++) features[i]: i},
      labels,
    );
  }

  IntentPrediction predict(String question) {
    final input = List<double>.filled(_featureIndex.length, 0);
    for (final feature in GuideFeatures.extract(question)) {
      final i = _featureIndex[feature];
      if (i != null) input[i] = 1;
    }
    final output = [List<double>.filled(_labels.length, 0)];
    _interpreter.run([input], output);

    final probs = output.first;
    var best = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[best]) best = i;
    }
    return IntentPrediction(_labels[best], probs[best]);
  }
}
