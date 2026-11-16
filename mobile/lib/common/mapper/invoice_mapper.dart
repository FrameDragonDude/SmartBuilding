import '../../data/model/invoice_data_model.dart';
import '../../domain/entities/invoice_entity.dart';

extension ResidentInvoiceSummaryMapper on ResidentInvoiceSummaryModel {
  ResidentInvoiceSummaryEntity toEntity() {
    return ResidentInvoiceSummaryEntity(
      totalUnpaidAmount: totalUnpaidAmount,
      totalPaidAmount: totalPaidAmount,
      unpaidCount: unpaidCount,
      overdueCount: overdueCount,
      invoices: invoices.map((i) => i.toEntity()).toList(),
    );
  }
}

extension ResidentInvoiceListItemMapper on ResidentInvoiceListItemModel {
  ResidentInvoiceListItemEntity toEntity() {
    return ResidentInvoiceListItemEntity(
      id: id,
      invoiceCode: invoiceCode,
      apartmentNumber: apartmentNumber,
      billingMonth: billingMonth,
      billingYear: billingYear,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      status: status,
      dueDate: dueDate,
      gracePeriodUntil: gracePeriodUntil,
      createdAt: createdAt,
    );
  }
}

extension ResidentInvoiceDetailMapper on ResidentInvoiceDetailModel {
  ResidentInvoiceDetailEntity toEntity() {
    return ResidentInvoiceDetailEntity(
      id: id,
      invoiceCode: invoiceCode,
      apartmentNumber: apartmentNumber,
      residentName: residentName,
      billingMonth: billingMonth,
      billingYear: billingYear,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      status: status,
      dueDate: dueDate,
      gracePeriodUntil: gracePeriodUntil,
      lineItems: lineItems.map((l) => l.toEntity()).toList(),
    );
  }
}

extension InvoiceLineItemMapper on InvoiceLineItemModel {
  InvoiceLineItemEntity toEntity() {
    return InvoiceLineItemEntity(
      id: id,
      itemType: itemType,
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
    );
  }
}
