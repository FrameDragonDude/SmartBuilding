import '../../data/model/invoice_data_model.dart';
import '../../domain/repo/i_invoice_repository.dart';

class GetResidentInvoicesUseCase {
  final IInvoiceRepository repository;

  GetResidentInvoicesUseCase(this.repository);

  Future<ResidentInvoiceSummaryModel> execute({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) async {
    return await repository.getResidentInvoices(
      residentId: residentId,
      status: status,
      year: year,
    );
  }
}
