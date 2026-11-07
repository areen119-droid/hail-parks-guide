import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/services/guide_model.dart';

/// The guide's answer to one question.
class GuideReply {
  final ChatMessage message;
  final GuideAction action;
  const GuideReply(this.message, [this.action = GuideAction.none]);
}

/// Answers questions using the trained intent model and the replies in
/// ml/intents.json (the same file the model was trained on).
class GuideBot {
  /// Below this confidence the guide says it didn't understand.
  static const double minConfidence = 0.6;

  final GuideModel _model;
  final Map<String, Map<String, dynamic>> _intents;
  final Map<String, dynamic> _fallback;
  final Map<String, dynamic> _outsideHail;
  final List<String> _outsidePlaces;

  GuideBot._(this._model, this._intents, this._fallback, this._outsideHail)
      : _outsidePlaces = [
          for (final place in _strings(_outsideHail['places']))
            GuideFeatures.normalize(place),
        ];

  static Future<GuideBot> load() async {
    final data = jsonDecode(await rootBundle.loadString('ml/intents.json'))
        as Map<String, dynamic>;
    return GuideBot._(
      await GuideModel.load(),
      {
        for (final intent in data['intents'] as List)
          (intent as Map<String, dynamic>)['tag'] as String: intent,
      },
      data['fallback'] as Map<String, dynamic>,
      data['outside_hail'] as Map<String, dynamic>,
    );
  }

  GuideReply reply(String question) {
    // The model only knows Hail, so a question about another city would get
    // a Hail answer. Catch that before asking the model.
    if (mentionsOnlyOtherPlace(question, _outsidePlaces)) {
      return _simple(_outsideHail);
    }
    // With no known word the model's answer is a guess, however confident.
    if (!_model.knowsAnyWord(question)) return _simple(_fallback);

    final prediction = _model.predict(question);
    final intent = _intents[prediction.label];
    if (intent == null || prediction.confidence < minConfidence) {
      return _simple(_fallback);
    }

    final show = (intent['show'] as Map<String, dynamic>?) ?? const {};
    final categories = _strings(show['categories']);
    final placeIds = [
      ..._strings(show['places']),
      for (final place in HailData.places)
        if (categories.contains(place.category.name)) place.id,
    ];

    final action = switch (intent['action']) {
      'planner' => GuideAction.openPlanner,
      'map' => GuideAction.openMap,
      _ => GuideAction.none,
    };

    return GuideReply(
      ChatMessage(
        fromUser: false,
        text: intent['reply'] as String,
        placeIds: placeIds,
        showPlants: show['plants'] == true,
        suggestions: _strings(intent['suggestions']),
      ),
      action,
    );
  }

  /// True if [question] names one of [places] (already normalized) and does
  /// not mention Hail. Allows a short prefix such as ب or و: "بالرياض".
  static bool mentionsOnlyOtherPlace(String question, List<String> places) {
    final words = GuideFeatures.normalize(question).split(' ');
    if (words.any((w) => w.contains('حايل'))) return false;
    return words.any((w) => places.any(
        (p) => w == p || (w.endsWith(p) && w.length - p.length <= 2)));
  }

  static GuideReply _simple(Map<String, dynamic> answer) => GuideReply(
        ChatMessage(
          fromUser: false,
          text: answer['reply'] as String,
          suggestions: _strings(answer['suggestions']),
        ),
      );

  static List<String> _strings(Object? value) =>
      value is List ? value.cast<String>() : const [];
}
