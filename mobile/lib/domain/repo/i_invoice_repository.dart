import '../../data/model/invoice_data_model.dart';

abstract class IInvoiceRepository {
  Future<ResidentInvoiceSummaryModel> getResidentInvoices({
    String residentId ,
    String? status,
    int? year,
  });

  Future<ResidentInvoiceDetailModel> getResidentInvoiceDetail(String invoiceId);

  Future<bool> submitPayment({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  });
}
