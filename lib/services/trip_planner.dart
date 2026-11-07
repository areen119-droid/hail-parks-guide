import 'package:hail_parks_guide/core/utils/helpers.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/chat_message.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// The visitor's answers from the planner questions.
class TripAnswers {
  final String duration; // نصف يوم / يوم كامل / يومان / ثلاثة أيام
  final String companion; // عائلة مع أطفال / أصدقاء / بمفردي / كبار السن
  final Set<String> interests;
  final String time; // الصباح / المساء / لا يهم
  final String notes;

  const TripAnswers({
    required this.duration,
    required this.companion,
    required this.interests,
    required this.time,
    this.notes = '',
  });
}

/// Builds a trip plan from the visitor's answers using simple rules on the
/// app's own data. Each day has one activity (a different kind of place than
/// the day before), lunch, coffee and dinner, spread from morning to evening.
class TripPlanner {
  static const _familyTag = 'مناسب للعائلات';
  static const _farKm = 40.0;

  // Places that suit each interest, besides whole categories.
  static const _photoSpots = ['hatem_view', 'samra', 'aarif', 'jubbah', 'aja', 'jaww', 'nafud'];
  static const _walkingSpots = ['samra_park', 'prince_saud_park', 'jaww', 'mashar'];
  static const _plantSpots = ['aja', 'iqdah', 'mashar', 'jaww'];
  static const _kidsSpots = ['samra_park', 'prince_saud_park', 'iqdah', 'al_wurud_park', 'al_salam_park'];
  static const _sunsetSpots = ['hatem_view', 'samra', 'aarif'];
  static const _ruggedSpots = ['jaww', 'hutaymah', 'shuwaymis', 'nafud'];
  // The best-known places, best first. With one activity a day, these win
  // over equally matching places that are merely closer.
  static const _featured = ['samra_park', 'prince_saud_park', 'jubbah', 'aja', 'hatem_view',
      'qishla', 'iqdah', 'mashar', 'aarif', 'museum', 'samra', 'al_salam_park'];

  static TripPlan plan(TripAnswers answers) {
    final days = switch (answers.duration) {
      'يومان' => 2,
      'ثلاثة أيام' => 3,
      _ => 1,
    };
    final halfDay = answers.duration == 'نصف يوم';
    final withKids = answers.companion == 'عائلة مع أطفال';
    final elderly = answers.companion == 'كبار السن';
    final familyFood = withKids || elderly;
    final noCar = RegExp(r'(لا|ما|بدون|مافي|ماعند)\S*\s*\S*\s*سيار').hasMatch(answers.notes);

    // 1. Score every sightseeing place by how many interests it matches.
    final scores = <PlaceModel, int>{};
    for (final place in HailData.places) {
      if (place.category.isFood || !place.hasLocation) continue;
      if (noCar && _km(place) > 10) continue;
      if (elderly && _ruggedSpots.contains(place.id)) continue;
      if (halfDay && _km(place) > _farKm) continue;
      var score = _interestScore(place, answers.interests);
      if (withKids && _kidsSpots.contains(place.id)) score += 2;
      if (score > 0) scores[place] = score;
    }
    int rank(PlaceModel p) {
      final i = _featured.indexOf(p.id);
      return i == -1 ? _featured.length : i;
    }
    int byScore(PlaceModel a, PlaceModel b) {
      final s = scores[b]!.compareTo(scores[a]!);
      if (s != 0) return s;
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : _km(a).compareTo(_km(b));
    }

    final ranked = scores.keys.toList()..sort(byScore);

    // 2. One activity a day. Day one stays near the city, and each day tries
    // a different kind of place than the day before (not park after park).
    final foodUses = <String, int>{};
    final planDays = <TripDay>[];
    PlaceCategory? lastCategory;
    for (var d = 0; d < days; d++) {
      final options = ranked.where((p) => d > 0 || _km(p) <= _farKm).toList();
      if (options.isEmpty) break;
      final activity = options.firstWhere((p) => p.category != lastCategory,
          orElse: () => options.first);
      ranked.remove(activity);
      lastCategory = activity.category;
      planDays.add(TripDay(
        label: days == 1 ? 'جدول اليوم' : 'اليوم ${_dayName(d)}',
        stops: _day(activity, answers.time,
            halfDay: halfDay, familyFood: familyFood, withKids: withKids, foodUses: foodUses),
      ));
    }

    return TripPlan(
      title: 'رحلة ${answers.duration} في حائل',
      summary: _summary(answers),
      days: planDays,
      tips: _tips(planDays, answers, withKids: withKids, noCar: noCar),
    );
  }

  static double _km(PlaceModel p) => distanceKm(
      HailData.hailLatitude, HailData.hailLongitude, p.latitude!, p.longitude!);

  static int _interestScore(PlaceModel place, Set<String> interests) {
    if (interests.isEmpty || interests.every((i) => i == 'المطاعم والمقاهي')) {
      return 1; // no preference: everything counts
    }
    var score = 0;
    for (final interest in interests) {
      final matches = switch (interest) {
        'الحدائق' => place.category == PlaceCategory.park,
        'الطبيعة والجبال' => place.category == PlaceCategory.nature,
        'التراث والتاريخ' => place.category == PlaceCategory.heritage,
        'التصوير' => _photoSpots.contains(place.id),
        'المشي' => _walkingSpots.contains(place.id),
        'النباتات' => place.category == PlaceCategory.park || _plantSpots.contains(place.id),
        _ => false,
      };
      if (matches) score++;
    }
    return score;
  }

  /// One day around [activity]: lunch, coffee and dinner at set times, with
  /// enough time at each stop. A half day has the activity, coffee and one meal.
  static List<TripStop> _day(PlaceModel activity, String time,
      {required bool halfDay,
      required bool familyFood,
      required bool withKids,
      required Map<String, int> foodUses}) {
    final today = <String>{};
    _Stop meal(int minutes, PlaceCategory category, String role) => _Stop(
        minutes, _pickFood(category, activity, today, familyFood, foodUses), role);
    final see = _Stop(0, activity, '');
    final far = _km(activity) > _farKm;
    final evening = time == 'المساء' || _sunsetSpots.contains(activity.id);

    final stops = halfDay
        ? (time == 'الصباح'
            ? [see.at(9 * 60), meal(11 * 60 + 30, PlaceCategory.cafe, 'قهوة'),
               meal(13 * 60, PlaceCategory.restaurant, 'غداء')]
            : [see.at(16 * 60 + 30), meal(18 * 60 + 30, PlaceCategory.cafe, 'قهوة'),
               meal(20 * 60, PlaceCategory.restaurant, 'عشاء')])
        : far
            // Far places take most of the day: leave early, eat back in town.
            ? [see.at(8 * 60 + 30), meal(14 * 60, PlaceCategory.restaurant, 'غداء'),
               meal(17 * 60, PlaceCategory.cafe, 'قهوة'),
               meal(20 * 60 + 30, PlaceCategory.restaurant, 'عشاء')]
            : evening
                // Activity late in the afternoon, in time for sunset.
                ? [meal(13 * 60 + 30, PlaceCategory.restaurant, 'غداء'),
                   meal(15 * 60 + 30, PlaceCategory.cafe, 'قهوة'), see.at(17 * 60),
                   meal(20 * 60 + 30, PlaceCategory.restaurant, 'عشاء')]
                : [see.at(time == 'الصباح' ? 9 * 60 : 10 * 60),
                   meal(13 * 60 + 30, PlaceCategory.restaurant, 'غداء'),
                   meal(17 * 60, PlaceCategory.cafe, 'قهوة'),
                   meal(20 * 60 + 30, PlaceCategory.restaurant, 'عشاء')];

    return [
      for (final stop in stops)
        if (stop.place != null)
          TripStop(
            placeId: stop.place!.id,
            time: _clock(stop.minutes),
            note: _note(stop.place!,
                role: stop.role, withKids: withKids, nearSunset: stop.minutes >= 16 * 60),
          ),
    ];
  }

  /// The restaurant or café to use near [near]: one not used yet on the trip
  /// if possible (repeats only when the list runs out), never twice a day.
  static PlaceModel? _pickFood(PlaceCategory category, PlaceModel near, Set<String> today,
      bool familyOnly, Map<String, int> uses) {
    final options = HailData.places
        .where((p) =>
            p.category == category &&
            p.hasLocation &&
            !today.contains(p.id) &&
            (!familyOnly || p.facilities.contains(_familyTag)))
        .toList();
    if (options.isEmpty) return null;
    double km(PlaceModel p) =>
        distanceKm(near.latitude!, near.longitude!, p.latitude!, p.longitude!);
    options.sort((a, b) {
      final byUse = (uses[a.id] ?? 0).compareTo(uses[b.id] ?? 0);
      return byUse != 0 ? byUse : km(a).compareTo(km(b));
    });
    final pick = options.first;
    today.add(pick.id);
    uses[pick.id] = (uses[pick.id] ?? 0) + 1;
    return pick;
  }

  static String _note(PlaceModel place,
      {required String role, required bool withKids, required bool nearSunset}) {
    final firstSentence = place.description.split(RegExp(r'[.،]')).first.trim();
    if (role.isNotEmpty) return '$role: $firstSentence';
    final extras = <String>[
      if (_km(place) > _farKm) 'على بعد حوالي ${_km(place).round()} كم، خصص لها وقتًا كافيًا',
      if (withKids && place.facilities.contains('ألعاب أطفال')) 'فيه ألعاب للأطفال',
      if (nearSunset && _sunsetSpots.contains(place.id)) 'في وقت مناسب لمشاهدة الغروب',
    ];
    return [firstSentence, ...extras].join('. ');
  }

  static String _summary(TripAnswers a) {
    final who = switch (a.companion) {
      'عائلة مع أطفال' => 'للعائلة مع الأطفال',
      'أصدقاء' => 'للأصدقاء',
      'كبار السن' => 'لكبار السن',
      _ => 'لزيارة فردية',
    };
    final interests = a.interests.isEmpty ? 'أبرز أماكن حائل' : a.interests.join('، ');
    return 'خطة مناسبة $who، تركز على $interests.';
  }

  static List<String> _tips(List<TripDay> days, TripAnswers answers,
      {required bool withKids, required bool noCar}) {
    final ids = {for (final d in days) for (final s in d.stops) s.placeId};
    final places = HailData.places.where((p) => ids.contains(p.id));
    return [
      if (places.any((p) => _km(p) > _farKm))
        'بعض الأماكن خارج المدينة، تحتاج سيارة وانطلق مبكرًا.',
      if (noCar) 'اخترنا أماكن داخل المدينة لأنك بدون سيارة، ويمكنك التنقل بتطبيقات التوصيل.',
      if (places.any((p) => p.category == PlaceCategory.nature))
        'في الأماكن الطبيعية خذ ماء كافيًا وتجنب وقت الظهر في الصيف.',
      if (withKids) 'جميع المطاعم والمقاهي في الخطة مناسبة للعائلات.',
      'تأكد من أوقات العمل في خرائط جوجل قبل الذهاب.',
    ];
  }

  static String _clock(int minutes) {
    final h24 = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final period = h24 < 12 ? 'صباحًا' : 'مساءً';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${_arabicDigits('$h12:${m.toString().padLeft(2, '0')}')} $period';
  }

  static String _arabicDigits(String s) => s.replaceAllMapped(
      RegExp(r'\d'), (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)]);

  static String _dayName(int i) => const ['الأول', 'الثاني', 'الثالث'][i];
}

/// A planned stop before it becomes a [TripStop]; [place] is null when no
/// suitable restaurant or café exists.
class _Stop {
  final int minutes;
  final PlaceModel? place;
  final String role; // غداء / قهوة / عشاء, empty for the activity
  const _Stop(this.minutes, this.place, this.role);

  _Stop at(int minutes) => _Stop(minutes, place, role);
}
