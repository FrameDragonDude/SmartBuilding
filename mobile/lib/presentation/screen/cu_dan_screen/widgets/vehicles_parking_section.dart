import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class VehiclesParkingSection extends StatelessWidget {
  final VoidCallback? onRegisterNewVehicle;

  const VehiclesParkingSection({
    super.key,
    this.onRegisterNewVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header
        Row(
          children: [
            const Icon(
              Icons.local_parking_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Phương tiện & Thẻ đỗ xe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),

            // Vehicles Count Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lightBlueContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '2 xe',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Hầm B1',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // CCCD Encoding Info Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightBlueContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textPrimary),
                    children: [
                      TextSpan(
                        text: 'Quy chuẩn mã hóa phương tiện theo CCCD:\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'Ô tô ('),
                      TextSpan(
                        text: 'OT-CCCD',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      TextSpan(text: '), Xe máy ('),
                      TextSpan(
                        text: 'XM-CCCD',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      TextSpan(text: '), Xe đạp ('),
                      TextSpan(
                        text: 'XD-CCCD',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      TextSpan(text: '), Xe điện ('),
                      TextSpan(
                        text: 'XEL-CCCD',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      TextSpan(text: ').'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Vehicle 1: Mercedes-Benz C200
        _buildVehicleCard(
          icon: Icons.directions_car_outlined,
          name: 'Mercedes-Benz C200',
          rfidStatus: 'RFID Active',
          subtitle: 'Màu: Đen Kim Loại • Sedan 5 chỗ',
          plateNumber: '51H-888.66',
          plateRegion: 'Biển số TP.HCM',
          rfidCode: 'RFID-CAR-002',
          vehicleId: 'OT-079095001234-51H88866',
          parkingSlot: 'Hầm B1 • Ô B1-B1-CAR-01',
        ),
        const SizedBox(height: 12),

        // Vehicle 2: Honda SH 150i
        _buildVehicleCard(
          icon: Icons.two_wheeler_outlined,
          name: 'Honda SH 150i',
          rfidStatus: 'RFID Active',
          subtitle: 'Màu: Trắng Ngọc Trai • Tay ga',
          plateNumber: '59E1-123.45',
          plateRegion: 'Biển kiểm soát',
          rfidCode: 'RFID-MB-001',
          vehicleId: 'XM-079095001234-59E112345',
          parkingSlot: 'Hầm B1 • Ô B1-B1-MOTO-01',
        ),
        const SizedBox(height: 14),

        // Register New Vehicle Full-width Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRegisterNewVehicle ?? () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.secondary,
              size: 18,
            ),
            label: const Text(
              'Đăng ký thêm phương tiện mới',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlueContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard({
    required IconData icon,
    required String name,
    required String rfidStatus,
    required String subtitle,
    required String plateNumber,
    required String plateRegion,
    required String rfidCode,
    required String vehicleId,
    required String parkingSlot,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rfidStatus,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // License Plate Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    plateNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plateRegion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.cell_tower,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rfidCode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Vehicle Identity Info
          Row(
            children: [
              const Text(
                'Mã định danh xe (ID): ',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  vehicleId,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Ô đỗ chỉ định (ParkingSlot): ',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.local_parking,
                size: 13,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 2),
              Text(
                parkingSlot,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
