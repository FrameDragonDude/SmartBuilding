using SmartBuilding.Application.Models;

namespace SmartBuilding.Application.Abstractions.Persistence;

public interface IInvoiceRepository
{
    Task<IReadOnlyList<InvoiceListItem>> GetInvoicesAsync(
        string? search,
        string? filterTab, // "All", "PendingUNC", "Overdue", "Paid"
        int? month,
        int? year,
        string? buildingId,
        CancellationToken cancellationToken);

    Task<InvoiceSummaryMetrics> GetSummaryMetricsAsync(int? month, int? year, string? buildingId, CancellationToken cancellationToken);

    Task<IReadOnlyList<PendingPaymentItem>> GetPendingPaymentsAsync(CancellationToken cancellationToken);

    Task<IReadOnlyList<PenaltyItem>> GetPenaltiesAsync(CancellationToken cancellationToken);

    Task<RevenueStructure> GetRevenueStructureAsync(int? month, int? year, CancellationToken cancellationToken);

    Task<bool> ApprovePaymentAsync(string paymentId, CancellationToken cancellationToken);

    Task<bool> RejectPaymentAsync(string paymentId, CancellationToken cancellationToken);

    Task<bool> WaivePenaltyAsync(string penaltyId, CancellationToken cancellationToken);

    Task<int> SendBatchRemindersAsync(CancellationToken cancellationToken);

    Task<int> GenerateMonthlyInvoicesAsync(int month, int year, CancellationToken cancellationToken);
}
