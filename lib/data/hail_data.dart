import 'package:hail_parks_guide/models/place_model.dart';
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

  // Parks without a known exact location have no coordinates yet:
  // they are listed in the app but not shown on the map.
  static const List<PlaceModel> places = [
    // Parks
    PlaceModel(
      id: 'prince_saud_park',
      name: 'منتزه الأمير سعود بن عبدالمحسن',
      category: PlaceCategory.park,
      description:
          'من أشهر منتزهات حائل، تبلغ مساحته نحو 350 ألف متر مربع. يضم مسطحات '
          'خضراء ونخيلًا وأشجارًا متنوعة وبحيرات وشلالات، إلى جانب مطاعم ومقاهٍ.',
      location: 'مدينة حائل',
      facilities: ['مسطحات خضراء', 'بحيرات وشلالات', 'مطاعم ومقاهٍ'],
    ),
    PlaceModel(
      id: 'al_salam_park',
      name: 'حديقة السلام',
      category: PlaceCategory.park,
      description: 'حديقة في مدينة حائل.',
      location: 'مدينة حائل',
    ),
    PlaceModel(
      id: 'al_wurud_park',
      name: 'منتزه الورود',
      category: PlaceCategory.park,
      description: 'منتزه في حي الورود بالقرب من بحيرة أجا.',
      location: 'حي الورود، حائل',
    ),

    // Mountains and nature
    PlaceModel(
      id: 'aja',
      name: 'جبال أجا',
      category: PlaceCategory.nature,
      description:
          'سلسلة جبلية غرب مدينة حائل يتراوح ارتفاعها بين 900 و1550 مترًا فوق '
          'سطح البحر، وتنتشر فيها أشجار الطلح. وجهة محبوبة للمشي والتصوير '
          'والتخييم ومراقبة النجوم، وهي مع جبال سلمى رمز لمنطقة حائل.',
      location: 'غرب مدينة حائل',
      latitude: 27.5043,
      longitude: 41.5571,
      image: 'assets/places/aja_1.jpg',
      gallery: [
        'assets/places/aja_1.jpg',
        'assets/places/aja_2.jpg',
        'assets/places/aja_3.jpg',
      ],
    ),
    PlaceModel(
      id: 'salma',
      name: 'جبال سلمى',
      category: PlaceCategory.nature,
      description:
          'السلسلة الجبلية التوأم لجبال أجا، تقع جنوب شرق حائل في محافظة '
          'الشنان، ويرتبط اسماهما معًا في تراث المنطقة. تحيط بها معالم بركانية '
          'ضمن جيوبارك سلمى.',
      location: 'محافظة الشنان',
      latitude: 27.1532,
      longitude: 42.1874,
    ),
    PlaceModel(
      id: 'samra',
      name: 'جبل السمراء',
      category: PlaceCategory.nature,
      description:
          'جبل داكن الصخور في مدينة حائل، تطل قمته على المدينة وجبال أجا، '
          'ويُعد من أجمل أماكن مشاهدة الغروب. على سفحه منتزه السمراء.',
      location: 'مدينة حائل',
      latitude: 27.5228,
      longitude: 41.7356,
      image: 'assets/places/samra_1.jpg',
    ),
    PlaceModel(
      id: 'jaww',
      name: 'شعيب جو',
      category: PlaceCategory.nature,
      description:
          'وادٍ بين جبال أجا شمال غرب حائل، تجري فيه السيول في مواسم الأمطار '
          'وتحيط به الأشجار والصخور. أدرجه برنامج جودة الحياة ضمن المعالم '
          'السياحية البارزة في المملكة.',
      location: 'جبال أجا، شمال غرب حائل',
      latitude: 27.7507,
      longitude: 41.4913,
      image: 'assets/places/jaww_1.jpg',
      gallery: ['assets/places/jaww_1.jpg', 'assets/places/jaww_2.jpg'],
    ),
    PlaceModel(
      id: 'nafud',
      name: 'صحراء النفود الكبير',
      category: PlaceCategory.nature,
      description:
          'صحراء من الكثبان الرملية الحمراء تمتد شمال حائل، تشتهر بالرحلات '
          'البرية ومراقبة النجوم، وتستضيف رالي حائل الدولي.',
      location: 'شمال حائل',
      latitude: 28.4705,
      longitude: 41.1843,
      image: 'assets/places/nafud_1.jpg',
    ),
    PlaceModel(
      id: 'hutaymah',
      name: 'فوهة الهتيمة',
      category: PlaceCategory.nature,
      description:
          'فوهة بركانية قرب قرية طابة جنوب شرق حائل، يبلغ قطرها نحو 1.2 كم '
          'وعمقها أكثر من 100 متر، وتقع ضمن حرة الهتيمة في جيوبارك سلمى.',
      location: 'قرب طابة، محافظة الشنان',
      latitude: 26.9882,
      longitude: 42.2473,
    ),

    // Heritage and history
    PlaceModel(
      id: 'jubbah',
      name: 'جبة والرسوم الصخرية',
      category: PlaceCategory.heritage,
      description:
          'رسوم ونقوش صخرية في جبل أم سنمان قرب بلدة جبة وسط صحراء النفود، '
          'يعود بعضها إلى أكثر من 10 آلاف عام وتصوّر الإبل والوعول ومشاهد '
          'الصيد. مسجلة في قائمة التراث العالمي لليونسكو.',
      location: 'جبة، شمال غرب حائل',
      latitude: 28.0050,
      longitude: 40.9154,
      image: 'assets/places/jubbah_1.jpg',
      gallery: [
        'assets/places/jubbah_1.jpg',
        'assets/places/jubbah_2.jpg',
        'assets/places/jubbah_3.jpg',
      ],
    ),
    PlaceModel(
      id: 'shuwaymis',
      name: 'الشويمس',
      category: PlaceCategory.heritage,
      description:
          'موقع للرسوم الصخرية جنوب غرب حائل، نقوشه أقدم من نقوش جبة، ويشكل '
          'معها موقع الفنون الصخرية في منطقة حائل المسجل في قائمة التراث '
          'العالمي لليونسكو.',
      location: 'محافظة الحائط',
      latitude: 26.1550,
      longitude: 40.2756,
      image: 'assets/places/shuwaymis_1.jpg',
    ),
    PlaceModel(
      id: 'aarif',
      name: 'قلعة أعيرف',
      category: PlaceCategory.heritage,
      description:
          'قلعة من الطين والحجر على جبل في وسط حائل، يعود بناؤها إلى القرن '
          'السابع عشر الميلادي. استُخدمت للمراقبة ولإطلاق مدفع الإفطار في '
          'رمضان، وتطل على المدينة بمنظر بانورامي.',
      location: 'وسط مدينة حائل',
      latitude: 27.5171,
      longitude: 41.7034,
      image: 'assets/places/aarif_1.jpg',
      gallery: [
        'assets/places/aarif_1.jpg',
        'assets/places/aarif_2.jpg',
        'assets/places/aarif_3.jpg',
      ],
    ),
    PlaceModel(
      id: 'qishla',
      name: 'قصر القشلة',
      category: PlaceCategory.heritage,
      description:
          'قصر طيني بُني في أوائل الأربعينيات الميلادية على الطراز النجدي، '
          'وتحيط به أبراج دفاعية. كان مقرًا عسكريًا، وهو اليوم متحف يعرض تراث '
          'منطقة حائل.',
      location: 'وسط مدينة حائل',
      latitude: 27.5191,
      longitude: 41.6943,
      image: 'assets/places/qishla_1.jpg',
      gallery: [
        'assets/places/qishla_1.jpg',
        'assets/places/qishla_2.jpg',
        'assets/places/qishla_3.jpg',
      ],
    ),
    PlaceModel(
      id: 'barzan',
      name: 'قصر برزان وسوق برزان',
      category: PlaceCategory.heritage,
      description:
          'بقايا قصر تاريخي في وسط حائل لم يبق منه إلا برجان، وبجواره سوق '
          'برزان الشعبي المعروف بالحرف اليدوية والمنتجات المحلية.',
      location: 'حي برزان، وسط حائل',
      latitude: 27.5253,
      longitude: 41.7050,
      image: 'assets/places/barzan_1.jpg',
      gallery: ['assets/places/barzan_1.jpg', 'assets/places/barzan_2.jpg'],
    ),
    PlaceModel(
      id: 'tuwarin',
      name: 'توارن وآثار حاتم الطائي',
      category: PlaceCategory.heritage,
      description:
          'قرية في جبال أجا ترتبط بحاتم الطائي المشهور بالكرم، وفيها بقايا '
          'قصره وقبره.',
      location: 'جبال أجا، محافظة موقق',
      latitude: 27.6587,
      longitude: 41.4505,
    ),
    PlaceModel(
      id: 'fayd',
      name: 'فيد التاريخية',
      category: PlaceCategory.heritage,
      description:
          'بلدة تاريخية جنوب شرق حائل كانت محطة مهمة على درب زبيدة لقوافل '
          'الحج، وتضم أطلال حصون ومساكن مبنية بالحجارة السوداء.',
      location: 'محافظة الشنان',
      latitude: 27.1132,
      longitude: 42.5188,
      image: 'assets/places/fayd_1.jpg',
    ),
    PlaceModel(
      id: 'museum',
      name: 'متحف حائل الإقليمي',
      category: PlaceCategory.heritage,
      description:
          'متحف بمساحة نحو 1500 متر مربع، تعرض قاعاته تاريخ المنطقة من العصور '
          'الحجرية حتى العصر الحديث، وتراثها وحرفها التقليدية وبدايات التعليم '
          'فيها.',
      location: 'مدينة حائل',
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
