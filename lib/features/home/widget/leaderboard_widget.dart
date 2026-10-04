import 'package:flutter/material.dart';
import 'package:lib/core/constants/app_color.dart';
import 'package:hail_parks_guide/models/leaderboard_model.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> users;
  final VoidCallback onPressed;           // 👈 Changed from onViewAll
  final Function(String) onUserTapped;

  const LeaderboardWidget({
    super.key,
    required this.users,
    required this.onPressed,              // 👈 Changed
    required this.onUserTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.baseGreenColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            const Text(
              'لوحة المتصدرين',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...users.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              final rank = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildRankRectangle(
                    rank: rank,
                    user: user,
                    onTap: () => onUserTapped(user.username), // 👈 changed from user.userId
                    context: context,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ... rest of _buildRankRectangle method (keep exactly as you have it)
  Widget _buildRankRectangle({
    required int rank,
    required LeaderboardEntry user,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    double getWidthFactor(int rank) {
      switch (rank) {
        case 1: return 0.95;
        case 2: return 0.85;
        case 3: return 0.75;
        default: return 0.65;
      }
    }

    EdgeInsets getPadding(int rank) {
      switch (rank) {
        case 1: return const EdgeInsets.symmetric(horizontal: 16, vertical: 18);
        case 2: return const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
        case 3: return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        default: return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      }
    }

    double getNameFontSize(int rank) {
      switch (rank) {
        case 1: return 18;
        case 2: return 17;
        case 3: return 16;
        default: return 15;
      }
    }

    double getPointsFontSize(int rank) {
      switch (rank) {
        case 1: return 16;
        case 2: return 15;
        case 3: return 14;
        default: return 13;
      }
    }

    double getProfileSize(int rank) {
      switch (rank) {
        case 1: return 52;
        case 2: return 46;
        case 3: return 42;
        default: return 38;
      }
    }

    Color getRankBackgroundColor(int rank) {
      return AppColors.sageTint;
    }

    Color getRankBorderColor(int rank) {
      return Colors.white.withOpacity(0.3);
    }

    Color getPointsColor(int rank) {
      return Colors.white;
    }

    Widget getRankDisplay(int rank) {
      switch (rank) {
        case 1: return const Text('🥇', style: TextStyle(fontSize: 32));
        case 2: return const Text('🥈', style: TextStyle(fontSize: 28));
        case 3: return const Text('🥉', style: TextStyle(fontSize: 24));
        default: return Text(
          '$rank',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
          ),
        );
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * getWidthFactor(rank),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: getRankBackgroundColor(rank),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: getRankBorderColor(rank),
              width: 1,
            ),
          ),
          child: Padding(
            padding: getPadding(rank),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  alignment: Alignment.center,
                  child: getRankDisplay(rank),
                ),
                const SizedBox(width: 12),
                Container(
                  width: getProfileSize(rank),
                  height: getProfileSize(rank),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: user.profileImageUrl != null
                      ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: getProfileSize(rank) * 0.5,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: getProfileSize(rank) * 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: getNameFontSize(rank),
                      fontWeight: FontWeight.w700,
                      color: AppColors.baseBlackColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${user.points} نقطة',
                  style: TextStyle(
                    fontSize: getPointsFontSize(rank),
                    color: AppColors.baseBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
