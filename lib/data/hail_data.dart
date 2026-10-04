import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';

/// Parks and plants shown in the app. Stored here until they move to Firebase.
class HailData {
  // TODO: replace these example parks with the real parks of Hail.
  static const List<ParkModel> parks = [
    ParkModel(
      id: 'park_1',
      name: 'حديقة ١',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
      openingHours: '٤ م - ١١ م',
      facilities: ['مواقف سيارات', 'ألعاب أطفال', 'جلسات عائلية'],
    ),
    ParkModel(
      id: 'park_2',
      name: 'حديقة ٢',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
      openingHours: '٤ م - ١١ م',
      facilities: ['ممشى', 'دورات مياه'],
    ),
    ParkModel(
      id: 'park_3',
      name: 'حديقة ٣',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
    ),
  ];

  static final List<Plant> plants = [
    Plant(
      id: 'sidr',
      name: 'السدر',
      description: 'شجرة صحراوية معمرة تتحمل الجفاف، وتشتهر بثمر النبق وعسل السدر.',
      image: '',
    ),
    Plant(
      id: 'talh',
      name: 'الطلح',
      description: 'شجرة شوكية من الأكاسيا تنتشر في الأودية وتوفر الظل للمراعي.',
      image: '',
    ),
    Plant(
      id: 'arta',
      name: 'الأرطى',
      description: 'شجيرة رملية تثبت الكثبان، وتنمو في نفود حائل.',
      image: '',
    ),
    Plant(
      id: 'rimth',
      name: 'الرمث',
      description: 'شجيرة رعوية تتحمل الملوحة والجفاف، وتنتشر في السهول.',
      image: '',
    ),
  ];
}
