import 'package:flutter/material.dart';

import '../../configs/theme/app_color.dart';

class BottomBar extends StatelessWidget {
  final int selectedIdx;
  final ValueChanged onTap;

  const BottomBar({
    super.key,
    required this.selectedIdx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide.none),
        color: AppColors.textPrimary,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.textPrimary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Hóa đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pool_rounded),
            label: 'Tiện ích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_rounded),
            label: 'Khiếu nại',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: 'Cư dân',
          ),
        ],
        currentIndex: selectedIdx,
        selectedItemColor: AppColors.secondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedItemColor: Colors.black,
        onTap: onTap,
      ),
    );
  }
}
