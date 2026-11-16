namespace SmartBuilding.Application.Models;

public class ResidentInvoiceSummaryDto
{
    public decimal TotalUnpaidAmount { get; set; }
    public decimal TotalPaidAmount { get; set; }
    public int UnpaidCount { get; set; }
    public int OverdueCount { get; set; }
    public List<ResidentInvoiceListItemDto> Invoices { get; set; } = new();
}

public class ResidentInvoiceListItemDto
{
    public string Id { get; set; } = string.Empty;
    public string InvoiceCode { get; set; } = string.Empty;
    public string ApartmentNumber { get; set; } = string.Empty;
    public int BillingMonth { get; set; }
    public int BillingYear { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RemainingAmount => Math.Max(0, TotalAmount - PaidAmount);
    public string Status { get; set; } = string.Empty;
    public string DueDate { get; set; } = string.Empty;
    public string? GracePeriodUntil { get; set; }
    public string CreatedAt { get; set; } = string.Empty;
}

public class ResidentInvoiceDetailDto
{
    public string Id { get; set; } = string.Empty;
    public string InvoiceCode { get; set; } = string.Empty;
    public string ApartmentNumber { get; set; } = string.Empty;
    public string? ResidentName { get; set; }
    public int BillingMonth { get; set; }
    public int BillingYear { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RemainingAmount => Math.Max(0, TotalAmount - PaidAmount);
    public string Status { get; set; } = string.Empty;
    public string DueDate { get; set; } = string.Empty;
    public string? GracePeriodUntil { get; set; }

    public List<InvoiceLineItemDto> LineItems { get; set; } = new();
    public List<UtilityReadingDto> UtilityReadings { get; set; } = new();
    public List<InvoicePaymentHistoryDto> Payments { get; set; } = new();
    public List<InvoicePenaltyDto> Penalties { get; set; } = new();
}

public class InvoiceLineItemDto
{
    public string Id { get; set; } = string.Empty;
    public string ItemType { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }
}

public class UtilityReadingDto
{
    public string MeterType { get; set; } = string.Empty;
    public string MeterSerialNumber { get; set; } = string.Empty;
    public decimal PreviousReading { get; set; }
    public decimal CurrentReading { get; set; }
    public decimal Consumption { get; set; }
    public decimal CalculatedAmount { get; set; }
    public string? ProofImageUrl { get; set; }
}

public class InvoicePaymentHistoryDto
{
    public string Id { get; set; } = string.Empty;
    public string TransactionCode { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string PaymentDate { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? ProofReceiptUrl { get; set; }
    public string? PayerNote { get; set; }
}

public class InvoicePenaltyDto
{
    public string Id { get; set; } = string.Empty;
    public int OverdueDays { get; set; }
    public decimal InterestRate { get; set; }
    public decimal PenaltyAmount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public bool IsResolved { get; set; }
}

public class SubmitInvoicePaymentRequest
{
    public string PaymentMethod { get; set; } = "VNPay";
    public decimal Amount { get; set; }
    public string? ProofReceiptUrl { get; set; }
    public string? PayerNote { get; set; }
}
