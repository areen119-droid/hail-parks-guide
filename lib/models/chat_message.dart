/// One stop in an AI trip plan.
class TripStop {
  final String placeId;
  final String time;
  final String note;

  const TripStop({required this.placeId, required this.time, required this.note});

  factory TripStop.fromJson(Map<String, dynamic> json) => TripStop(
        placeId: json['place_id'] as String,
        time: json['time'] as String,
        note: json['note'] as String,
      );
}

class TripDay {
  final String label;
  final List<TripStop> stops;

  const TripDay({required this.label, required this.stops});

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
        label: json['label'] as String,
        stops: [
          for (final s in json['stops'] as List)
            TripStop.fromJson(s as Map<String, dynamic>),
        ],
      );
}

class TripPlan {
  final String title;
  final String summary;
  final List<TripDay> days;
  final List<String> tips;

  const TripPlan({
    required this.title,
    required this.summary,
    required this.days,
    required this.tips,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
        title: json['title'] as String,
        summary: json['summary'] as String,
        days: [
          for (final d in json['days'] as List)
            TripDay.fromJson(d as Map<String, dynamic>),
        ],
        tips: [for (final t in json['tips'] as List) t as String],
      );
}

/// A message shown in the guide chat.
class ChatMessage {
  final bool fromUser;
  final String text;
  final TripPlan? plan; // set when the assistant replied with a trip plan
  final bool isError;

  const ChatMessage({
    required this.fromUser,
    this.text = '',
    this.plan,
    this.isError = false,
  });
}
