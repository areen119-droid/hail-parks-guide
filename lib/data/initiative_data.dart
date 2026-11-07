/// Our earlier project, Ghars Nation, and the planting initiative we ran with
/// it in Prince Saud bin Abdulmohsen Park. Shown from the home screen.
///
/// Fields left null or empty are hidden in the app; fill them in when known.
class InitiativeData {
  static const String appName = 'غرس نيشن';
  static const String appNameLatin = 'Ghars Nation';
  static const String logo = 'assets/images/ghars_nation_logo.png';

  /// The park where the initiative took place (a place id in HailData).
  static const String parkId = 'prince_saud_park';

  static const String title = 'مبادرة غرس في منتزه الأمير سعود بن عبدالمحسن';

  static const String summary =
      'قبل هذا الدليل طوّرنا تطبيق «غرس نيشن» لتشجيع الزراعة والعناية بالأشجار، '
      'ونفّذنا به مبادرة ميدانية في منتزه الأمير سعود بن عبدالمحسن، حضرها الزوار '
      'وشاركوا فيها مستخدمين التطبيق.';

  static const List<String> story = [
    'بدأت الفكرة من سؤال بسيط: كيف نجعل زراعة شجرة والعناية بها شيئًا يشارك فيه '
        'الجميع ويتابعونه؟ فطوّرنا تطبيق «غرس نيشن» الذي يربط كل شتلة بموقعها على '
        'الخريطة وبالشخص الذي زرعها.',
    'في يوم المبادرة حضر زوار المنتزه، فسجّلوا في التطبيق، وزرعوا الشتلات، '
        'ووثّقوا زراعتهم من داخل المنتزه، ثم عادوا لسقيها ومتابعتها.',
    'كانت المبادرة أول تجربة حقيقية للتطبيق مع الناس، ومنها خرجت فكرة هذا '
        'الدليل: تطبيق يعرّف زوار حائل بحدائقها وأماكنها.',
  ];

  /// How taking part worked in the app.
  static const List<String> steps = [
    'يسجّل المشارك في التطبيق ويختار موقع الشتلة على خريطة المنتزه.',
    'يزرع الشتلة ويوثّقها بصورة من كاميرا التطبيق مباشرة.',
    'لا يُقبل التوثيق إلا من داخل الموقع، في حدود ٥٠ مترًا من الشتلة.',
    'يعود لسقي نبتته، ويُحفظ كل سقي في سجل خاص بها.',
    'يجمع نقاطًا على الزراعة والسقي، ويظهر في لوحة المتصدرين.',
  ];

  // Details to fill in.
  static const String? date = null; // e.g. 'أبريل ٢٠٢٦'
  static const int? participants = null;
  static const int? seedlings = null;
  static const List<String> team = [];
}
