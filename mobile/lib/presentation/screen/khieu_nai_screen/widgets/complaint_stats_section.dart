import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ComplaintStatsSection extends StatelessWidget {
  final int totalCount;
  final int processingCount;
  final int completedCount;

  const ComplaintStatsSection({
    super.key,
    this.totalCount = 10,
    this.processingCount = 3,
    this.completedCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card 1: Tổng số
        Expanded(
          child: _buildStatCard(
            title: 'Tổng số',
            count: totalCount,
            countColor: AppColors.textPrimary,
            icon: Icons.inbox_outlined,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.lightBlueContainer,
            cardBgColor: Colors.white,
            borderColor: AppColors.cardBorder,
          ),
        ),
        const SizedBox(width: 8),

        // Card 2: Đang xử lý
        Expanded(
          child: _buildStatCard(
            title: 'Đang xử lý',
            count: processingCount,
            countColor: AppColors.secondary,
            icon: Icons.sync_rounded,
            iconColor: AppColors.secondary,
            iconBgColor: Colors.white,
            cardBgColor: AppColors.lightBlueContainer,
          ),
        ),
        const SizedBox(width: 8),

        // Card 3: Đã xong
        Expanded(
          child: _buildStatCard(
            title: 'Đã xong',
            count: completedCount,
            countColor: AppColors.statusCompleted,
            icon: Icons.verified_outlined,
            iconColor: AppColors.statusCompleted,
            iconBgColor: Colors.white,
            cardBgColor: AppColors.highlightGreenBg,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color countColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardBgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: countColor,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'phiếu',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
