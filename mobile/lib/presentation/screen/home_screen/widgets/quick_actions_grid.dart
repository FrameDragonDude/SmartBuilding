import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Đóng phí\nsinh hoạt',
      },
      {
        'icon': Icons.outdoor_grill_outlined,
        'label': 'Đặt lịch\nBBQ/Sân',
      },
      {
        'icon': Icons.business_center_outlined,
        'label': 'Báo cáo sự\ncố',
      },
      {
        'icon': Icons.contactless_outlined,
        'label': 'Thẻ xe\nRFID',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: Container(
              height: 115,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
