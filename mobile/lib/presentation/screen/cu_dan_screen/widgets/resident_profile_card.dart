import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ResidentProfileCard extends StatelessWidget {
  final String name;
  final String roleText;
  final String residentId;
  final String apartmentInfo;
  final String apartmentSubtext;
  final String identityNumber;
  final String identitySubtext;
  final String phoneNumber;
  final String email;
  final String username;
  final String avatarUrl;

  const ResidentProfileCard({
    super.key,
    this.name = 'Nguyễn Văn An',
    this.roleText = 'Cư dân chính thức (Resident)',
    this.residentId = 'Res1',
    this.apartmentInfo = 'RB-0101 • 95m²',
    this.apartmentSubtext = 'Tầng 1 • Ruby Suites',
    this.identityNumber = '079095001234',
    this.identitySubtext = 'Nam • 12/05/1985',
    this.phoneNumber = '0901234567',
    this.email = 'an.nguyen@gmail.com',
    this.username = 'nguyenvanan',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name/Role + ID Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verified badge overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      avatarUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 54,
                        height: 54,
                        color: AppColors.lightBlueContainer,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ID Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightSlateContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ID: $residentId',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Verification Badges Row
          Row(
            children: [
              _buildBadge(
                icon: Icons.verified_user_outlined,
                label: 'Đã định danh CCCD',
                bgColor: AppColors.lightBlueContainer,
                textColor: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                icon: Icons.lock_outline_rounded,
                label: 'JWT Auth',
                bgColor: AppColors.lightSlateContainer,
                textColor: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2 Info Cards Row (Apartment & CCCD)
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Căn hộ & Diện tích',
                  value: apartmentInfo,
                  subtext: apartmentSubtext,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.badge_outlined,
                  label: 'CCCD / CMND',
                  value: identityNumber,
                  subtext: identitySubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Contact Detail Rows
          _buildContactRow(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: phoneNumber,
          ),
          const SizedBox(height: 10),
          _buildContactRow(
            icon: Icons.email_outlined,
            label: 'Hộp thư điện tử',
            value: email,
          ),
          const SizedBox(height: 10),
          _buildSecurityRow(
            icon: Icons.key_outlined,
            label: 'Tài khoản & Bảo mật',
            username: username,
            securityMethod: 'BCrypt Encrypted',
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightSlateBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.lightBlueContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.secondary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityRow({
    required IconData icon,
    required String label,
    required String username,
    required String securityMethod,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.lightBlueContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.secondary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: username,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                text: ' • ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              TextSpan(
                text: securityMethod,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
