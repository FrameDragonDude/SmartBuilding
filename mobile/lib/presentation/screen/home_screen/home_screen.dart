import 'package:flutter/material.dart';
import '../../common widgets/custom_app_bar.dart';
import 'widgets/resident_welcome_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/invoice_summary_card.dart';
import 'widgets/vehicle_parking_section.dart';
import 'widgets/amenity_booking_card.dart';
import 'widgets/announcement_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            ResidentWelcomeCard(),
            QuickActionsGrid(),
            InvoiceSummaryCard(),
            VehicleParkingSection(),
            AmenityBookingCard(),
            AnnouncementCard(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
