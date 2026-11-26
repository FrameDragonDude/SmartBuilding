import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;

  const InvoiceTabBar({
    super.key,
    this.selectedIndex = 0,
    this.onTabChanged,
  });

  static const List<Map<String, dynamic>> _tabs = [
    {
      'label': 'Hóa đơn tháng',
      'icon': Icons.receipt_long_rounded,
    },
    {
      'label': 'Chỉ số Điện Nước',
      'icon': Icons.speed_rounded,
    },
    {
      'label': 'Lịch sử',
      'icon': Icons.history_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabContainerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == selectedIndex;
          final tab = _tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onTabChanged?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
