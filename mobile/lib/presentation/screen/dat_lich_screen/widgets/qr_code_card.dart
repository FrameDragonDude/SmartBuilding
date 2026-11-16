import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../configs/theme/app_color.dart';
import '../cubit/dat_lich_state.dart';

class QrCodeCard extends StatelessWidget {
  final DatLichState state;
  final VoidCallback onRefreshQr;

  const QrCodeCard({
    super.key,
    required this.state,
    required this.onRefreshQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner Image with Overlay Badges
          _buildBannerImage(),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Title & Location info row
                _buildHeaderInfoRow(),

                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.cardDivider),
                const SizedBox(height: 18),

                // 3. Time & Apartment 2-Column Info
                _buildTwoColumnDetails(),

                const SizedBox(height: 20),

                // 4. QR Code Box
                _buildQrCodeBox(),

                const SizedBox(height: 16),

                // 5. Code Pill & Instruction Text
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.ticketCodeText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quét mã tại đầu đọc cổng sảnh tầng thượng hoặc xuất trình cho kỹ thuật viên & an ninh BQL.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.cardDivider),
                const SizedBox(height: 16),

                // 6. Summary List (Guests, CCCD, Fee)
                _buildSummaryItem(
                  icon: Icons.groups_outlined,
                  title: 'Số khách đăng ký',
                  valueWidget: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${state.numberOfGuests} người ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: '(Tối đa ${state.maxCapacity})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  icon: Icons.badge_outlined,
                  title: 'CCCD đại diện',
                  valueWidget: Text(
                    state.idCardNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Phí đặt chỗ',
                  valueWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.feeText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage() {
    return Stack(
      children: [
        Container(
          height: 145,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=1000&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Green Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: state.isCancelled ? Colors.red.withOpacity(0.85) : Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: state.isCancelled ? Colors.white : AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.statusText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: state.isCancelled ? Colors.white : AppColors.tertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Booking Code Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.bookingCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.blockName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.amenityTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      state.locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.lightBlueContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.outdoor_grill_outlined,
            color: AppColors.secondary,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnDetails() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thời gian đặt chỗ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.timeRange,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                state.bookingDate,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: AppColors.cardDivider,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Căn hộ & Cư dân',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.apartmentNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                state.residentName,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeBox() {
    final progressValue = state.remainingSeconds / state.maxSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // QR Code Image with Central Overlay Icon
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QrImageView(
                    data: state.qrData,
                    version: QrVersions.auto,
                    size: 220.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Central Blue Checkmark Badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Auto Refresh Row
          InkWell(
            onTap: onRefreshQr,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sync_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Tự động làm mới sau ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.remainingSeconds}s',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              minHeight: 4.5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required Widget valueWidget,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        valueWidget,
      ],
    );
  }
}
