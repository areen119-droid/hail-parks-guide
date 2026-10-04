import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/widgets/curved_header.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.softMint,
                    child: Icon(Icons.park,
                        size: 64, color: AppColors.baseDarkGreenColor),
                  ),
                ),

                const SizedBox(height: 20),

                // App Name
                Text(
                  'Hail Parks Guide',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
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
                    'دليلك إلى حدائق حائل',
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
                            'دليل حدائق حائل تطبيق يساعد الزوار والسياح على اكتشاف حدائق ومتنزهات منطقة حائل. '
                                'يعرض التطبيق مواقع الحدائق على الخريطة مع معلومات عن كل حديقة ومرافقها، '
                                'ويعرّف بالنباتات المحلية والنباتات المزروعة في المنطقة.\n\n'
                                'يمكنك حفظ حدائقك ونباتاتك المفضلة في ملفك الشخصي للرجوع إليها في أي وقت.',
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

                // Credits Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'المصادر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.baseDarkGreenColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'الخرائط: © OpenStreetMap contributors\n'
                          'صور السدر والطلح والأرطى: Krzysztof Ziarnek (Kenraiz)، '
                          'Wikimedia Commons، رخصة CC BY-SA 4.0',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 12, height: 1.6),
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