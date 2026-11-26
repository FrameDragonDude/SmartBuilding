import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import '../auth/login_screen.dart';
import 'cubit/cu_dan_cubit.dart';
import 'cubit/cu_dan_state.dart';
import 'widgets/resident_profile_card.dart';
import 'widgets/residence_contract_card.dart';
import 'widgets/legal_documents_section.dart';
import 'widgets/vehicles_parking_section.dart';
import 'widgets/security_authorization_card.dart';

class CuDanScreen extends StatelessWidget {
  final String? residentId;

  const CuDanScreen({super.key, this.residentId});

  void _confirmLogout(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản cư dân?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                parentContext,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CuDanCubit()..fetchResidentProfile(residentId: residentId ?? 'Res1'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<CuDanCubit, CuDanState>(
          builder: (context, state) {
            if (state is CuDanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CuDanError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Lỗi tải hồ sơ cư dân: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CuDanCubit>().fetchResidentProfile(residentId: residentId ?? 'Res1');
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is CuDanLoaded) {
              final profile = state.profile;
              final info = profile.residentInfo;
              final contract = profile.contractInfo;
              final account = profile.accountInfo;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<CuDanCubit>().fetchResidentProfile(residentId: residentId ?? 'Res1');
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Section 1: Resident Personal Profile Card
                      ResidentProfileCard(
                        name: info.fullName.isNotEmpty ? info.fullName : 'Vũ Quốc Khánh',
                        roleText: account?.roleName ?? 'Cư dân chính thức (Resident)',
                        residentId: info.id.isNotEmpty ? info.id : (residentId ?? 'Res7'),
                        apartmentInfo: contract != null
                            ? '${contract.apartmentNumber} • ${contract.area.toInt()}m²'
                            : 'RB-0302 • 95m²',
                        apartmentSubtext: contract != null
                            ? '${contract.floorDescription} • ${contract.buildingName}'
                            : 'Tầng 3 • Ruby Suites',
                        identityNumber: info.identityCardNumber.isNotEmpty ? info.identityCardNumber : '079080004455',
                        identitySubtext: '${info.gender} • ${info.dateOfBirth}',
                        phoneNumber: info.phoneNumber,
                        email: (info.email != null && info.email!.isNotEmpty)
                            ? info.email!
                            : (account?.email ?? 'khanh.vu@techcorp.vn'),
                        username: account?.username ?? 'khanhvu',
                        avatarUrl: (info.avatarUrl != null && info.avatarUrl!.isNotEmpty)
                            ? info.avatarUrl!
                            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                      ),
                      const SizedBox(height: 16),

                      // Section 2: Residence Contract Card
                      ResidenceContractCard(
                        tenantRole: contract?.contractType ?? 'Cư dân chính thức (Owner)',
                        contractCode: contract?.historyId ?? 'HD-RB-0302-2024',
                        statusText: contract?.isCurrent == true ? 'Đang hiệu lực (IsCurrent)' : 'Hết hiệu lực',
                        startDate: contract?.startDate ?? '01/01/2024',
                        durationText: '36 tháng',
                        endDate: contract?.endDate ?? '01/01/2027',
                        fileName: contract?.contractFileUrl != null
                            ? contract!.contractFileUrl!.split('/').last
                            : 'Hợp đồng cư trú (RB0302.pdf)',
                      ),
                      const SizedBox(height: 16),

                      // Section 3: Legal Documents Section
                      LegalDocumentsSection(documents: profile.documents),
                      const SizedBox(height: 16),

                      // Section 4: Vehicles & Parking Section
                      VehiclesParkingSection(vehicles: profile.vehicles),
                      const SizedBox(height: 16),

                      // Section 5: Security & Database Authorization Info
                      const SecurityAuthorizationCard(),
                      const SizedBox(height: 20),

                      // Section 6: Red Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'ĐĂNG XUẤT TÀI KHOẢN',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
  }
}
