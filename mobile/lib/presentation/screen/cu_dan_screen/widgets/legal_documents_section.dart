import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class LegalDocItemData {
  final String title;
  final String codeOrSubtitle;
  final String subtext;
  final String rightText;
  final bool isApproved;
  final String? actionLabel;
  final Widget? customIcon;

  const LegalDocItemData({
    required this.title,
    required this.codeOrSubtitle,
    required this.subtext,
    required this.rightText,
    this.isApproved = true,
    this.actionLabel,
    this.customIcon,
  });
}

class LegalDocumentsSection extends StatelessWidget {
  final VoidCallback? onUploadNew;

  const LegalDocumentsSection({
    super.key,
    this.onUploadNew,
  });

  List<LegalDocItemData> get _docs => [
        const LegalDocItemData(
          title: 'CCCD Mặt trước',
          codeOrSubtitle: '079095001234',
          subtext: 'Cấp ngày: 10/06/2021',
          rightText: 'Cục CSQLHC về TTXH',
          isApproved: true,
        ),
        const LegalDocItemData(
          title: 'CCCD Mặt sau',
          codeOrSubtitle: 'Chip điện tử & Vân tay',
          subtext: 'Đặc điểm nhận dạng: Nốt ruồi cánh mũi',
          rightText: '10/06/2021',
          isApproved: true,
        ),
        const LegalDocItemData(
          title: 'Xác nhận Tạm trú (CT07)',
          codeOrSubtitle: 'Mã: TT-2024-08A',
          subtext: 'Công an Phường An Phú',
          rightText: 'Hạn: 01/2026',
          isApproved: true,
          customIcon: Icon(Icons.description_outlined,
              color: AppColors.secondary, size: 22),
        ),
        const LegalDocItemData(
          title: 'Khai báo Tạm vắng (TamVang)',
          codeOrSubtitle: 'Tùy chọn khi vắng mặt > 30 ngày',
          subtext: 'Chưa có bản ghi phát sinh',
          rightText: '',
          isApproved: false,
          actionLabel: 'Nộp khai báo',
          customIcon: Icon(Icons.flight_takeoff_rounded,
              color: AppColors.textSecondary, size: 22),
        ),
        const LegalDocItemData(
          title: 'Đăng ký kết hôn (GiayKetHon)',
          codeOrSubtitle: 'Hồ sơ đồng sở hữu / Bảo lãnh',
          subtext: 'Dành cho cư trú cùng gia đình',
          rightText: '',
          isApproved: false,
          actionLabel: 'Tải lên hồ sơ',
          customIcon: Icon(Icons.favorite_outline_rounded,
              color: AppColors.textSecondary, size: 22),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Row
        Row(
          children: [
            const Icon(
              Icons.folder_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hồ sơ Pháp lý',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),

            // Number Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_docs.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),

            // Top Upload Link
            GestureDetector(
              onTap: onUploadNew,
              child: Row(
                children: const [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Tải lên mới',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Document Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _docs[index];
            return _buildDocCard(item, index);
          },
        ),
        const SizedBox(height: 14),

        // Black Upload Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onUploadNew ?? () {},
            icon: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'Tải lên giấy tờ mới (Upload Document)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Widget _buildDocCard(LegalDocItemData item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon / Thumbnail
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightSlateContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: item.customIcon ??
                  Image.network(
                    'https://images.unsplash.com/photo-1557053910-d9eadeed1c58?auto=format&fit=crop&w=100&q=80',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.badge_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Approved / Unapproved Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isApproved
                            ? AppColors.lightBlueContainer
                            : AppColors.lightSlateContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isApproved
                                ? Icons.verified_outlined
                                : Icons.circle,
                            size: 11,
                            color: item.isApproved
                                ? AppColors.secondary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isApproved ? 'Đã duyệt' : 'Chưa nộp',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.isApproved
                                  ? AppColors.secondary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  item.codeOrSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtext and Right Action/Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.subtext,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.actionLabel != null)
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              size: 13,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.actionLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (item.rightText.isNotEmpty)
                      Text(
                        item.rightText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
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
