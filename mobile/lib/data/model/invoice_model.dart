import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  InvoiceModel({
    required super.id,
    required super.apartmentId,
    required super.invoiceCode,
    required super.billingMonth,
    required super.billingYear,
    required super.totalAmount,
    required super.paidAmount,
    required super.dueDate,
    required super.status,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      apartmentId: json['apartmentId'] ?? '',
      invoiceCode: json['invoiceCode'] ?? '',
      billingMonth: json['billingMonth'] ?? 1,
      billingYear: json['billingYear'] ?? 2026,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'Unpaid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'invoiceCode': invoiceCode,
      'billingMonth': billingMonth,
      'billingYear': billingYear,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueDate': dueDate,
      'status': status,
    };
  }
}
