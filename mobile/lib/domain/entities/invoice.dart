class Invoice {
  final String id;
  final String apartmentId;
  final String invoiceCode;
  final int billingMonth;
  final int billingYear;
  final double totalAmount;
  final double paidAmount;
  final String dueDate;
  final String status;

  Invoice({
    required this.id,
    required this.apartmentId,
    required this.invoiceCode,
    required this.billingMonth,
    required this.billingYear,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });
}
