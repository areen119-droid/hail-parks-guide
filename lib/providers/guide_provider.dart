import 'package:flutter/foundation.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/services/guide_bot.dart';
import 'package:hail_parks_guide/services/trip_planner.dart';

/// Chat state for the guide tab. Answers come from the trained model that
/// runs on the device, so the guide works offline.
class GuideProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  Future<GuideBot>? _bot;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Answers [question] and returns what the screen should do next.
  Future<GuideAction> ask(String question) async {
    final text = question.trim();
    if (text.isEmpty) return GuideAction.none;
    _messages.add(ChatMessage(fromUser: true, text: text));
    notifyListeners();

    try {
      final reply = (await (_bot ??= GuideBot.load())).reply(text);
      _messages.add(reply.message);
      notifyListeners();
      return reply.action;
    } catch (e) {
      debugPrint('Guide error: $e');
      _bot = null; // try loading the model again next time
      _messages.add(const ChatMessage(
          fromUser: false, text: 'حدث خطأ في المرشد، حاول مرة أخرى', isError: true));
      notifyListeners();
      return GuideAction.none;
    }
  }

  /// Builds a trip plan from the planner answers; [shownText] is what the
  /// chat shows as the visitor's message.
  void planTrip(TripAnswers answers, {required String shownText}) {
    _messages
      ..add(ChatMessage(fromUser: true, text: shownText))
      ..add(ChatMessage(fromUser: false, plan: TripPlanner.plan(answers)));
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
