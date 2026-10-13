import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hail_parks_guide/data/guide_prompt.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/chat_message.dart';

/// Thrown with an Arabic message that can be shown to the user.
class GuideException implements Exception {
  final String message;
  const GuideException(this.message);
  @override
  String toString() => message;
}

/// Talks to the Claude API (Messages endpoint) for the AI guide.
///
/// The API key is passed at build time, never stored in the code. Put it in
/// api_keys.json (gitignored, see api_keys.example.json) and run:
///   flutter run --dart-define-from-file=api_keys.json
class ClaudeService {
  static const String _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  static const String _model = 'claude-opus-5-5';
  static final Uri _endpoint = Uri.parse('https://api.anthropic.com/v1/messages');

  static bool get hasApiKey => _apiKey.isNotEmpty;

  final http.Client _client = http.Client();
  final String _systemPrompt = buildGuideSystemPrompt();

  /// Conversation sent to the API. Assistant turns are stored exactly as
  /// returned (including thinking blocks), which the model requires.
  final List<Map<String, dynamic>> _history = [];

  void reset() => _history.clear();

  /// Sends a chat message and returns the guide's text reply.
  Future<String> ask(String question) async {
    final content = await _send(question, effort: 'low');
    return content
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join('\n')
        .trim();
  }

  /// Asks for a structured trip plan that only uses the app's place IDs.
  Future<TripPlan> planTrip(String request) async {
    final content = await _send(request, effort: 'medium', format: _planSchema());
    final text = content.firstWhere((block) => block['type'] == 'text',
        orElse: () => throw const GuideException('لم يصل رد من المرشد، حاول مرة أخرى'));
    return TripPlan.fromJson(jsonDecode(text['text'] as String) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> _send(
    String userText, {
    required String effort,
    Map<String, dynamic>? format,
  }) async {
    if (!hasApiKey) {
      throw const GuideException('لم يُضف مفتاح Claude API بعد');
    }

    final messages = [
      ..._history,
      {'role': 'user', 'content': userText},
    ];

    final body = {
      'model': _model,
      'max_tokens': 16000,
      'system': [
        // Cached: the system prompt is the same for every request.
        {'type': 'text', 'text': _systemPrompt, 'cache_control': {'type': 'ephemeral'}},
      ],
      'messages': messages,
      'output_config': {
        'effort': effort,
        if (format != null) 'format': format,
      },
      // If a safety classifier declines, retry on Anthropic's recommended model.
      'fallbacks': 'default',
    };

    final http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {
              'content-type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
              'anthropic-beta': 'server-side-fallback-2026-07-01',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(minutes: 3));
    } catch (_) {
      throw const GuideException('تعذر الاتصال بالإنترنت، تحقق من الاتصال وحاول مرة أخرى');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw GuideException(switch (response.statusCode) {
        401 => 'مفتاح Claude API غير صحيح',
        429 => 'المرشد مشغول الآن، حاول بعد قليل',
        529 || 500 || 503 => 'خدمة المرشد غير متاحة مؤقتًا، حاول بعد قليل',
        _ => 'حدث خطأ (${response.statusCode})، حاول مرة أخرى',
      });
    }

    if (data['stop_reason'] == 'refusal') {
      throw const GuideException('لا يستطيع المرشد الإجابة عن هذا الطلب، جرّب سؤالًا آخر');
    }

    final content = [
      for (final block in data['content'] as List) block as Map<String, dynamic>,
    ];
    // Only add the turn once it succeeded, so a failed request leaves no gap.
    _history
      ..add({'role': 'user', 'content': userText})
      ..add({'role': 'assistant', 'content': content});
    return content;
  }

  /// JSON schema for trip plans; place_id is limited to real place IDs.
  Map<String, dynamic> _planSchema() {
    Map<String, dynamic> object(Map<String, dynamic> props) => {
          'type': 'object',
          'properties': props,
          'required': props.keys.toList(),
          'additionalProperties': false,
        };

    return {
      'type': 'json_schema',
      'schema': object({
        'title': {'type': 'string'},
        'summary': {'type': 'string'},
        'days': {
          'type': 'array',
          'items': object({
            'label': {'type': 'string'},
            'stops': {
              'type': 'array',
              'items': object({
                'place_id': {
                  'type': 'string',
                  'enum': [for (final p in HailData.places) p.id],
                },
                'time': {'type': 'string'},
                'note': {'type': 'string'},
              }),
            },
          }),
        },
        'tips': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      }),
    };
  }
}
