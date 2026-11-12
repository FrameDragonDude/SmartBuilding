class ComplaintSummaryEntity {
  final int totalCount;
  final int pendingCount;
  final int processingCount;
  final int resolvedCount;
  final List<ComplaintListItemEntity> complaints;

  const ComplaintSummaryEntity({
    required this.totalCount,
    required this.pendingCount,
    required this.processingCount,
    required this.resolvedCount,
    required this.complaints,
  });
}

class ComplaintListItemEntity {
  final String id;
  final String apartmentNumber;
  final String category;
  final String title;
  final String content;
  final String? attachedImageUrl;
  final String? resolvedImageUrl;
  final String status;
  final String createdAt;
  final String? resolvedAt;

  const ComplaintListItemEntity({
    required this.id,
    required this.apartmentNumber,
    required this.category,
    required this.title,
    required this.content,
    this.attachedImageUrl,
    this.resolvedImageUrl,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });
}
