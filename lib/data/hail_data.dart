import 'package:hail_parks_guide/models/park_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
import 'package:hail_parks_guide/models/user_model.dart';

/// All the app's content. Everything is hard-coded here (no backend).
class HailData {
  /// Center of Hail city, used as the map's starting point.
  static const double hailLatitude = 27.5219;
  static const double hailLongitude = 41.6907;

  /// The app's single account.
  static const UserModel currentUser = UserModel(
    name: 'زائر حائل',
    username: 'hail_visitor',
    city: 'حائل',
    bio: 'أحب استكشاف حدائق حائل ونباتاتها',
  );

  // TODO: replace these example parks with the real parks and coordinates.
  static const List<ParkModel> parks = [
    ParkModel(
      id: 'park_1',
      name: 'حديقة ١',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
      latitude: 27.5236,
      longitude: 41.6966,
      openingHours: '٤ م - ١١ م',
      facilities: ['مواقف سيارات', 'ألعاب أطفال', 'جلسات عائلية'],
    ),
    ParkModel(
      id: 'park_2',
      name: 'حديقة ٢',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
      latitude: 27.5090,
      longitude: 41.7060,
      openingHours: '٤ م - ١١ م',
      facilities: ['ممشى', 'دورات مياه'],
    ),
    ParkModel(
      id: 'park_3',
      name: 'حديقة ٣',
      description: 'وصف الحديقة: ما يميزها وما يمكن للزائر أن يفعله فيها.',
      location: 'حائل',
      latitude: 27.5400,
      longitude: 41.6800,
    ),
  ];

  static const List<Plant> plants = [
    Plant(
      id: 'sidr',
      name: 'السدر',
      scientificName: 'Ziziphus spina-christi',
      type: 'شجرة برية محلية',
      description:
          'شجرة صحراوية معمرة تتحمل الجفاف والحرارة، أغصانها شوكية وأوراقها صغيرة لامعة. '
          'تشتهر بثمر النبق، ويتغذى النحل على أزهارها فينتج عسل السدر المعروف.',
      image: 'assets/plants/sidr.jpg',
    ),
    Plant(
      id: 'talh',
      name: 'الطلح',
      scientificName: 'Acacia gerrardii',
      type: 'شجرة برية محلية',
      description:
          'شجرة شوكية من فصيلة الأكاسيا تنتشر في الأودية والشعاب. '
          'توفر الظل للمسافرين والمواشي، وتُعد من أهم أشجار المراعي في المنطقة.',
      image: 'assets/plants/talh.jpg',
    ),
    Plant(
      id: 'arta',
      name: 'الأرطى',
      scientificName: 'Calligonum comosum',
      type: 'شجيرة برية محلية',
      description:
          'شجيرة رملية بأغصان رفيعة خضراء، تنمو في الكثبان الرملية مثل نفود حائل. '
          'تساعد جذورها على تثبيت الرمال، وتزهر في الربيع.',
      image: 'assets/plants/arta.jpg',
    ),
    Plant(
      id: 'rimth',
      name: 'الرمث',
      scientificName: 'Haloxylon salicornicum',
      type: 'شجيرة برية محلية',
      description:
          'شجيرة رعوية تتحمل الملوحة والجفاف، وتنتشر في السهول والروضات. '
          'من أهم النباتات التي تتغذى عليها الإبل.',
      image: 'assets/plants/ramth.jpg',
    ),
    Plant(
      id: 'qaysoom',
      name: 'القيصوم',
      scientificName: 'Achillea fragrantissima',
      type: 'شجيرة برية محلية',
      description:
          'شجيرة عطرية ذات أوراق رمادية ورائحة قوية مميزة، تنمو في الأودية والروضات. '
          'استُخدمت تقليديًا في الطب الشعبي.',
      image: 'assets/plants/qaysoom.jpg',
    ),
    Plant(
      id: 'sheeh',
      name: 'الشيح',
      scientificName: 'Artemisia sieberi',
      type: 'شجيرة برية محلية',
      description:
          'شجيرة صغيرة عطرية بأوراق رمادية دقيقة ورائحة نفاذة، تنتشر في السهول. '
          'من النباتات المعروفة في البيئة الصحراوية.',
      image: 'assets/plants/sheeh.png',
    ),
    Plant(
      id: 'olive',
      name: 'الزيتون',
      scientificName: 'Olea europaea',
      type: 'شجرة مثمرة',
      description:
          'شجرة دائمة الخضرة طويلة العمر تتحمل الجفاف، تُزرع في المزارع والحدائق. '
          'ثمارها تؤكل ويُستخرج منها زيت الزيتون.',
      image: 'assets/plants/oliveTree.jpg',
    ),
    Plant(
      id: 'yellow_bells',
      name: 'الجرس الأصفر',
      scientificName: 'Tecoma stans',
      type: 'نبات زينة',
      description:
          'شجيرة زينة بأزهار صفراء على شكل جرس، تتحمل الحرارة. '
          'تُزرع كثيرًا في الحدائق والشوارع.',
      image: 'assets/plants/yellowBells.jpg',
    ),
    Plant(
      id: 'wunka',
      name: 'الونكة',
      scientificName: 'Catharanthus roseus',
      type: 'نبات زينة',
      description:
          'نبات زينة بأزهار وردية أو بيضاء يزهر معظم أيام السنة ويتحمل الحر. '
          'يُزرع في أحواض الحدائق، وهو نبات سام لا يؤكل.',
      image: 'assets/plants/wunka.png',
    ),
  ];

  static const List<String> facts = [
    'تقع حائل في شمال المملكة العربية السعودية بين جبلي أجا وسلمى.',
    'الفنون الصخرية في جبة والشويمس بمنطقة حائل مسجلة في قائمة التراث العالمي لليونسكو.',
    'تُعرف حائل بمدينة حاتم الطائي المشهور بالكرم.',
    'يقام رالي حائل الدولي سنويًا في رمال صحراء النفود.',
    'قلعة أعيرف من أبرز المعالم التاريخية في مدينة حائل.',
    'تمتد صحراء النفود الكبير شمال مدينة حائل بكثبانها الرملية الحمراء.',
  ];
}
