import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceActionButtons extends StatelessWidget {
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onPaymentPressed;
  final String paymentButtonText;

  const InvoiceActionButtons({
    super.key,
    this.onDownloadPdf,
    this.onPaymentPressed,
    this.paymentButtonText = 'Đã thanh toán',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Button 1: Tải sao kê PDF
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDownloadPdf ?? () {},
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 18,
              color: AppColors.secondary,
            ),
            label: const Text(
              'Tải sao kê PDF',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlueContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Button 2: Đã thanh toán / Thanh toán
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPaymentPressed ?? () {},
            icon: const Icon(
              Icons.credit_card_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              paymentButtonText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
