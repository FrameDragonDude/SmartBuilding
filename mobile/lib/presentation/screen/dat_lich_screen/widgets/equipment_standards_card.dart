import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class EquipmentStandardsCard extends StatelessWidget {
  const EquipmentStandardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Trang thiết bị bàn giao & Quy chuẩn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid of Equipment Items
          Row(
            children: [
              Expanded(
                child: _buildEquipmentTile(
                  icon: Icons.microwave_outlined,
                  title: 'Lò nướng BBQ điện',
                  subtitle: 'Công suất lớn 3500W',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEquipmentTile(
                  icon: Icons.countertops_outlined,
                  title: 'Bồn rửa & Sơ chế',
                  subtitle: 'Độc lập tại bếp BBQ-03',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEquipmentTile(
                  icon: Icons.table_restaurant_outlined,
                  title: '2 Bàn ăn ngoài trời',
                  subtitle: 'Kèm 16 ghế composite',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEquipmentTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Thùng rác phân loại',
                  subtitle: 'Hữu cơ & Tái chế',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Red Warning Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Nghiêm cấm dùng than hoa / củi khô',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tuân thủ an toàn PCCC nhà cao tầng. Vui lòng ngắt nguồn điện lò nướng và dọn sạch rác trước giờ bàn giao 20:00.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightBlueContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
