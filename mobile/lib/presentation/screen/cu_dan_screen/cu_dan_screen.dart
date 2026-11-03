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
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<CuDanCubit>().fetchResidentProfile(residentId: residentId ?? 'Res1');
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      // Section 1: Resident Personal Profile Card
                      ResidentProfileCard(),
                      SizedBox(height: 16),

                      // Section 2: Residence Contract Card
                      ResidenceContractCard(),
                      SizedBox(height: 16),

                      // Section 3: Legal Documents Section
                      LegalDocumentsSection(),
                      SizedBox(height: 16),

                      // Section 4: Vehicles & Parking Section
                      VehiclesParkingSection(),
                      SizedBox(height: 16),

                      // Section 5: Security & Database Authorization Info
                      SecurityAuthorizationCard(),
                      SizedBox(height: 16),
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
