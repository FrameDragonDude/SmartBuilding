import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';
import '../../../../data/model/resident_profile_model.dart';

class VehiclesParkingSection extends StatefulWidget {
  final List<ResidentVehicleModel> vehicles;
  final VoidCallback? onRegisterNewVehicle;

  const VehiclesParkingSection({
    super.key,
    this.vehicles = const [],
    this.onRegisterNewVehicle,
  });

  @override
  State<VehiclesParkingSection> createState() => _VehiclesParkingSectionState();
}

class _VehiclesParkingSectionState extends State<VehiclesParkingSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final vehicleList = widget.vehicles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header (Clickable)
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
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
                  child: Text(
                    '${vehicleList.isNotEmpty ? vehicleList.length : 2} xe',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
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
        ),
        const SizedBox(height: 8),

        if (_isExpanded) ...[
          if (vehicleList.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicleList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = vehicleList[index];
                final isCar = v.vehicleType.toLowerCase().contains('car') || v.vehicleType.toLowerCase().contains('ô tô');
                final icon = isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded;
                final brandTitle = (v.brand != null && v.brand!.isNotEmpty)
                    ? '${v.vehicleType} ${v.brand}'
                    : '${v.vehicleType} đăng ký';
                final slotLoc = (v.slotCode != null && v.slotCode!.isNotEmpty)
                    ? 'Vị trí: Bãi ${v.basementLevel ?? "B1"} - Ô ${v.slotCode}'
                    : 'Bãi xe cư dân tự do';

                return _buildVehicleCard(
                  title: brandTitle,
                  licensePlate: v.licensePlate,
                  rfidCard: v.rfidCardCode,
                  slotLocation: slotLoc,
                  vehicleType: v.vehicleType.toUpperCase(),
                  isActive: v.isActive,
                  icon: icon,
                );
              },
            )
          else ...[
            // Default mock vehicles if list is empty
            _buildVehicleCard(
              title: 'Ô tô Mercedes-Benz C200',
              licensePlate: '51H-987.65',
              rfidCard: 'RFID-CAR-90812',
              slotLocation: 'Vị trí: Bãi B1 - Ô B1-042 (Cố định)',
              vehicleType: 'Ô TÔ',
              isActive: true,
              icon: Icons.directions_car_rounded,
            ),
            const SizedBox(height: 12),
            _buildVehicleCard(
              title: 'Xe máy Honda SH 150i',
              licensePlate: '59P2-456.78',
              rfidCard: 'RFID-MOTO-33412',
              slotLocation: 'Vị trí: Bãi M1 - Cư dân tự do',
              vehicleType: 'XE MÁY',
              isActive: true,
              icon: Icons.two_wheeler_rounded,
            ),
          ],
          const SizedBox(height: 14),

          // Add New Vehicle Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onRegisterNewVehicle ?? () {},
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
              label: const Text(
                'Đăng ký phương tiện mới (Register Vehicle)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVehicleCard({
    required String title,
    required String licensePlate,
    required String rfidCard,
    required String slotLocation,
    required String vehicleType,
    required bool isActive,
    required IconData icon,
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
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Biển số: $licensePlate',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.lightBlueContainer
                      : AppColors.lightSlateContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vehicleType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardDivider),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thẻ RFID: $rfidCard',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                slotLocation,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
