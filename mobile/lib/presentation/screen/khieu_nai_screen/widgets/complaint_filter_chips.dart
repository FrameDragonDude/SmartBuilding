import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ComplaintFilterChips extends StatefulWidget {
  final String selectedFilter;
  final Function(String filter)? onFilterSelected;

  const ComplaintFilterChips({
    super.key,
    this.selectedFilter = 'Tất cả',
    this.onFilterSelected,
  });

  @override
  State<ComplaintFilterChips> createState() => _ComplaintFilterChipsState();
}

class _ComplaintFilterChipsState extends State<ComplaintFilterChips> {
  final List<Map<String, dynamic>> _filters = const [
    {'label': 'Tất cả', 'icon': null},
    {'label': 'Chờ tiếp nhận', 'icon': Icons.pending_actions_outlined},
    {'label': 'Đang xử lý', 'icon': Icons.engineering_outlined},
    {'label': 'Đã hoàn thành', 'icon': Icons.check_circle_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final filter = _filters[index];
          final String label = filter['label'];
          final isSelected = widget.selectedFilter == label ||
              (widget.selectedFilter == 'Tất cả' && index == 0);
          final IconData? iconData = filter['icon'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                if (widget.onFilterSelected != null) {
                  widget.onFilterSelected!(label);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.chipSelectedBg
                      : AppColors.chipUnselectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconData != null) ...[
                      Icon(
                        iconData,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
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
