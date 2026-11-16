import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import 'cubit/khieu_nai_cubit.dart';
import 'cubit/khieu_nai_state.dart';
import 'widgets/complaint_header.dart';
import 'widgets/complaint_stats_section.dart';
import 'widgets/complaint_filter_chips.dart';
import 'widgets/complaint_card.dart';
import 'widgets/floating_report_button.dart';

class KhieuNaiScreen extends StatelessWidget {
  final String? residentId;

  const KhieuNaiScreen({super.key, this.residentId});

  ComplaintStatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatusType.pending;
      case 'assigned':
        return ComplaintStatusType.assigned;
      case 'processing':
        return ComplaintStatusType.processing;
      case 'resolved':
      case 'closed':
        return ComplaintStatusType.completed;
      default:
        return ComplaintStatusType.pending;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ tiếp nhận';
      case 'assigned':
        return 'Đã phân công';
      case 'processing':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã giải quyết';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Chờ tiếp nhận';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KhieuNaiCubit()..fetchComplaints(residentId: residentId ?? 'Res1'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<KhieuNaiCubit, KhieuNaiState>(
          listener: (context, state) {
            if (state is KhieuNaiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is ComplaintCreatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.tertiary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is KhieuNaiLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is KhieuNaiLoaded) {
              final summary = state.summary;
              final complaints = summary.complaints;

              final cardDataList = complaints.map((item) {
                return ComplaintCardData(
                  code: item.id,
                  location: 'Căn ${item.apartmentNumber}',
                  title: item.title,
                  description: item.content,
                  status: _getStatusType(item.status),
                  statusText: _getStatusText(item.status),
                  timeText: item.createdAt,
                  imageUrl: item.attachedImageUrl,
                  attachmentText: item.attachedImageUrl != null ? '1 ảnh đính kèm' : null,
                );
              }).toList();

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await context.read<KhieuNaiCubit>().fetchComplaints(residentId: residentId ?? 'Res1');
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const ComplaintHeader(),
                          const SizedBox(height: 16),

                          // Stats Cards Section
                          ComplaintStatsSection(
                            totalCount: summary.totalCount,
                            processingCount: summary.pendingCount + summary.processingCount,
                            completedCount: summary.resolvedCount,
                          ),
                          const SizedBox(height: 16),

                          // Category Filter Chips
                          ComplaintFilterChips(
                            selectedFilter: state.selectedFilter,
                            onFilterSelected: (filter) {
                              context.read<KhieuNaiCubit>().filterComplaints(filter, residentId: residentId ?? 'Res1');
                            },
                          ),
                          const SizedBox(height: 16),

                          // List of Complaint Cards
                          if (cardDataList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text('Không có khiếu nại/phản hồi nào'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cardDataList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return ComplaintCard(
                                  data: cardDataList[index],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Action Button at Bottom Right
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingReportButton(
                      onPressed: () {
                        // Create complaint dialog
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
