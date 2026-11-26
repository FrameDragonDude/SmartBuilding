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
import 'widgets/utility_reading_visual_content.dart';

class HoaDonScreen extends StatelessWidget {
  final String? residentId;

  const HoaDonScreen({super.key, this.residentId});

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
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

  List<UtilityReadingModel> _getReadings(ResidentInvoiceDetailModel detail) {
    if (detail.utilityReadings.isNotEmpty) {
      return detail.utilityReadings;
    }

    double elecConsumption = 270;
    double elecAmount = 585000;
    double waterConsumption = 17;
    double waterAmount = 185000;

    for (final item in detail.lineItems) {
      if (item.itemType.toLowerCase() == 'electricity') {
        elecConsumption = item.quantity;
        elecAmount = item.lineTotal;
      } else if (item.itemType.toLowerCase() == 'water') {
        waterConsumption = item.quantity;
        waterAmount = item.lineTotal;
      }
    }

    return [
      UtilityReadingModel(
        meterType: 'Electricity',
        meterSerialNumber: 'EM-RB0101-01',
        previousReading: 420,
        currentReading: 420 + elecConsumption,
        consumption: elecConsumption,
        calculatedAmount: elecAmount,
        proofImageUrl: 'https://storage.bms.vn/meters/m1_0826.jpg',
      ),
      UtilityReadingModel(
        meterType: 'Water',
        meterSerialNumber: 'WM-RB0101-01',
        previousReading: 35,
        currentReading: 35 + waterConsumption,
        consumption: waterConsumption,
        calculatedAmount: waterAmount,
        proofImageUrl: 'https://storage.bms.vn/meters/m2_0826.jpg',
      ),
    ];
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

              final readings = detail != null ? _getReadings(detail) : <UtilityReadingModel>[];

              // Format line items for UI
              final lineItems = detail != null
                  ? detail.lineItems.map((item) {
                      final isElec = item.itemType.toLowerCase() == 'electricity';
                      final isWater = item.itemType.toLowerCase() == 'water';
                      final isUtility = isElec || isWater;

                      UtilityReadingModel? matchingReading;
                      if (isUtility && readings.isNotEmpty) {
                        matchingReading = readings.firstWhere(
                          (r) => r.meterType.toLowerCase() == item.itemType.toLowerCase(),
                          orElse: () => isElec ? readings.first : readings.last,
                        );
                      }

                      return InvoiceItemData(
                        icon: _getItemIcon(item.itemType),
                        iconColor: _getItemIconColor(item.itemType),
                        iconBgColor: _getItemIconBgColor(item.itemType),
                        title: item.description,
                        subtitle: isUtility && matchingReading != null
                            ? '${matchingReading.meterSerialNumber} • ${matchingReading.previousReading.toStringAsFixed(0)} ➔ ${matchingReading.currentReading.toStringAsFixed(0)}'
                            : 'Số lượng: ${item.quantity.toStringAsFixed(0)}',
                        amountText: '${_formatCurrency(item.lineTotal)} đ',
                        meterImageAction: isUtility ? 'Xem số đo' : null,
                        itemType: item.itemType,
                        onTap: isUtility && matchingReading != null
                            ? () {
                                showUtilityReadingModal(
                                  context,
                                  matchingReading!,
                                  billingMonth: detail.billingMonth,
                                  billingYear: detail.billingYear,
                                );
                              }
                            : null,
                      );
                    }).toList()
                  : <InvoiceItemData>[];

              String statusLabel = "Chưa thanh toán";
              if (detail != null) {
                if (detail.status.toLowerCase() == 'paid') {
                  statusLabel = "Đã thanh toán";
                } else if (detail.status.toLowerCase() == 'partiallypaid') {
                  statusLabel = "Thanh toán 1 phần";
                } else if (detail.status.toLowerCase() == 'overdue') {
                  statusLabel = "Quá hạn";
                }
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
                      // Top Segmented Tab Bar (Always Visible)
                      InvoiceTabBar(
                        selectedIndex: state.activeTab,
                        onTabChanged: (index) {
                          context.read<InvoiceCubit>().changeTab(index);
                        },
                      ),
                      const SizedBox(height: 16),

                      // If multiple invoices exist, allow selecting invoice month
                      if (summary.invoices.length > 1 && state.activeTab != 2) ...[
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: summary.invoices.length,
                            itemBuilder: (context, idx) {
                              final inv = summary.invoices[idx];
                              final isSelected = detail != null && inv.id == detail.id;
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

                      // BODY DEPENDING ON ACTIVE TAB
                      if (state.activeTab == 0) ...[
                        if (detail != null) ...[
                          // Tab 0: Hóa đơn tháng
                          InvoiceHeaderCard(
                            billingPeriod: 'Kỳ ${detail.billingMonth.toString().padLeft(2, '0')}/${detail.billingYear}',
                            invoiceCode: detail.invoiceCode,
                            totalAmountText: _formatCurrency(detail.totalAmount),
                            statusText: statusLabel,
                            dueDateText: detail.dueDate,
                            gracePeriodText: detail.gracePeriodUntil ?? 'N/A',
                          ),
                          const SizedBox(height: 16),

                          InvoiceLineItemsCard(items: lineItems),
                          const SizedBox(height: 20),

                          if (detail.status.toLowerCase() != 'paid')
                            InvoiceActionButtons(
                              paymentButtonText: 'Thanh toán ngay',
                              onPaymentPressed: () {
                                context.read<InvoiceCubit>().payInvoice(
                                  invoiceId: detail.id,
                                  amount: detail.remainingAmount > 0 ? detail.remainingAmount : detail.totalAmount,
                                );
                              },
                            ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  state.selectedYear == 0
                                      ? 'Chưa có hóa đơn nào cho căn hộ này'
                                      : 'Chưa có hóa đơn nào trong năm ${state.selectedYear}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else if (state.activeTab == 1) ...[
                        if (detail != null) ...[
                          // Tab 1: Chỉ số Điện Nước
                          _buildUtilityReadingsTab(context, detail, readings),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.speed_rounded, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  state.selectedYear == 0
                                      ? 'Không có chỉ số điện nước'
                                      : 'Chưa có dữ liệu chỉ số điện nước trong năm ${state.selectedYear}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Tab 2: Lịch sử Giao dịch & Hóa đơn theo Năm / Tháng
                        _buildPaymentHistoryTab(
                          context,
                          summary,
                          detail,
                          state.selectedYear,
                          residentId ?? 'Res1',
                        ),
                      ],

                      const SizedBox(height: 20),
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

  Widget _buildUtilityReadingsTab(
    BuildContext context,
    ResidentInvoiceDetailModel detail,
    List<UtilityReadingModel> readings,
  ) {
    final elecReading = readings.firstWhere(
      (r) => r.meterType.toLowerCase() == 'electricity',
      orElse: () => readings.first,
    );
    final waterReading = readings.firstWhere(
      (r) => r.meterType.toLowerCase() == 'water',
      orElse: () => readings.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Summary Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng hợp Điện & Nước kỳ này',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'T${detail.billingMonth.toString().padLeft(2, '0')}/${detail.billingYear}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Elec summary
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.electricOrange.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: AppColors.electricOrange, size: 16),
                              SizedBox(width: 4),
                              Text('Điện sinh hoạt', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${elecReading.consumption.toStringAsFixed(0)} kWh',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_formatCurrency(elecReading.calculatedAmount)} đ',
                            style: const TextStyle(color: AppColors.electricOrange, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Water summary
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.waterCyan.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.water_drop_outlined, color: AppColors.waterCyan, size: 16),
                              SizedBox(width: 4),
                              Text('Nước sinh hoạt', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${waterReading.consumption.toStringAsFixed(0)} m³',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_formatCurrency(waterReading.calculatedAmount)} đ',
                            style: const TextStyle(color: AppColors.waterCyan, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title: Điện sinh hoạt
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.electricOrangeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.electricOrange, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Chỉ số Điện Sinh Hoạt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        UtilityReadingVisualContent(
          reading: elecReading,
          billingMonth: detail.billingMonth,
          billingYear: detail.billingYear,
        ),

        const SizedBox(height: 10),

        // Section Title: Nước sinh hoạt
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.waterCyanBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.water_drop_outlined, color: AppColors.waterCyan, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Chỉ số Nước Sinh Hoạt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        UtilityReadingVisualContent(
          reading: waterReading,
          billingMonth: detail.billingMonth,
          billingYear: detail.billingYear,
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab(
    BuildContext context,
    ResidentInvoiceSummaryModel summary,
    ResidentInvoiceDetailModel? currentDetail,
    int selectedYear,
    String residentId,
  ) {
    final cubit = context.read<InvoiceCubit>();
    final invoices = summary.invoices;

    // Available years for dropdown/filter
    final availableYears = [2026, 2025, 2024, 0]; // 0 = Tất cả các năm

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Filter Year & Summary Header Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_rounded, color: AppColors.secondary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lịch sử Giao dịch & Hóa đơn',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Search / Select Year Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: availableYears.contains(selectedYear) ? selectedYear : 2026,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.secondary),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                        onChanged: (newYear) {
                          if (newYear != null) {
                            cubit.selectYear(newYear, residentId: residentId);
                          }
                        },
                        items: availableYears.map((yr) {
                          return DropdownMenuItem<int>(
                            value: yr,
                            child: Text(yr == 0 ? 'Tất cả các năm' : 'Năm $yr'),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cardDivider),
              const SizedBox(height: 12),

              // Year Stats Summary Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng tiền đã thanh toán',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatCurrency(summary.totalPaidAmount)} đ',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: AppColors.cardDivider),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng cước còn nợ',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatCurrency(summary.totalUnpaidAmount)} đ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: summary.totalUnpaidAmount > 0 ? AppColors.warningRed : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Invoices List Grouped by Month
        if (invoices.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  selectedYear == 0
                      ? 'Không tìm thấy hóa đơn giao dịch nào'
                      : 'Không có giao dịch hóa đơn trong năm $selectedYear',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inv = invoices[index];
              final isPaid = inv.status.toLowerCase() == 'paid';
              final isOverdue = inv.status.toLowerCase() == 'overdue';

              Color statusBgColor = Colors.orange.shade50;
              Color statusTextColor = Colors.orange.shade800;
              String statusLabel = 'Chưa thanh toán';

              if (isPaid) {
                statusBgColor = Colors.green.shade50;
                statusTextColor = Colors.green.shade700;
                statusLabel = 'Đã thanh toán';
              } else if (isOverdue) {
                statusBgColor = Colors.red.shade50;
                statusTextColor = Colors.red.shade700;
                statusLabel = 'Quá hạn';
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (currentDetail?.id == inv.id)
                        ? AppColors.secondary
                        : AppColors.cardBorder,
                    width: (currentDetail?.id == inv.id) ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kỳ Tháng ${inv.billingMonth.toString().padLeft(2, '0')}/${inv.billingYear}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inv.invoiceCode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.cardDivider),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPaid
                                  ? 'Hạn chót: ${inv.dueDate}'
                                  : 'Hạn thanh toán: ${inv.dueDate}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Căn hộ: ${inv.apartmentNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_formatCurrency(inv.totalAmount)} đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action Button: Xem chi tiết hóa đơn này
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await cubit.selectInvoiceDetail(inv.id);
                          cubit.changeTab(0); // Switch to "Hóa đơn tháng" tab to view full details
                        },
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.secondary),
                        label: const Text(
                          'Xem chi tiết hóa đơn kỳ này',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
