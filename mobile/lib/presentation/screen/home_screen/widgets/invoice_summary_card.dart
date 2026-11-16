import 'package:flutter/material.dart';
import '../../../../configs/theme/app_color.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final String monthYear;
  final String invoiceCode;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String paymentGateway;
  final String paymentDate;

  const InvoiceSummaryCard({
    super.key,
    this.monthYear = "08/2026",
    this.invoiceCode = "INV-202608-RB0101",
    this.totalAmount = 4100000,
    this.paidAmount = 4100000,
    this.status = "Paid",
    this.paymentGateway = "VNPay QR",
    this.paymentDate = "02/09/2026",
  });

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }

  @override
  Widget build(BuildContext context) {
    final double remainingAmount = (totalAmount - paidAmount).clamp(0, totalAmount);
    final double paidPercentage = totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

    // Determine Status Badge Properties
    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'paid':
        badgeBg = const Color(0xFF064E3B);
        badgeText = const Color(0xFF34D399);
        badgeIcon = Icons.check_circle_outline;
        statusLabel = "Đã thanh toán";
        break;
      case 'partiallypaid':
        badgeBg = const Color(0xFFFFFBEB);
        badgeText = const Color(0xFFD97706);
        badgeIcon = Icons.pie_chart_outline_rounded;
        statusLabel = "Thanh toán 1 phần";
        break;
      case 'overdue':
        badgeBg = const Color(0xFFFEF2F2);
        badgeText = const Color(0xFFEF4444);
        badgeIcon = Icons.error_outline;
        statusLabel = "Quá hạn";
        break;
      case 'unpaid':
      default:
        badgeBg = const Color(0xFFFEF2F2);
        badgeText = const Color(0xFFEF4444);
        badgeIcon = Icons.error_outline;
        statusLabel = "Chưa thanh toán";
        break;
    }

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
          // Header Row
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
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeText, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng chi phí phát sinh:", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // IF PARTIALLY PAID -> SHOW PAID & REMAINING BREAKDOWN
          if (status.toLowerCase() == 'partiallypaid') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Đã thanh toán:", style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(_formatCurrency(paidAmount), style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Còn nợ lại:", style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(_formatCurrency(remainingAmount), style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: paidPercentage,
                      backgroundColor: const Color(0xFFFDE68A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Payment Gateway / Date Info Box
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
