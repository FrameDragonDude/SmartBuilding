import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceTabBar extends StatefulWidget {
  final Function(int index)? onTabChanged;

  const InvoiceTabBar({
    super.key,
    this.onTabChanged,
  });

  @override
  State<InvoiceTabBar> createState() => _InvoiceTabBarState();
}

class _InvoiceTabBarState extends State<InvoiceTabBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = const [
    {
      'label': 'Hóa đơn tháng',
      'icon': Icons.receipt_long_rounded,
    },
    {
      'label': 'Chỉ số Điện Nước',
      'icon': Icons.bolt_outlined,
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
          final isSelected = index == _selectedIndex;
          final tab = _tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (widget.onTabChanged != null) {
                  widget.onTabChanged!(index);
                }
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
                            color: Colors.black.withOpacity(0.04),
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
                      tab['icon'],
                      size: 18,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab['label'],
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
