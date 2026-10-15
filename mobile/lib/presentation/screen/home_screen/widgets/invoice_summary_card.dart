import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final String monthYear;
  final String invoiceCode;
  final double totalAmount;
  final String paymentGateway;
  final String paymentDate;
  final bool isPaid;

  const InvoiceSummaryCard({
    super.key,
    this.monthYear = "08/2026",
    this.invoiceCode = "INV-202608-RB0101",
    this.totalAmount = 4100000,
    this.paymentGateway = "VNPay QR",
    this.paymentDate = "02/09/2026",
    this.isPaid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hóa đơn kỳ $monthYear", style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text("Mã: $invoiceCode", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.activeStatusGreenBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.mintGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? "Đã thanh toán" : "Chưa thanh toán",
                      style: const TextStyle(color: AppColors.mintGreen, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng chi phí phát sinh:", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      style: const TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "đ",
                      style: TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(text: "Cổng thanh toán: ", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          TextSpan(text: paymentGateway, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(paymentDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
