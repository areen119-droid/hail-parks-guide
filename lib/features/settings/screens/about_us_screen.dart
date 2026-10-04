import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/widgets/curved_header.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'عن التطبيق',
          style: TextStyle(
            color: AppColors.baseDarkGreenColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.baseDarkGreenColor),
      ),
      body: Stack(
        children: [
          // Curved Header
          const CurvedHeader(height: 200),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 120),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/plants/GNLogo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.eco,
                        size: 80,
                        color: AppColors.baseDarkGreenColor,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // App Name
                Text(
                  'Hail Parks Guide',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseDarkGreenColor,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.softMint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ننموا معا',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.baseDarkGreenColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // About Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.vibrantGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'من نحن',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.baseDarkGreenColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'نحن فريق من خمس طالبات طوّرنا تطبيقًا يهدف إلى تشجيع الأفراد على الاهتمام بالطبيعة وزراعة المساحات الفارغة. يوفر التطبيق إرشادات للري، والاطلاع على معلومات وأخبار بيئية، ويساعد المستخدمين على تحويل الأماكن غير المستغلة إلى مساحات خضراء بسهولة.\n\n'
                                'يسعى المشروع إلى نشر الوعي البيئي وتعزيز ثقافة الاستدامة، انطلاقًا من فكرة أن التغيير يبدأ بخطوات بسيطة، دعمًا لتحسين جودة الحياة وتحقيق أهداف رؤية المملكة 2030 نحو بيئة أكثر خضرة.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.baseBlackColor,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Team Section - Names Side by Side in One Row (Centered)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'فريق العمل',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.baseDarkGreenColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Centered names
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTeamName('أرين إبراهيم الفقيه', AppColors.tealGreen),
                                const SizedBox(width: 12),
                                _buildTeamName('رهف الضمادي', AppColors.tealGreen),
                                const SizedBox(width: 12),
                                _buildTeamName('ريم الفهيد', AppColors.tealGreen),
                                const SizedBox(width: 12),
                                _buildTeamName('فوزيه القحطاني', AppColors.tealGreen),
                                const SizedBox(width: 12),
                                _buildTeamName('العنود الصقيه', AppColors.tealGreen),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Contact Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: AppColors.baseDarkGreenColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'HailParksGuide@gmail.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.baseBlackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Version
                Center(
                  child: Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamName(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}