import 'package:flutter_test/flutter_test.dart';
import 'package:hail_parks_guide/data/hail_data.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/services/trip_planner.dart';

PlaceModel place(String id) => HailData.places.firstWhere((p) => p.id == id);

void main() {
  test('family day: kids places, family-friendly food only', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'يوم كامل',
      companion: 'عائلة مع أطفال',
      interests: {'الحدائق'},
      time: 'المساء',
    ));
    final ids = plan.days.single.stops.map((s) => s.placeId).toList();
    expect(ids, contains('samra_park'));
    for (final id in ids) {
      final p = place(id);
      if (p.category.isFood) {
        expect(p.facilities, contains('مناسب للعائلات'), reason: '$id is not family-friendly');
      }
    }
    expect(ids.toSet().length, ids.length, reason: 'no repeated stops');
  });

  test('each full day: one activity, lunch and dinner, a café, ending in the evening', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'ثلاثة أيام',
      companion: 'أصدقاء',
      interests: {'الحدائق', 'الطبيعة والجبال', 'التراث والتاريخ'},
      time: 'لا يهم',
    ));
    expect(plan.days, hasLength(3));
    for (final day in plan.days) {
      final places = day.stops.map((s) => place(s.placeId)).toList();
      expect(places.where((p) => !p.category.isFood), hasLength(1));
      expect(places.where((p) => p.category == PlaceCategory.restaurant), hasLength(2));
      expect(places.where((p) => p.category == PlaceCategory.cafe), hasLength(1));
      expect(day.stops.last.time, contains('مساءً'));
      expect(day.stops.last.note, startsWith('عشاء'));
    }
    final activities = [
      for (final day in plan.days)
        day.stops.map((s) => place(s.placeId)).firstWhere((p) => !p.category.isFood),
    ];
    expect(activities.map((p) => p.id).toSet(), hasLength(3), reason: 'no repeated activity');
    for (var i = 1; i < activities.length; i++) {
      expect(activities[i].category, isNot(activities[i - 1].category),
          reason: 'consecutive days should not both be ${activities[i].category.name}');
    }
  });

  test('two-day trip: morning start, a far place can fill day two', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'يومان',
      companion: 'أصدقاء',
      interests: {'الطبيعة والجبال', 'التراث والتاريخ'},
      time: 'الصباح',
    ));
    expect(plan.days, hasLength(2));
    expect(plan.days.first.stops.first.time, contains('صباحًا'));
    final day1Activity =
        plan.days.first.stops.map((s) => place(s.placeId)).firstWhere((p) => !p.category.isFood);
    expect(['jubbah', 'fayd', 'shuwaymis', 'nafud', 'hutaymah'], isNot(contains(day1Activity.id)),
        reason: 'day one stays near the city');
  });

  test('half day: activity, coffee and one meal', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'نصف يوم',
      companion: 'بمفردي',
      interests: {'الحدائق'},
      time: 'المساء',
    ));
    final places = plan.days.single.stops.map((s) => place(s.placeId)).toList();
    expect(places, hasLength(3));
    expect(places.where((p) => p.category == PlaceCategory.restaurant), hasLength(1));
  });

  test('no car keeps everything inside the city', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'ثلاثة أيام',
      companion: 'بمفردي',
      interests: {'التراث والتاريخ'},
      time: 'لا يهم',
      notes: 'لا نملك سيارة',
    ));
    for (final day in plan.days) {
      for (final stop in day.stops) {
        final p = place(stop.placeId);
        if (!p.category.isFood) {
          expect(['jubbah', 'fayd', 'shuwaymis'], isNot(contains(p.id)));
        }
      }
    }
  });

  test('every plan has at least one stop for any answers', () {
    for (final duration in ['نصف يوم', 'يوم كامل', 'يومان', 'ثلاثة أيام']) {
      for (final companion in ['عائلة مع أطفال', 'أصدقاء', 'بمفردي', 'كبار السن']) {
        final plan = TripPlanner.plan(TripAnswers(
          duration: duration,
          companion: companion,
          interests: const {},
          time: 'لا يهم',
        ));
        expect(plan.days, isNotEmpty, reason: '$duration / $companion');
        expect(plan.days.first.stops, isNotEmpty);
      }
    }
  });
}
