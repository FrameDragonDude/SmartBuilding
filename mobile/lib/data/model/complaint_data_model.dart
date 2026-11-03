class ComplaintSummaryDataModel {
  final int totalCount;
  final int pendingCount;
  final int processingCount;
  final int resolvedCount;
  final List<ComplaintListItemModel> complaints;

  ComplaintSummaryDataModel({
    required this.totalCount,
    required this.pendingCount,
    required this.processingCount,
    required this.resolvedCount,
    required this.complaints,
  });

  factory ComplaintSummaryDataModel.fromJson(Map<String, dynamic> json) {
    return ComplaintSummaryDataModel(
      totalCount: json['totalCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      processingCount: json['processingCount'] ?? 0,
      resolvedCount: json['resolvedCount'] ?? 0,
      complaints: json['complaints'] != null
          ? (json['complaints'] as List)
              .map((c) => ComplaintListItemModel.fromJson(c))
              .toList()
          : [],
    );
  }
}

class ComplaintListItemModel {
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

  ComplaintListItemModel({
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

  factory ComplaintListItemModel.fromJson(Map<String, dynamic> json) {
    return ComplaintListItemModel(
      id: json['id'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachedImageUrl: json['attachedImageUrl'],
      resolvedImageUrl: json['resolvedImageUrl'],
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? '',
      resolvedAt: json['resolvedAt'],
    );
  }
}
