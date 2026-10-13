import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ComplaintFilterChips extends StatefulWidget {
  final Function(int index)? onSelected;

  const ComplaintFilterChips({
    super.key,
    this.onSelected,
  });

  @override
  State<ComplaintFilterChips> createState() => _ComplaintFilterChipsState();
}

class _ComplaintFilterChipsState extends State<ComplaintFilterChips> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _filters = const [
    {'label': 'Tất cả (10)', 'icon': null},
    {'label': 'Vệ sinh', 'icon': Icons.cleaning_services_outlined},
    {'label': 'Tiếng ồn', 'icon': Icons.volume_up_outlined},
    {'label': 'Hạ tầng', 'icon': Icons.build_outlined},
    {'label': 'An ninh', 'icon': Icons.shield_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = index == _selectedIndex;
          final filter = _filters[index];
          final IconData? iconData = filter['icon'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (widget.onSelected != null) {
                  widget.onSelected!(index);
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
                      filter['label'],
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
