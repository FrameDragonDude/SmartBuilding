import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class SecurityAuthorizationCard extends StatefulWidget {
  const SecurityAuthorizationCard({super.key});

  @override
  State<SecurityAuthorizationCard> createState() => _SecurityAuthorizationCardState();
}

class _SecurityAuthorizationCardState extends State<SecurityAuthorizationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Clickable)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Xác thực & Ủy quyền Cơ sở Dữ liệu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardDivider, height: 1),
            const SizedBox(height: 12),

            // Detail Rows
            _buildInfoRow(
              label: 'Cụm dữ liệu phân quyền:',
              value: 'Residents, ApartmentHistories',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              label: 'Cụm dịch vụ bãi xe:',
              value: 'Vehicles, ParkingSlots',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              label: 'Cơ chế bảo mật mã hóa:',
              value: 'HMAC-SHA256 (JWT) & Salt BCrypt',
              valueColor: AppColors.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
