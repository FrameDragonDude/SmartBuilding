import '../repo/i_invoice_repository.dart';

class SubmitPaymentUseCase {
  final IInvoiceRepository repository;

  SubmitPaymentUseCase(this.repository);

  Future<bool> execute({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  }) {
    return repository.submitPayment(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      payerNote: payerNote,
    );
  }
}
