import '../../domain/repo/i_invoice_repository.dart';
import '../datasources/invoice_remote_datasource.dart';
import '../model/invoice_data_model.dart';

class InvoiceRepository implements IInvoiceRepository {
  final IInvoiceRemoteDataSource remoteDataSource;

  InvoiceRepository({IInvoiceRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? InvoiceRemoteDataSourceImpl();

  @override
  Future<ResidentInvoiceSummaryModel> getResidentInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) {
    return remoteDataSource.getResidentInvoices(
      residentId: residentId,
      status: status,
      year: year,
    );
  }

  @override
  Future<ResidentInvoiceDetailModel> getResidentInvoiceDetail(String invoiceId) {
    return remoteDataSource.getResidentInvoiceDetail(invoiceId);
  }

  @override
  Future<bool> submitPayment({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  }) {
    return remoteDataSource.submitPayment(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      payerNote: payerNote,
    );
  }
}
