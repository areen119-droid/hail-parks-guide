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

  test('two-day nature trip gives a far place its own day', () {
    final plan = TripPlanner.plan(const TripAnswers(
      duration: 'يومان',
      companion: 'أصدقاء',
      interests: {'الطبيعة والجبال', 'التراث والتاريخ'},
      time: 'الصباح',
    ));
    expect(plan.days, hasLength(2));
    final day2Sights = plan.days[1].stops
        .map((s) => place(s.placeId))
        .where((p) => !p.category.isFood);
    expect(day2Sights, hasLength(1));
    expect(plan.days.first.stops.first.time, contains('صباحًا'));
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
