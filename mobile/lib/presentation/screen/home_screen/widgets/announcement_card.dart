import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';
import '../../../../data/model/home_data_model.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementHomeModel? announcement;

  const AnnouncementCard({super.key, this.announcement});

  @override
  Widget build(BuildContext context) {
    final title = announcement?.title ?? "Bảo trì thang máy Tháp Ruby";
    final date = announcement?.date ?? "Hôm nay";
    final content = announcement?.content ?? "Thang máy P1 & P2 tạm ngưng để kiểm định an toàn định kỳ từ 14:00 đến 17:00 ngày 10/09/2026. Quý cư dân vui lòng sử dụng thang hàng P3.";
    final hotline = announcement?.hotline ?? "1900 8899";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign, color: AppColors.secondary, size: 22),
                  SizedBox(width: 8),
                  Text("Thông báo Ban Quản Lý", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text("Mới nhất", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warningRedBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.build, color: AppColors.warningRed, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.cardDivider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.support_agent, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 4),
                        Text("Hotline hỗ trợ: $hotline", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                      child: const Text("Chi tiết lịch", style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
