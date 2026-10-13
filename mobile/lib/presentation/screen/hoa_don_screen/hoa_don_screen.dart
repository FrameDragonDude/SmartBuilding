import 'package:flutter/material.dart';
import '../../../configs/theme/app_color.dart';
import 'widgets/invoice_tab_bar.dart';
import 'widgets/invoice_header_card.dart';
import 'widgets/invoice_line_items_card.dart';
import 'widgets/invoice_action_buttons.dart';

class HoaDonScreen extends StatelessWidget {
  const HoaDonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            // Top Segmented Tab Bar
            InvoiceTabBar(),
            SizedBox(height: 16),

            // Invoice Header Summary Card
            InvoiceHeaderCard(),
            SizedBox(height: 16),

            // Detailed Line Items Card
            InvoiceLineItemsCard(),
            SizedBox(height: 20),

            // Bottom Action Buttons
            InvoiceActionButtons(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
