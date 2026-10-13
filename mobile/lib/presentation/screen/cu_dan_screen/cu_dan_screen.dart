import 'package:flutter/material.dart';
import '../../../configs/theme/app_color.dart';
import 'widgets/resident_profile_card.dart';
import 'widgets/residence_contract_card.dart';
import 'widgets/legal_documents_section.dart';
import 'widgets/vehicles_parking_section.dart';
import 'widgets/security_authorization_card.dart';

class CuDanScreen extends StatelessWidget {
  const CuDanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
}
