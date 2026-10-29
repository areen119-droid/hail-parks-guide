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
  static const double minConfidence = 0.5;

  final GuideModel _model;
  final Map<String, Map<String, dynamic>> _intents;
  final Map<String, dynamic> _fallback;

  GuideBot._(this._model, this._intents, this._fallback);

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
    );
  }

  GuideReply reply(String question) {
    final prediction = _model.predict(question);
    final intent = _intents[prediction.label];
    if (intent == null || prediction.confidence < minConfidence) {
      return GuideReply(ChatMessage(
        fromUser: false,
        text: _fallback['reply'] as String,
        suggestions: _strings(_fallback['suggestions']),
      ));
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

  static List<String> _strings(Object? value) =>
      value is List ? value.cast<String>() : const [];
}
