class NotificationModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String priority;
  final String publishDate;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.priority,
    required this.publishDate,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Normal',
      publishDate: json['publishDate'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? category,
    String? priority,
    String? publishDate,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      publishDate: publishDate ?? this.publishDate,
      isRead: isRead ?? this.isRead,
    );
  }
}
