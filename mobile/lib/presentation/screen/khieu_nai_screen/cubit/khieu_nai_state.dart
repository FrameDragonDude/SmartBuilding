import 'package:equatable/equatable.dart';
import '../../../../data/model/complaint_data_model.dart';

abstract class KhieuNaiState extends Equatable {
  const KhieuNaiState();

  @override
  List<Object?> get props => [];
}

class KhieuNaiInitial extends KhieuNaiState {}

class KhieuNaiLoading extends KhieuNaiState {}

class KhieuNaiLoaded extends KhieuNaiState {
  final ComplaintSummaryDataModel summary;
  final String selectedFilter;

  const KhieuNaiLoaded({
    required this.summary,
    this.selectedFilter = 'Tất cả',
  });

  KhieuNaiLoaded copyWith({
    ComplaintSummaryDataModel? summary,
    String? selectedFilter,
  }) {
    return KhieuNaiLoaded(
      summary: summary ?? this.summary,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [summary, selectedFilter];
}

class KhieuNaiError extends KhieuNaiState {
  final String message;

  const KhieuNaiError(this.message);

  @override
  List<Object?> get props => [message];
}

class ComplaintCreatedSuccess extends KhieuNaiState {
  final String message;

  const ComplaintCreatedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
