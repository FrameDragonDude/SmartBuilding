import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
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

                      // If multiple invoices exist, allow selecting invoice month
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
                      InvoiceLineItemsCard(items: lineItems),
                      const SizedBox(height: 20),

                      // Bottom Action Buttons
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
