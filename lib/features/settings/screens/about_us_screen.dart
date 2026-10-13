import 'package:flutter/material.dart';
import 'package:hail_parks_guide/app/theme.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/custom_button.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _team = [
    'أرين إبراهيم الفقيه',
    'رهف الضمادي',
    'ريم الفهيد',
    'فوزيه القحطاني',
    'العنود الصقيه',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/hail_landscape.jpg', fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), AppColors.sandLight],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircleIconButton(
                        icon: Icons.arrow_back,
                        tooltip: 'رجوع',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  start: 20,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('دليل حدائق حائل', style: AppText.display),
                      Text(
                        'Hail Parks Guide · الإصدار 1.0.0',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.sandLight,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Card(
                  title: 'عن التطبيق',
                  child: Text(
                    'دليل حدائق حائل تطبيق يساعد الزوار والسياح على اكتشاف منطقة حائل: '
                    'حدائقها ومتنزهاتها، وجبالها ومعالمها الطبيعية، ومواقعها التراثية '
                    'والتاريخية. يعرض التطبيق الأماكن على الخريطة مع معلومات عن كل '
                    'مكان، ويعرّف بالنباتات المحلية والنباتات المزروعة في المنطقة.'
                    '\n\nيمكنك حفظ أماكنك ونباتاتك المفضلة في ملفك الشخصي للرجوع إليها '
                    'في أي وقت.',
                    style: AppText.body,
                  ),
                ),
                _Card(
                  title: 'فريق العمل',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in _team)
                        Chip(
                          label: Text(name),
                          backgroundColor: AppColors.sandLight,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                    ],
                  ),
                ),
                const _Card(
                  title: 'المصادر',
                  child: Text(
                    'الخرائط: © OpenStreetMap contributors\n'
                    'صور منطقة حائل (جبال المسمى، محمية الملك سلمان): '
                    'وكالة الأنباء السعودية (SPA)، Wikimedia Commons، رخصة CC BY-SA 4.0\n'
                    'صور السدر والطلح والأرطى: Krzysztof Ziarnek (Kenraiz)، '
                    'Wikimedia Commons، رخصة CC BY-SA 4.0\n'
                    'صور الأماكن (Wikimedia Commons): هيئة التراث (قلعة أعيرف، قصر '
                    'القشلة، قصر برزان، الشويمس) CC BY-SA 4.0؛ وكالة الأنباء السعودية '
                    'و saudipics (جبال أجا، القشلة) CC BY-SA 4.0؛ Iain Cheyne (قلعة '
                    'أعيرف) CC BY-SA 4.0؛ cvhail (شعيب جو) و Khalid Alhallabi (جبل '
                    'السمراء) CC BY 3.0؛ Prof. Mortel (جبة، فيد) CC BY 2.0؛ NASA '
                    '(النفود) و Gertrude Bell (قصر برزان 1914) ملكية عامة\n'
                    'الخطوط: Amiri و Tajawal، رخصة SIL Open Font License',
                    style: TextStyle(fontSize: 12, height: 1.8, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.section),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
