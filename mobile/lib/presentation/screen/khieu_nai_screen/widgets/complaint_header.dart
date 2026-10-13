import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ComplaintHeader extends StatelessWidget {
  final VoidCallback? onCreateNew;

  const ComplaintHeader({
    super.key,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Quản lý Phản ánh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Theo dõi & Xử lý sự cố tòa nhà Ruby Suites',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onCreateNew ?? () {},
          icon: const Icon(
            Icons.add,
            size: 18,
            color: Colors.white,
          ),
          label: const Text(
            'Tạo mới',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
