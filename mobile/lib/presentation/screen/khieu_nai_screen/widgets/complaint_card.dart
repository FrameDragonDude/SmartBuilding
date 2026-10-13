import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

enum ComplaintStatusType {
  pending, // Chờ tiếp nhận
  processing, // Đang xử lý
  assigned, // Đã phân công
  completed, // Đã hoàn thành
}

class ComplaintCardData {
  final String code;
  final String location;
  final String title;
  final String description;
  final ComplaintStatusType status;
  final String statusText;

  // Custom optional fields for different card variations
  final String? timeText;
  final String? attachmentText;
  final String? imageUrl;
  final String? responseTitle;
  final String? responseSubtitle;
  final String? technicianName;
  final String? estimatedTime;
  final String? priorityText;
  final String? completedNote;
  final String? completedAction;

  const ComplaintCardData({
    required this.code,
    required this.location,
    required this.title,
    required this.description,
    required this.status,
    required this.statusText,
    this.timeText,
    this.attachmentText,
    this.imageUrl,
    this.responseTitle,
    this.responseSubtitle,
    this.technicianName,
    this.estimatedTime,
    this.priorityText,
    this.completedNote,
    this.completedAction,
  });
}

class ComplaintCard extends StatelessWidget {
  final ComplaintCardData data;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Code Badge + Location + Status Pill
            _buildTopRow(),
            const SizedBox(height: 12),

            // Title
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Variant Specific Content
            if (data.imageUrl != null || data.timeText != null)
              _buildImageAndMetaRow()
            else if (data.responseTitle != null)
              _buildResponseBox()
            else if (data.technicianName != null)
              _buildTechnicianFooter()
            else if (data.priorityText != null)
              _buildPriorityFooter()
            else if (data.completedNote != null)
              _buildCompletedBox(),
          ],
        ),
      ),
    );
  }

  // Header row
  Widget _buildTopRow() {
    return Row(
      children: [
        // Code Pill (e.g., CR1)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightSlateContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            data.code,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Location text
        Expanded(
          child: Text(
            data.location,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Status Badge
        _buildStatusBadge(),
      ],
    );
  }

  // Status badge widget
  Widget _buildStatusBadge() {
    Color bg;
    Color fg;
    Widget iconWidget;

    switch (data.status) {
      case ComplaintStatusType.pending:
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPending;
        iconWidget = Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: fg,
            shape: BoxShape.circle,
          ),
        );
        break;

      case ComplaintStatusType.processing:
        bg = AppColors.statusProcessingBg;
        fg = AppColors.statusProcessing;
        iconWidget = Icon(Icons.sync_rounded, size: 13, color: fg);
        break;

      case ComplaintStatusType.assigned:
        bg = AppColors.statusAssignedBg;
        fg = AppColors.statusAssigned;
        iconWidget = Icon(Icons.badge_outlined, size: 13, color: fg);
        break;

      case ComplaintStatusType.completed:
        bg = AppColors.statusCompletedBg;
        fg = AppColors.statusCompleted;
        iconWidget = Icon(Icons.check_circle_outline, size: 13, color: fg);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            data.statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // Variant 1: Image thumbnail + Metadata column
  Widget _buildImageAndMetaRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Thumbnail Image with zoom icon overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(
                data.imageUrl ??
                    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=300&q=80',
                width: 90,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 70,
                    color: AppColors.lightSlateContainer,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Metadata Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.timeText != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.timeText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (data.attachmentText != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.attachmentText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: const [
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Variant 2: Soft Blue Response Banner (Card 2)
  Widget _buildResponseBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.highlightBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.roofing_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.responseTitle ?? 'BQL Tòa Ruby tiếp nhận',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (data.responseSubtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.responseSubtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // Variant 3: Technician Footer Row (Card 3)
  Widget _buildTechnicianFooter() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.lightBlueContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.badge_outlined,
            size: 16,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          data.technicianName ?? 'Kỹ sư Hùng (Bảo trì)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (data.estimatedTime != null)
          Text(
            'Dự kiến: ${data.estimatedTime}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  // Variant 4: Urgent Alert Footer Row (Card 4)
  Widget _buildPriorityFooter() {
    return Row(
      children: [
        const Icon(
          Icons.error,
          size: 16,
          color: AppColors.warningRed,
        ),
        const SizedBox(width: 6),
        Text(
          data.priorityText ?? 'Ưu tiên cao PCCC',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.warningRed,
          ),
        ),
        const Spacer(),
        Row(
          children: const [
            Text(
              'Chi tiết xử lý',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }

  // Variant 5: Completed Box (Card 5)
  Widget _buildCompletedBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.highlightBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.statusCompleted),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.statusCompleted,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data.completedNote ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (data.completedAction != null) ...[
            const SizedBox(width: 8),
            Text(
              data.completedAction!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
