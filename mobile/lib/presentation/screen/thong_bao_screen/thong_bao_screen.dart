import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import '../../../data/model/notification_model.dart';
import 'cubit/thong_bao_cubit.dart';
import 'cubit/thong_bao_state.dart';

class ThongBaoScreen extends StatelessWidget {
  final String residentId;
  final ValueChanged<bool>? onUnreadChanged;

  const ThongBaoScreen({
    super.key,
    this.residentId = 'Res1',
    this.onUnreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThongBaoCubit()..fetchNotifications(residentId: residentId),
      child: BlocConsumer<ThongBaoCubit, ThongBaoState>(
        listener: (context, state) {
          if (state is ThongBaoLoaded) {
            final hasUnread = state.notifications.any((n) => !n.isRead);
            onUnreadChanged?.call(hasUnread);
          }
        },
        builder: (context, state) {
          final hasUnread = (state is ThongBaoLoaded)
              ? state.notifications.any((n) => !n.isRead)
              : false;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              Navigator.pop(context, hasUnread);
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context, hasUnread),
                ),
                title: const Text(
                  'Hộp thư',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<ThongBaoCubit>().markAllAsRead();
                      onUnreadChanged?.call(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã đánh dấu tất cả thông báo là đã đọc!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.secondary),
                    label: const Text(
                      'Đánh dấu đọc tất cả',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Builder(
                builder: (context) {
                  if (state is ThongBaoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ThongBaoError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<ThongBaoCubit>().fetchNotifications(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ThongBaoLoaded) {
                    final notifications = state.notifications;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<ThongBaoCubit>().fetchNotifications();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thông tin gần nhất',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBlueContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${notifications.where((n) => !n.isRead).length} chưa đọc',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Notification List Cards
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: notifications.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = notifications[index];
                                return _buildNotificationCard(context, item);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item) {
    final priority = item.priority.toLowerCase();

    // Priority-based Border Colors: Urgent = Red, High = Yellow/Orange, Normal = White/Light Grey
    Border border;
    if (priority == 'urgent') {
      border = Border.all(color: Colors.red.shade500, width: 1.8);
    } else if (priority == 'high') {
      border = Border.all(color: Colors.amber.shade700, width: 1.8);
    } else {
      border = Border.all(color: AppColors.cardBorder, width: 1.0);
    }

    // Category / Urgency Icon & Color
    IconData icon;
    Color iconBgColor;
    Color iconColor;

    if (item.category == 'Emergency' || priority == 'urgent') {
      icon = Icons.warning_amber_rounded;
      iconBgColor = Colors.red.shade50;
      iconColor = Colors.red;
    } else if (item.category == 'Complaint') {
      icon = Icons.feedback_rounded;
      iconBgColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
    } else if (item.category == 'Maintenance' || priority == 'high') {
      icon = Icons.build_rounded;
      iconBgColor = Colors.amber.shade50;
      iconColor = Colors.amber.shade800;
    } else if (item.category == 'FeeNotice') {
      icon = Icons.receipt_long_rounded;
      iconBgColor = AppColors.lightBlueContainer;
      iconColor = AppColors.secondary;
    } else {
      icon = Icons.campaign_rounded;
      iconBgColor = AppColors.lightBlueContainer;
      iconColor = AppColors.secondary;
    }

    return InkWell(
      onTap: () {
        context.read<ThongBaoCubit>().markAsRead(item.id);
        _showNotificationDetailDialog(context, item);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : AppColors.lightBlueContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.summary.isNotEmpty ? item.summary : item.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.publishDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetailDialog(BuildContext context, NotificationModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          item.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thời gian: ${item.publishDate}',
                style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                item.content,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
