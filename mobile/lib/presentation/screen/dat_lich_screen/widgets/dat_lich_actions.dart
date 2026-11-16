import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class DatLichActions extends StatelessWidget {
  final VoidCallback onSaveQrPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onCancelPressed;

  const DatLichActions({
    super.key,
    required this.onSaveQrPressed,
    required this.onSharePressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Button 1: Dark Slate Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onSaveQrPressed,
            icon: const Icon(
              Icons.file_download_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Lưu mã QR vào thư viện ảnh / Apple Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A), // Dark slate
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Button 2: Light Outlined Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onSharePressed,
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
            label: const Text(
              'Chia sẻ mã vé cho khách mời (10 người)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Button 3: Red Cancel Action
        InkWell(
          onTap: onCancelPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.highlight_off_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Hủy lịch đặt tiện ích BBQ này',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '* Miễn phí hủy trước 12:00 cùng ngày (trước giờ sử dụng 6 tiếng).',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
