import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class VehicleParkingSection extends StatelessWidget {
  const VehicleParkingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      {
        'name': 'Mercedes-Benz C200',
        'plate': '51H-888.66',
        'price': '1.500.000',
        'slot': 'B1-B1-CAR-01',
        'rfid': 'RFID-CAR-002',
        'type': 'car',
      },
      {
        'name': 'Honda SH 150i',
        'plate': '59E1-123.45',
        'price': '120.000',
        'slot': 'B1-B1-MOTO-01',
        'rfid': 'RFID-MB-001',
        'type': 'bike',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("P", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Text("Phương tiện & Vị trí đỗ xe", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text("${vehicles.length} Phương tiện", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...vehicles.map((v) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            v['type'] == 'car' ? Icons.directions_car_outlined : Icons.two_wheeler_outlined,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['name']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(v['plate']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: v['price']!, style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.bold)),
                          const TextSpan(text: "đ", style: TextStyle(color: AppColors.secondary, fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          const TextSpan(text: "/tháng", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ô đỗ định danh", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 14),
                              const SizedBox(width: 2),
                              Text(v['slot']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text("Khu vực: Hầm B1", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Mã thẻ RFID", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(v['rfid']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.mintGreen, width: 1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Icon(Icons.nfc, color: AppColors.mintGreen, size: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text("Đang hoạt động", style: TextStyle(color: AppColors.mintGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
