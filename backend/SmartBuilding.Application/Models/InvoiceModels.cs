namespace SmartBuilding.Application.Models;

public sealed record InvoiceListItem(
    string Id,
    string InvoiceCode,
    string ApartmentId,
    string ApartmentNumber,
    string? ResidentName,
    string? PhoneNumber,
    int BillingMonth,
    int BillingYear,
    decimal ManagementFee,
    decimal ElectricityFee,
    decimal WaterFee,
    decimal ParkingFee,
    decimal TotalAmount,
    decimal PaidAmount,
    string Status,
    DateTime DueDate,
    int OverdueDays,
    decimal PenaltyAmount);

public sealed record InvoiceSummaryMetrics(
    decimal TotalAmount,
    decimal PaidAmount,
    decimal PendingAmount,
    decimal OverdueAmount,
    decimal CashFundAmount,
    int TotalInvoices,
    int PaidCount,
    int PendingCount,
    int OverdueCount);

public sealed record PendingPaymentItem(
    string PaymentId,
    string InvoiceId,
    string InvoiceCode,
    string ApartmentNumber,
    string? ResidentName,
    string TransactionCode,
    string PaymentMethod,
    decimal Amount,
    string? ProofReceiptUrl,
    DateTime PaymentDate,
    string? PayerNote);

public sealed record PenaltyItem(
    string PenaltyId,
    string InvoiceId,
    string InvoiceCode,
    string ApartmentNumber,
    string? ResidentName,
    int OverdueDays,
    decimal OriginalAmount,
    decimal PenaltyAmount,
    string Reason,
    bool IsResolved);

public sealed record RevenueStructure(
    decimal ManagementTotal,
    decimal ElectricityTotal,
    decimal WaterAndParkingTotal,
    decimal GrandTotal);

public sealed record GenerateMonthlyInvoiceRequest(
    int Month,
    int Year);
