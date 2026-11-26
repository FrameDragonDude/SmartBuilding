import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class ResidentProfileCard extends StatefulWidget {
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
  State<ResidentProfileCard> createState() => _ResidentProfileCardState();
}

class _ResidentProfileCardState extends State<ResidentProfileCard> {
  bool _isExpanded = false;
  bool _isSensitiveVisible = false;

  String _maskValue(String raw, {int showPrefix = 3, int showSuffix = 3}) {
    if (_isSensitiveVisible) return raw;
    if (raw.contains('@')) {
      final parts = raw.split('@');
      final namePart = parts[0];
      final domainPart = parts[1];
      if (namePart.length <= 2) {
        return '${namePart[0]}***@$domainPart';
      }
      return '${namePart.substring(0, 2)}***${namePart.substring(namePart.length - 1)}@$domainPart';
    }
    if (raw.length <= showPrefix + showSuffix) {
      return '••••••••';
    }
    final prefix = raw.substring(0, showPrefix);
    final suffix = raw.substring(raw.length - showSuffix);
    final maskedLen = raw.length - showPrefix - showSuffix;
    return '$prefix${'*' * maskedLen}$suffix';
  }

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
          // Top Row: Avatar + Name/Role + ID Pill + Privacy/Expand Controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.avatarUrl,
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
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.roleText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Controls: Privacy Eye Button + ID Badge + Chevron Toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _isSensitiveVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    tooltip: _isSensitiveVisible ? 'Ẩn thông tin nhạy cảm' : 'Hiển thị thông tin nhạy cảm',
                    onPressed: () {
                      setState(() {
                        _isSensitiveVisible = !_isSensitiveVisible;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightSlateContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: ${widget.residentId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_isExpanded) ...[
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
                    value: widget.apartmentInfo,
                    subtext: widget.apartmentSubtext,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'CCCD / CMND',
                    value: _maskValue(widget.identityNumber),
                    subtext: widget.identitySubtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Contact Detail Rows
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: 'Số điện thoại',
              value: _maskValue(widget.phoneNumber),
            ),
            const SizedBox(height: 10),
            _buildContactRow(
              icon: Icons.email_outlined,
              label: 'Hộp thư điện tử',
              value: _maskValue(widget.email),
            ),
            const SizedBox(height: 10),
            _buildSecurityRow(
              icon: Icons.key_outlined,
              label: 'Tài khoản & Bảo mật',
              username: widget.username,
              securityMethod: 'BCrypt Encrypted',
            ),
          ],
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
