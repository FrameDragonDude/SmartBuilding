class ResidentInvoiceSummaryEntity {
  final double totalUnpaidAmount;
  final double totalPaidAmount;
  final int unpaidCount;
  final int overdueCount;
  final List<ResidentInvoiceListItemEntity> invoices;

  const ResidentInvoiceSummaryEntity({
    required this.totalUnpaidAmount,
    required this.totalPaidAmount,
    required this.unpaidCount,
    required this.overdueCount,
    required this.invoices,
  });
}

class ResidentInvoiceListItemEntity {
  final String id;
  final String invoiceCode;
  final String apartmentNumber;
  final int billingMonth;
  final int billingYear;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final String dueDate;
  final String? gracePeriodUntil;
  final String createdAt;

  const ResidentInvoiceListItemEntity({
    required this.id,
    required this.invoiceCode,
    required this.apartmentNumber,
    required this.billingMonth,
    required this.billingYear,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.dueDate,
    this.gracePeriodUntil,
    required this.createdAt,
  });
}

class ResidentInvoiceDetailEntity {
  final String id;
  final String invoiceCode;
  final String apartmentNumber;
  final String? residentName;
  final int billingMonth;
  final int billingYear;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final String dueDate;
  final String? gracePeriodUntil;
  final List<InvoiceLineItemEntity> lineItems;

  const ResidentInvoiceDetailEntity({
    required this.id,
    required this.invoiceCode,
    required this.apartmentNumber,
    this.residentName,
    required this.billingMonth,
    required this.billingYear,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.dueDate,
    this.gracePeriodUntil,
    this.lineItems = const [],
  });
}

class InvoiceLineItemEntity {
  final String id;
  final String itemType;
  final String description;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  const InvoiceLineItemEntity({
    required this.id,
    required this.itemType,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}
