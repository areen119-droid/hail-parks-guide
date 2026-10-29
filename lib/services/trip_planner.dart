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
/// app's own data: match interests, respect who's coming, keep far places
/// for their own day, order stops by distance, add meals, end at sunset spots.
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
    final foodie = answers.interests.contains('المطاعم والمقاهي');

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
    int byScore(PlaceModel a, PlaceModel b) {
      final s = scores[b]!.compareTo(scores[a]!);
      return s != 0 ? s : _km(a).compareTo(_km(b));
    }

    final near = scores.keys.where((p) => _km(p) <= _farKm).toList()..sort(byScore);
    final far = scores.keys.where((p) => _km(p) > _farKm).toList()..sort(byScore);

    // 2. Fill each day: far places get their own day after day one.
    final perDay = halfDay ? 2 : 3;
    final used = <String>{};
    final planDays = <TripDay>[];
    for (var d = 0; d < days; d++) {
      final picks = <PlaceModel>[];
      if (d > 0 && far.isNotEmpty) {
        picks.add(far.removeAt(0));
      } else {
        while (picks.length < perDay && near.isNotEmpty) {
          picks.add(near.removeAt(0));
        }
      }
      if (picks.isEmpty) break;
      used.addAll(picks.map((p) => p.id));

      final ordered = _orderStops(picks);
      final stops = _withMeals(ordered, used,
          familyFood: familyFood, halfDay: halfDay, foodie: foodie);
      planDays.add(TripDay(
        label: days == 1 ? 'جدول اليوم' : 'اليوم ${_dayName(d)}',
        stops: _timed(stops, answers.time, withKids: withKids),
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

  /// Nearest-first from the city center, with sunset spots moved to the end.
  static List<PlaceModel> _orderStops(List<PlaceModel> places) {
    final remaining = [...places];
    final ordered = <PlaceModel>[];
    var lat = HailData.hailLatitude, lon = HailData.hailLongitude;
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => distanceKm(lat, lon, a.latitude!, a.longitude!)
          .compareTo(distanceKm(lat, lon, b.latitude!, b.longitude!)));
      final next = remaining.removeAt(0);
      ordered.add(next);
      lat = next.latitude!;
      lon = next.longitude!;
    }
    final sunset = ordered.where((p) => _sunsetSpots.contains(p.id)).toList();
    return [...ordered.where((p) => !_sunsetSpots.contains(p.id)), ...sunset];
  }

  /// Adds a meal stop (and a coffee stop on full days or for food lovers).
  static List<PlaceModel> _withMeals(List<PlaceModel> stops, Set<String> used,
      {required bool familyFood, required bool halfDay, required bool foodie}) {
    PlaceModel? nearestFood(PlaceCategory category, PlaceModel near) {
      final options = HailData.places.where((p) =>
          p.category == category &&
          p.hasLocation &&
          !used.contains(p.id) &&
          (!familyFood || p.facilities.contains(_familyTag)));
      if (options.isEmpty) return null;
      return options.reduce((a, b) =>
          distanceKm(near.latitude!, near.longitude!, a.latitude!, a.longitude!) <=
                  distanceKm(near.latitude!, near.longitude!, b.latitude!, b.longitude!)
              ? a
              : b);
    }

    final result = [...stops];
    final mealAfter = halfDay ? result.length : (result.length / 2).ceil();
    final restaurant = nearestFood(PlaceCategory.restaurant, result[mealAfter - 1]);
    if (restaurant != null) {
      result.insert(mealAfter, restaurant);
      used.add(restaurant.id);
    }
    if (!halfDay || foodie) {
      final cafe = nearestFood(PlaceCategory.cafe, result.last);
      if (cafe != null) {
        // Coffee before the sunset stop if there is one, otherwise at the end.
        final sunsetIndex = result.indexWhere((p) => _sunsetSpots.contains(p.id));
        result.insert(sunsetIndex == -1 ? result.length : sunsetIndex, cafe);
        used.add(cafe.id);
      }
    }
    return result;
  }

  static List<TripStop> _timed(List<PlaceModel> stops, String time,
      {required bool withKids}) {
    var minutes = switch (time) {
      'الصباح' => 8 * 60,
      'المساء' => 15 * 60,
      _ => 9 * 60,
    };
    final result = <TripStop>[];
    for (final place in stops) {
      result.add(TripStop(
        placeId: place.id,
        time: _clock(minutes),
        note: _note(place, withKids: withKids, nearSunset: minutes >= 16 * 60),
      ));
      final far = _km(place) > _farKm;
      minutes += place.category.isFood ? 75 : (far ? 240 : 105);
    }
    return result;
  }

  static String _note(PlaceModel place,
      {required bool withKids, required bool nearSunset}) {
    final firstSentence = place.description.split(RegExp(r'[.،]')).first.trim();
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
