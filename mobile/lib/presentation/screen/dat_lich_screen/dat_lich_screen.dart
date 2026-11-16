import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import 'cubit/dat_lich_cubit.dart';
import 'cubit/dat_lich_state.dart';
import 'widgets/dat_lich_tab_bar.dart';
import 'widgets/qr_code_card.dart';
import 'widgets/equipment_standards_card.dart';
import 'widgets/dat_lich_actions.dart';
import 'widgets/support_contact_card.dart';

class DatLichScreen extends StatelessWidget {
  final String? bookingId;
  final String residentId;

  const DatLichScreen({
    super.key,
    this.bookingId,
    this.residentId = 'Res1',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DatLichCubit()
        ..fetchBookingDetail(
          bookingId: bookingId,
          residentId: residentId,
        ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'Chốt Chỉ Số & Vận Hành Kỹ Thu...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Trợ giúp & Hướng dẫn sử dụng vé tiện ích"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<DatLichCubit, DatLichState>(
          listener: (context, state) {
            if (state.toastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.toastMessage!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<DatLichCubit>().clearToast();
            }
          },
          builder: (context, state) {
            final cubit = context.read<DatLichCubit>();

            if (state.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          cubit.fetchBookingDetail(
                            bookingId: bookingId,
                            residentId: residentId,
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tải lại trang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.fetchBookingDetail(
                  bookingId: bookingId,
                  residentId: residentId,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Top Segmented Tab Filter Bar
                    DatLichTabBar(
                      selectedIndex: state.selectedTabIndex,
                      onTabSelected: (index) => cubit.selectTab(index),
                    ),
                    const SizedBox(height: 16),

                    if (state.selectedTabIndex == 0) ...[
                      // 1. QR Code Booking Card
                      QrCodeCard(
                        state: state,
                        onRefreshQr: () => cubit.refreshQrCode(),
                      ),
                      const SizedBox(height: 16),

                      // 2. Equipment & Regulations Card
                      const EquipmentStandardsCard(),
                      const SizedBox(height: 20),

                      // 3. Bottom Action Buttons
                      DatLichActions(
                        onSaveQrPressed: () => cubit.saveQrToGallery(),
                        onSharePressed: () => cubit.shareTicketCode(),
                        onCancelPressed: () => _showCancelDialog(context, cubit),
                      ),
                      const SizedBox(height: 20),

                      // 4. Support Contact Footer Card
                      SupportContactCard(
                        onCallPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đang gọi Hotline BQL: 1900 8899..."),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // 5. Lobby / Elevator Access Pass Tab Content
                      _buildElevatorAccessCard(context, cubit, state),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, DatLichCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Xác nhận hủy đặt chỗ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bạn có chắc chắn muốn hủy lịch đặt Vườn Nướng BBQ Tầng Thượng? Thao tác này không thể hoàn tác.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Quay lại", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.cancelBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Xác nhận hủy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElevatorAccessCard(BuildContext context, DatLichCubit cubit, DatLichState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.secondary, size: 22),
              SizedBox(width: 10),
              Text(
                "Thẻ Thang Máy & Cổng Sảnh",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Mã QR truy cập thang máy tầng 38 Tháp Ruby. Tự động hết hạn sau khi quẹt.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          QrCodeCard(
            state: state.copyWith(
              amenityTitle: "Thẻ Thang Máy Tầng 38",
              blockName: "CỬA SẢNH & THANG MÁY",
            ),
            onRefreshQr: () => cubit.refreshQrCode(),
          ),
        ],
      ),
    );
  }
}
