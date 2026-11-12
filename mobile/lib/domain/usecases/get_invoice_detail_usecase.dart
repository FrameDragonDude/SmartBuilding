import '../../data/model/invoice_data_model.dart';
import '../repo/i_invoice_repository.dart';

class GetInvoiceDetailUseCase {
  final IInvoiceRepository repository;

  GetInvoiceDetailUseCase(this.repository);

  Future<ResidentInvoiceDetailModel> execute(String invoiceId) async {
    return await repository.getResidentInvoiceDetail(invoiceId);
  }
}
