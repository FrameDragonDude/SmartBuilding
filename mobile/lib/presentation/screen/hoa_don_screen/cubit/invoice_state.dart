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

  const InvoiceLoaded({
    required this.summary,
    this.selectedDetail,
    this.activeTab = 0,
  });

  InvoiceLoaded copyWith({
    ResidentInvoiceSummaryModel? summary,
    ResidentInvoiceDetailModel? selectedDetail,
    int? activeTab,
  }) {
    return InvoiceLoaded(
      summary: summary ?? this.summary,
      selectedDetail: selectedDetail ?? this.selectedDetail,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [summary, selectedDetail, activeTab];
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
