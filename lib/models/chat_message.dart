/// One stop in a trip plan.
class TripStop {
  final String placeId;
  final String time;
  final String note;

  const TripStop({required this.placeId, required this.time, required this.note});
}

class TripDay {
  final String label;
  final List<TripStop> stops;

  const TripDay({required this.label, required this.stops});
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
}

/// What the guide asks the screen to do after a reply.
enum GuideAction { none, openPlanner, openMap }

/// A message shown in the guide chat.
class ChatMessage {
  final bool fromUser;
  final String text;
  final TripPlan? plan; // set when the guide replied with a trip plan
  final List<String> placeIds; // places shown as cards under the reply
  final bool showPlants; // show plant cards under the reply
  final List<String> suggestions; // quick follow-up questions
  final bool isError;

  const ChatMessage({
    required this.fromUser,
    this.text = '',
    this.plan,
    this.placeIds = const [],
    this.showPlants = false,
    this.suggestions = const [],
    this.isError = false,
  });
}
