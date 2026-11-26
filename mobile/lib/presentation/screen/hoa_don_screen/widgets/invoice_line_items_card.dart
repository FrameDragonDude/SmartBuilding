import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceItemData {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String amountText;
  final String? meterImageAction;
  final VoidCallback? onTap;
  final String? itemType;

  const InvoiceItemData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.amountText,
    this.meterImageAction,
    this.onTap,
    this.itemType,
  });
}

class InvoiceLineItemsCard extends StatelessWidget {
  final List<InvoiceItemData>? items;

  const InvoiceLineItemsCard({
    super.key,
    this.items,
  });

  List<InvoiceItemData> get _defaultItems => const [
        InvoiceItemData(
          icon: Icons.apartment_rounded,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.lightBlueContainer,
          title: 'Phí quản lý căn hộ',
          subtitle: '95 m² × 18.000đ/m²',
          amountText: '1.710.000 đ',
        ),
        InvoiceItemData(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.electricOrange,
          iconBgColor: AppColors.electricOrangeBg,
          title: 'Điện sinh hoạt (270 kWh)',
          subtitle: 'EM-RB0101-01 • 420 ➔ 690',
          amountText: '585.000 đ',
          meterImageAction: 'Ảnh số đo',
          itemType: 'Electricity',
        ),
        InvoiceItemData(
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.waterCyan,
          iconBgColor: AppColors.waterCyanBg,
          title: 'Nước sinh hoạt (17 m³)',
          subtitle: 'WM-RB0101-01 • 35 ➔ 52',
          amountText: '185.000 đ',
          meterImageAction: 'Ảnh số đo',
          itemType: 'Water',
        ),
        InvoiceItemData(
          icon: Icons.directions_car_outlined,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.lightBlueContainer,
          title: 'Phí giữ xe ô tô',
          subtitle: 'Biển số: 51H-888.66 (B1)',
          amountText: '1.500.000 đ',
        ),
        InvoiceItemData(
          icon: Icons.two_wheeler_outlined,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.lightBlueContainer,
          title: 'Phí giữ xe máy',
          subtitle: 'Biển số: 59E1-123.45',
          amountText: '120.000 đ',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final listItems = items ?? _defaultItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(
                Icons.format_list_bulleted_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết cước kỳ này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${listItems.length} mục phí',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardDivider, height: 1),
          const SizedBox(height: 8),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = listItems[index];
              return _buildItemRow(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItemData item) {
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Icon Box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: item.iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Title & Subtitle Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Amount & Optional Meter Image Action Link
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.amountText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (item.meterImageAction != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: item.iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 13,
                        color: item.iconColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.meterImageAction!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (item.onTap != null) ...[
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
        ],
      ],
    );

    if (item.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: rowContent,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: rowContent,
    );
  }
}
