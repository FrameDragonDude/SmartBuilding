import '../../data/model/invoice_model.dart';
import '../../domain/entities/invoice.dart';

extension InvoiceMapper on InvoiceModel {
  Invoice toEntity() {
    return Invoice(
      id: id,
      apartmentId: apartmentId,
      invoiceCode: invoiceCode,
      billingMonth: billingMonth,
      billingYear: billingYear,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      dueDate: dueDate,
      status: status,
    );
  }
}
