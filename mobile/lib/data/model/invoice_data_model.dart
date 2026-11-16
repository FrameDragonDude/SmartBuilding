class ResidentInvoiceSummaryModel {
  final double totalUnpaidAmount;
  final double totalPaidAmount;
  final int unpaidCount;
  final int overdueCount;
  final List<ResidentInvoiceListItemModel> invoices;

  ResidentInvoiceSummaryModel({
    required this.totalUnpaidAmount,
    required this.totalPaidAmount,
    required this.unpaidCount,
    required this.overdueCount,
    required this.invoices,
  });

  factory ResidentInvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return ResidentInvoiceSummaryModel(
      totalUnpaidAmount: (json['totalUnpaidAmount'] ?? 0).toDouble(),
      totalPaidAmount: (json['totalPaidAmount'] ?? 0).toDouble(),
      unpaidCount: json['unpaidCount'] ?? 0,
      overdueCount: json['overdueCount'] ?? 0,
      invoices: json['invoices'] != null
          ? (json['invoices'] as List)
              .map((i) => ResidentInvoiceListItemModel.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ResidentInvoiceListItemModel {
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

  ResidentInvoiceListItemModel({
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

  factory ResidentInvoiceListItemModel.fromJson(Map<String, dynamic> json) {
    return ResidentInvoiceListItemModel(
      id: json['id'] ?? '',
      invoiceCode: json['invoiceCode'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      billingMonth: json['billingMonth'] ?? 1,
      billingYear: json['billingYear'] ?? 2026,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unpaid',
      dueDate: json['dueDate'] ?? '',
      gracePeriodUntil: json['gracePeriodUntil'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ResidentInvoiceDetailModel {
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
  final List<InvoiceLineItemModel> lineItems;
  final List<UtilityReadingModel> utilityReadings;
  final List<InvoicePaymentHistoryModel> payments;

  ResidentInvoiceDetailModel({
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
    this.utilityReadings = const [],
    this.payments = const [],
  });

  factory ResidentInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ResidentInvoiceDetailModel(
      id: json['id'] ?? '',
      invoiceCode: json['invoiceCode'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      residentName: json['residentName'],
      billingMonth: json['billingMonth'] ?? 1,
      billingYear: json['billingYear'] ?? 2026,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unpaid',
      dueDate: json['dueDate'] ?? '',
      gracePeriodUntil: json['gracePeriodUntil'],
      lineItems: json['lineItems'] != null
          ? (json['lineItems'] as List)
              .map((i) => InvoiceLineItemModel.fromJson(i))
              .toList()
          : [],
      utilityReadings: json['utilityReadings'] != null
          ? (json['utilityReadings'] as List)
              .map((u) => UtilityReadingModel.fromJson(u))
              .toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((p) => InvoicePaymentHistoryModel.fromJson(p))
              .toList()
          : [],
    );
  }
}

class InvoiceLineItemModel {
  final String id;
  final String itemType;
  final String description;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  InvoiceLineItemModel({
    required this.id,
    required this.itemType,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceLineItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItemModel(
      id: json['id'] ?? '',
      itemType: json['itemType'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
    );
  }
}

class UtilityReadingModel {
  final String meterType;
  final String meterSerialNumber;
  final double previousReading;
  final double currentReading;
  final double consumption;
  final double calculatedAmount;
  final String? proofImageUrl;

  UtilityReadingModel({
    required this.meterType,
    required this.meterSerialNumber,
    required this.previousReading,
    required this.currentReading,
    required this.consumption,
    required this.calculatedAmount,
    this.proofImageUrl,
  });

  factory UtilityReadingModel.fromJson(Map<String, dynamic> json) {
    return UtilityReadingModel(
      meterType: json['meterType'] ?? 'Electricity',
      meterSerialNumber: json['meterSerialNumber'] ?? '',
      previousReading: (json['previousReading'] ?? 0).toDouble(),
      currentReading: (json['currentReading'] ?? 0).toDouble(),
      consumption: (json['consumption'] ?? 0).toDouble(),
      calculatedAmount: (json['calculatedAmount'] ?? 0).toDouble(),
      proofImageUrl: json['proofImageUrl'],
    );
  }
}

class InvoicePaymentHistoryModel {
  final String id;
  final String transactionCode;
  final String paymentMethod;
  final double amount;
  final String paymentDate;
  final String status;
  final String? proofReceiptUrl;

  InvoicePaymentHistoryModel({
    required this.id,
    required this.transactionCode,
    required this.paymentMethod,
    required this.amount,
    required this.paymentDate,
    required this.status,
    this.proofReceiptUrl,
  });

  factory InvoicePaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return InvoicePaymentHistoryModel(
      id: json['id'] ?? '',
      transactionCode: json['transactionCode'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'VNPay',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] ?? '',
      status: json['status'] ?? 'Success',
      proofReceiptUrl: json['proofReceiptUrl'],
    );
  }
}
