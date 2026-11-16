import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
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

  void _showRegisterVehicleDialog(BuildContext context, String currentResidentId) {
    final formKey = GlobalKey<FormState>();
    String vehicleType = 'Motorcycle';
    final brandController = TextEditingController();
    final plateController = TextEditingController();
    final rfidController = TextEditingController(text: 'RFID-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Đăng ký phương tiện mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: vehicleType,
                        decoration: InputDecoration(
                          labelText: 'Loại phương tiện',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Motorcycle', child: Text('Xe máy')),
                          DropdownMenuItem(value: 'Car', child: Text('Ô tô')),
                          DropdownMenuItem(value: 'Bicycle', child: Text('Xe đạp / Xe điện')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => vehicleType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: brandController,
                        decoration: InputDecoration(
                          labelText: 'Hãng xe / Mẫu xe (tùy chọn)',
                          hintText: 'VD: Honda SH, VinFast VF8',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: plateController,
                        decoration: InputDecoration(
                          labelText: 'Biển số xe *',
                          hintText: 'VD: 59E1-888.88',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Vui lòng nhập biển số xe'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: rfidController,
                        decoration: InputDecoration(
                          labelText: 'Mã thẻ RFID *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Vui lòng nhập mã RFID'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(context);
                              context.read<CuDanCubit>().registerVehicle(
                                residentId: currentResidentId,
                                vehicleType: vehicleType,
                                licensePlate: plateController.text.trim(),
                                rfidCardCode: rfidController.text.trim(),
                                brand: brandController.text.trim().isNotEmpty
                                    ? brandController.text.trim()
                                    : null,
                              );
                            }
                          },
                          child: const Text(
                            'Gửi đăng ký',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentResId = residentId ?? 'Res1';
    return BlocProvider(
      create: (context) => CuDanCubit()..fetchResidentProfile(residentId: currentResId),
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
                          context.read<CuDanCubit>().fetchResidentProfile(residentId: currentResId);
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is CuDanLoaded) {
              final info = state.profile.residentInfo;
              final contract = state.profile.contractInfo;
              final vehicles = state.profile.vehicles;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<CuDanCubit>().fetchResidentProfile(residentId: currentResId);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Section 1: Resident Personal Profile Card
                      ResidentProfileCard(
                        name: info.fullName,
                        residentId: info.id,
                        roleText: contract != null
                            ? '${contract.contractType} (${contract.buildingName})'
                            : 'Cư dân chính thức (Resident)',
                        apartmentInfo: contract != null
                            ? 'Căn ${contract.apartmentNumber}'
                            : 'Chưa gán căn hộ',
                        apartmentSubtext: contract != null
                            ? 'Tòa ${contract.buildingName}'
                            : '',
                        identityNumber: info.identityCardNumber,
                        identitySubtext: '${info.gender} • Cư dân',
                        phoneNumber: info.phoneNumber,
                        email: info.email ?? 'Chưa cập nhật email',
                        username: info.id.toLowerCase(),
                        avatarUrl: info.avatarUrl ??
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                      ),
                      const SizedBox(height: 16),

                      // Section 2: Residence Contract Card
                      ResidenceContractCard(
                        tenantRole: contract?.contractType ?? 'Chủ hộ / Cư dân',
                        contractCode: 'HD-${contract?.apartmentNumber ?? info.id}',
                        statusText: contract?.isCurrent == true
                            ? 'Đang hiệu lực (IsCurrent)'
                            : 'Hết hiệu lực',
                        startDate: contract?.startDate ?? '01/01/2024',
                        durationText: 'Hợp đồng dài hạn',
                        endDate: 'Đang duy trì',
                        fileName: 'Hợp đồng cư trú (${contract?.apartmentNumber ?? "Apartment"}.pdf)',
                      ),
                      const SizedBox(height: 16),

                      // Section 3: Legal Documents Section
                      const LegalDocumentsSection(),
                      const SizedBox(height: 16),

                      // Section 4: Vehicles & Parking Section
                      VehiclesParkingSection(
                        vehicles: vehicles,
                        onRegisterNewVehicle: () => _showRegisterVehicleDialog(context, currentResId),
                      ),
                      const SizedBox(height: 16),

                      // Section 5: Security & Database Authorization Info
                      const SecurityAuthorizationCard(),
                      const SizedBox(height: 16),
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
