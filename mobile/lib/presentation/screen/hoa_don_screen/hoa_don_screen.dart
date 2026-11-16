import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import '../../../data/model/invoice_data_model.dart';
import 'cubit/invoice_cubit.dart';
import 'cubit/invoice_state.dart';
import 'widgets/invoice_tab_bar.dart';
import 'widgets/invoice_header_card.dart';
import 'widgets/invoice_line_items_card.dart';
import 'widgets/invoice_action_buttons.dart';

class HoaDonScreen extends StatelessWidget {
  final String? residentId;

  const HoaDonScreen({super.key, this.residentId});

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showPaymentModal(BuildContext context, InvoiceCubit cubit, ResidentInvoiceDetailModel detail) {
    final payAmount = detail.remainingAmount > 0 ? detail.remainingAmount : detail.totalAmount;
    String selectedMethod = 'VietQR';
    final noteController = TextEditingController();

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thanh toán hóa đơn',
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
                    const SizedBox(height: 12),

                    // Invoice Info Summary Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mã HĐ: ${detail.invoiceCode}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Căn ${detail.apartmentNumber}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Số tiền cần thanh toán:',
                                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                              Text(
                                '${_formatCurrency(payAmount)} đ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Phương thức thanh toán:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),

                    // Method 1: VietQR
                    RadioListTile<String>(
                      value: 'VietQR',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.secondary,
                      title: const Text('Chuyển khoản VietQR (Napas 24/7)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Quét mã QR tự động điền số tiền & nội dung', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.qr_code_2_rounded, color: AppColors.secondary),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                    ),

                    // If VietQR is selected, display dynamic QR
                    if (selectedMethod == 'VietQR') ...[
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://img.vietqr.io/image/970422-0901234567-compact2.png?amount=${payAmount.toInt()}&addInfo=${detail.invoiceCode}',
                                  width: 170,
                                  height: 170,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 170,
                                    height: 170,
                                    color: Colors.grey.shade100,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_rounded, size: 64, color: AppColors.secondary),
                                        SizedBox(height: 8),
                                        Text('Mã QR MBBank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Ngân hàng Quân Đội (MBBank) • 0901234567', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text('Nội dung: ${detail.invoiceCode}', style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Method 2: MoMo
                    RadioListTile<String>(
                      value: 'MoMo',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.secondary,
                      title: const Text('Ví điện tử MoMo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Thanh toán qua ứng dụng Ví MoMo', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.account_balance_wallet_outlined, color: Colors.pinkAccent),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                    ),

                    // Method 3: VNPay
                    RadioListTile<String>(
                      value: 'VNPay',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.secondary,
                      title: const Text('Cổng VNPAY / Thẻ ATM nội địa & Quốc tế', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Visa, Master, Napas...', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.credit_card_rounded, color: Colors.blueAccent),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                    ),

                    // Method 4: Cash
                    RadioListTile<String>(
                      value: 'Cash',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.secondary,
                      title: const Text('Tiền mặt tại Văn phòng Quản lý (BQL)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      secondary: const Icon(Icons.payments_outlined, color: Colors.green),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú người nộp (tùy chọn)',
                        hintText: 'VD: Căn hộ ${detail.apartmentNumber} đã thanh toán',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text(
                          'Xác nhận thanh toán',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          cubit.payInvoice(
                            invoiceId: detail.id,
                            amount: payAmount,
                            paymentMethod: selectedMethod,
                            payerNote: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getItemIcon(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'managementfee':
        return Icons.apartment_rounded;
      case 'electricity':
        return Icons.bolt_rounded;
      case 'water':
        return Icons.water_drop_outlined;
      case 'parkingfee':
        return Icons.directions_car_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  Color _getItemIconColor(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'electricity':
        return AppColors.electricOrange;
      case 'water':
        return AppColors.waterCyan;
      default:
        return AppColors.secondary;
    }
  }

  Color _getItemIconBgColor(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'electricity':
        return AppColors.electricOrangeBg;
      case 'water':
        return AppColors.waterCyanBg;
      default:
        return AppColors.lightBlueContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoiceCubit()..fetchInvoices(residentId: residentId ?? 'Res1'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<InvoiceCubit, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is InvoicePaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.tertiary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is InvoiceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InvoiceLoaded) {
              final detail = state.selectedDetail;
              final summary = state.summary;

              if (detail == null) {
                return const Center(
                  child: Text('Chưa có hóa đơn nào cho căn hộ này'),
                );
              }

              // Format line items for UI
              final lineItems = detail.lineItems.map((item) {
                return InvoiceItemData(
                  icon: _getItemIcon(item.itemType),
                  iconColor: _getItemIconColor(item.itemType),
                  iconBgColor: _getItemIconBgColor(item.itemType),
                  title: item.description,
                  subtitle: 'Số lượng: ${item.quantity.toStringAsFixed(0)}',
                  amountText: '${_formatCurrency(item.lineTotal)} đ',
                  meterImageAction: (item.itemType == 'Electricity' || item.itemType == 'Water')
                      ? 'Ảnh số đo'
                      : null,
                );
              }).toList();

              String statusLabel = "Chưa thanh toán";
              if (detail.status.toLowerCase() == 'paid') {
                statusLabel = "Đã thanh toán";
              } else if (detail.status.toLowerCase() == 'partiallypaid') {
                statusLabel = "Thanh toán 1 phần";
              } else if (detail.status.toLowerCase() == 'overdue') {
                statusLabel = "Quá hạn";
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<InvoiceCubit>().fetchInvoices(residentId: residentId ?? 'Res1');
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Top Segmented Tab Bar
                      InvoiceTabBar(
                        onTabChanged: (index) {
                          context.read<InvoiceCubit>().changeTab(index);
                        },
                      ),
                      const SizedBox(height: 16),

                      if (state.activeTab == 0) ...[
                        // TAB 0: HÓA ĐƠN THÁNG
                        if (summary.invoices.length > 1) ...[
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: summary.invoices.length,
                              itemBuilder: (context, idx) {
                                final inv = summary.invoices[idx];
                                final isSelected = inv.id == detail.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text("T${inv.billingMonth.toString().padLeft(2, '0')}/${inv.billingYear}"),
                                    selected: isSelected,
                                    selectedColor: AppColors.secondary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        context.read<InvoiceCubit>().selectInvoiceDetail(inv.id);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Invoice Header Summary Card
                        InvoiceHeaderCard(
                          billingPeriod: 'Kỳ ${detail.billingMonth.toString().padLeft(2, '0')}/${detail.billingYear}',
                          invoiceCode: detail.invoiceCode,
                          totalAmountText: _formatCurrency(detail.totalAmount),
                          statusText: statusLabel,
                          dueDateText: detail.dueDate,
                          gracePeriodText: detail.gracePeriodUntil ?? 'N/A',
                        ),
                        const SizedBox(height: 16),

                        // Detailed Line Items Card
                        InvoiceLineItemsCard(
                          items: lineItems,
                          onMeterImageTap: (item) => _showMeterImageDialog(context, item),
                        ),
                        const SizedBox(height: 20),

                        // Bottom Action Buttons
                        if (detail.status.toLowerCase() != 'paid')
                          InvoiceActionButtons(
                            paymentButtonText: 'Thanh toán ngay',
                            onPaymentPressed: () {
                              _showPaymentModal(context, context.read<InvoiceCubit>(), detail);
                            },
                          ),
                        const SizedBox(height: 16),
                      ] else if (state.activeTab == 1) ...[
                        // TAB 1: CHỈ SỐ ĐIỆN NƯỚC
                        _buildUtilityReadingsView(context, detail),
                      ] else ...[
                        // TAB 2: LỊCH SỬ THANH TOÁN & HÓA ĐƠN
                        _buildHistoryView(context, detail, summary),
                      ],
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

  void _showMeterImageDialog(BuildContext context, InvoiceItemData item) {
    final isElec = item.title.toLowerCase().contains('điện');
    final sampleUrl = isElec
        ? 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=600&q=80'
        : 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=600&q=80';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isElec ? Icons.bolt_rounded : Icons.water_drop_outlined,
              color: isElec ? AppColors.electricOrange : AppColors.waterCyan,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ảnh chỉ số ${isElec ? "Điện" : "Nước"}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                sampleUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey.shade100,
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlueContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dịch vụ:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chỉ số ghi nhận:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(item.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Được kỹ sư MEP chụp và kiểm định trực tiếp tại hộp kỹ thuật tầng.',
                    style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityReadingsView(BuildContext context, ResidentInvoiceDetailModel detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉ số Điện & Nước Căn hộ ${detail.apartmentNumber}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Kỳ hóa đơn T${detail.billingMonth.toString().padLeft(2, '0')}/${detail.billingYear} • Đối soát tự động',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Electricity Card
        _buildMeterCard(
          context: context,
          title: 'Đồng hồ Điện Sinh Hoạt',
          meterCode: 'EM-${detail.apartmentNumber}',
          unit: 'kWh',
          icon: Icons.bolt_rounded,
          iconColor: AppColors.electricOrange,
          iconBgColor: AppColors.electricOrangeBg,
          previous: 420,
          current: 690,
          consumed: 270,
          amountText: '585.000 đ',
          photoUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=600&q=80',
        ),
        const SizedBox(height: 16),

        // Water Card
        _buildMeterCard(
          context: context,
          title: 'Đồng hồ Nước Sinh Hoạt',
          meterCode: 'WM-${detail.apartmentNumber}',
          unit: 'm³',
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.waterCyan,
          iconBgColor: AppColors.waterCyanBg,
          previous: 35,
          current: 52,
          consumed: 17,
          amountText: '185.000 đ',
          photoUrl: 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=600&q=80',
        ),
      ],
    );
  }

  Widget _buildMeterCard({
    required BuildContext context,
    required String title,
    required String meterCode,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required double previous,
    required double current,
    required double consumed,
    required String amountText,
    required String photoUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    Text('Mã công tơ: $meterCode', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                amountText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn('Số cũ', '${previous.toStringAsFixed(0)} $unit'),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
              _buildMetricColumn('Số mới', '${current.toStringAsFixed(0)} $unit'),
              const Icon(Icons.equalizer_rounded, size: 16, color: AppColors.secondary),
              _buildMetricColumn('Tiêu thụ', '${consumed.toStringAsFixed(0)} $unit', isHighlight: true),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              _showMeterImageDialog(
                context,
                InvoiceItemData(
                  icon: icon,
                  iconColor: iconColor,
                  iconBgColor: iconBgColor,
                  title: title,
                  subtitle: '$meterCode • $previous ➔ $current ($consumed $unit)',
                  amountText: amountText,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightSlateContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.photo_camera_back_outlined, size: 16, color: AppColors.secondary),
                  SizedBox(width: 6),
                  Text(
                    'Xem ảnh công tơ thực tế tại hộp kỹ thuật',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView(
    BuildContext context,
    ResidentInvoiceDetailModel currentDetail,
    ResidentInvoiceSummaryModel summary,
  ) {
    final payments = currentDetail.payments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Transactions History
        const Text(
          'Lịch sử Giao dịch & Thanh toán',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (payments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: const [
                Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Chưa có giao dịch thanh toán nào được ghi nhận cho kỳ này', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final pay = payments[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pay.transactionCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('${pay.paymentMethod} • ${pay.paymentDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          if (pay.payerNote != null && pay.payerNote!.isNotEmpty)
                            Text('Ghi chú: ${pay.payerNote}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      '+${_formatCurrency(pay.amount)} đ',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 24),

        // Section 2: All Past Invoices
        const Text(
          'Lịch sử Hóa đơn các kỳ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summary.invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final inv = summary.invoices[idx];
            final isCurrent = inv.id == currentDetail.id;
            final isPaid = inv.status.toLowerCase() == 'paid';
            return InkWell(
              onTap: () {
                context.read<InvoiceCubit>().selectInvoiceDetail(inv.id);
                context.read<InvoiceCubit>().changeTab(0);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.lightBlueContainer.withOpacity(0.5) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isCurrent ? AppColors.secondary : AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPaid ? Icons.check_circle_outline : Icons.pending_actions_rounded,
                        color: isPaid ? Colors.green : Colors.amber.shade800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kỳ T${inv.billingMonth.toString().padLeft(2, '0')}/${inv.billingYear} • ${inv.invoiceCode}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Hạn thanh toán: ${inv.dueDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${_formatCurrency(inv.totalAmount)} đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green : Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
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
