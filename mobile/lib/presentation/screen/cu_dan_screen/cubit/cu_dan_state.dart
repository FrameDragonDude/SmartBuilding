import 'package:equatable/equatable.dart';
import '../../../../data/model/resident_profile_model.dart';

abstract class CuDanState extends Equatable {
  const CuDanState();

  @override
  List<Object?> get props => [];
}

class CuDanInitial extends CuDanState {}

class CuDanLoading extends CuDanState {}

class CuDanLoaded extends CuDanState {
  final ResidentProfileDataModel profile;

  const CuDanLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class CuDanError extends CuDanState {
  final String message;

  const CuDanError(this.message);

  @override
  List<Object?> get props => [message];
}
