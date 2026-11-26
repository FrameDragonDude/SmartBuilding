import 'package:equatable/equatable.dart';
import '../../../../data/model/invoice_data_model.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final ResidentInvoiceSummaryModel summary;
  final ResidentInvoiceDetailModel? selectedDetail;
  final int activeTab;
  final int selectedYear;

  const InvoiceLoaded({
    required this.summary,
    this.selectedDetail,
    this.activeTab = 0,
    this.selectedYear = 2026,
  });

  InvoiceLoaded copyWith({
    ResidentInvoiceSummaryModel? summary,
    ResidentInvoiceDetailModel? selectedDetail,
    int? activeTab,
    int? selectedYear,
  }) {
    return InvoiceLoaded(
      summary: summary ?? this.summary,
      selectedDetail: selectedDetail ?? this.selectedDetail,
      activeTab: activeTab ?? this.activeTab,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }

  @override
  List<Object?> get props => [summary, selectedDetail, activeTab, selectedYear];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoicePaymentSuccess extends InvoiceState {
  final String message;

  const InvoicePaymentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
