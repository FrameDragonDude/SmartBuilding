import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/invoice_repository.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRepository invoiceRepository;

  InvoiceCubit({InvoiceRepository? invoiceRepository})
      : invoiceRepository = invoiceRepository ?? InvoiceRepository(),
        super(InvoiceInitial());

  Future<void> fetchInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) async {
    emit(InvoiceLoading());
    try {
      final summary = await invoiceRepository.getResidentInvoices(
        residentId: residentId,
        status: status,
        year: year,
      );

      if (summary.invoices.isNotEmpty) {
        final latestInvoice = summary.invoices.first;
        final detail = await invoiceRepository.getResidentInvoiceDetail(latestInvoice.id);
        emit(InvoiceLoaded(summary: summary, selectedDetail: detail));
      } else {
        emit(InvoiceLoaded(summary: summary));
      }
    } catch (e) {
      emit(InvoiceError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> selectInvoiceDetail(String invoiceId) async {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;
      try {
        final detail = await invoiceRepository.getResidentInvoiceDetail(invoiceId);
        emit(currentState.copyWith(selectedDetail: detail));
      } catch (e) {
        // Keep current state
      }
    }
  }

  void changeTab(int tabIndex) {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;
      emit(currentState.copyWith(activeTab: tabIndex));
    }
  }

  Future<void> payInvoice({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  }) async {
    try {
      final success = await invoiceRepository.submitPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMethod: paymentMethod,
        payerNote: payerNote,
      );
      if (success) {
        emit(const InvoicePaymentSuccess("Thanh toán hóa đơn thành công!"));
        await fetchInvoices();
      }
    } catch (e) {
      emit(InvoiceError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
