import 'package:equatable/equatable.dart';
import '../../../../data/model/notification_model.dart';

abstract class ThongBaoState extends Equatable {
  const ThongBaoState();

  @override
  List<Object?> get props => [];
}

class ThongBaoInitial extends ThongBaoState {}

class ThongBaoLoading extends ThongBaoState {}

class ThongBaoLoaded extends ThongBaoState {
  final List<NotificationModel> notifications;

  const ThongBaoLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class ThongBaoError extends ThongBaoState {
  final String message;

  const ThongBaoError(this.message);

  @override
  List<Object?> get props => [message];
}
