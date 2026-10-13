import 'package:flutter/foundation.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/services/claude_service.dart';

/// Chat state for the AI guide tab.
class GuideProvider extends ChangeNotifier {
  final ClaudeService _service = ClaudeService();
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  bool get hasApiKey => ClaudeService.hasApiKey;

  Future<void> ask(String question) =>
      _run(question, () async => ChatMessage(fromUser: false, text: await _service.ask(question)));

  /// [request] is the full planner request; [shownText] is what the chat shows.
  Future<void> planTrip(String request, {required String shownText}) => _run(
        shownText,
        () async => ChatMessage(fromUser: false, plan: await _service.planTrip(request)),
      );

  void clear() {
    _messages.clear();
    _service.reset();
    notifyListeners();
  }

  Future<void> _run(String shownText, Future<ChatMessage> Function() call) async {
    if (_loading || shownText.trim().isEmpty) return;
    _messages.add(ChatMessage(fromUser: true, text: shownText.trim()));
    _loading = true;
    notifyListeners();
    try {
      _messages.add(await call());
    } on GuideException catch (e) {
      _messages.add(ChatMessage(fromUser: false, text: e.message, isError: true));
    } catch (e) {
      debugPrint('Guide error: $e');
      _messages.add(const ChatMessage(
          fromUser: false, text: 'حدث خطأ غير متوقع، حاول مرة أخرى', isError: true));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
