import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/invoice_repository.dart';
import '../../../../domain/usecases/get_invoice_detail_usecase.dart';
import '../../../../domain/usecases/get_resident_invoices_usecase.dart';
import '../../../../domain/usecases/submit_payment_usecase.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final GetResidentInvoicesUseCase getResidentInvoicesUseCase;
  final GetInvoiceDetailUseCase getInvoiceDetailUseCase;
  final SubmitPaymentUseCase submitPaymentUseCase;

  InvoiceCubit({
    GetResidentInvoicesUseCase? getResidentInvoicesUseCase,
    GetInvoiceDetailUseCase? getInvoiceDetailUseCase,
    SubmitPaymentUseCase? submitPaymentUseCase,
  })  : getResidentInvoicesUseCase = getResidentInvoicesUseCase ?? GetResidentInvoicesUseCase(InvoiceRepository()),
        getInvoiceDetailUseCase = getInvoiceDetailUseCase ?? GetInvoiceDetailUseCase(InvoiceRepository()),
        submitPaymentUseCase = submitPaymentUseCase ?? SubmitPaymentUseCase(InvoiceRepository()),
        super(InvoiceInitial());

  Future<void> fetchInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) async {
    emit(InvoiceLoading());
    try {
      final summary = await getResidentInvoicesUseCase.execute(
        residentId: residentId,
        status: status,
        year: year,
      );

      if (summary.invoices.isNotEmpty) {
        final latestInvoice = summary.invoices.first;
        final detail = await getInvoiceDetailUseCase.execute(latestInvoice.id);
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
        final detail = await getInvoiceDetailUseCase.execute(invoiceId);
        emit(currentState.copyWith(selectedDetail: detail));
      } catch (_) {}
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
      final success = await submitPaymentUseCase.execute(
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
