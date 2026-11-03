import 'package:equatable/equatable.dart';
import '../../../../data/model/amenity_data_model.dart';

abstract class TienIchState extends Equatable {
  const TienIchState();

  @override
  List<Object?> get props => [];
}

class TienIchInitial extends TienIchState {}

class TienIchLoading extends TienIchState {}

class TienIchLoaded extends TienIchState {
  final List<AmenityModel> amenities;
  final List<AmenityBookingModel> myBookings;
  final int activeTab;

  const TienIchLoaded({
    required this.amenities,
    required this.myBookings,
    this.activeTab = 0,
  });

  TienIchLoaded copyWith({
    List<AmenityModel>? amenities,
    List<AmenityBookingModel>? myBookings,
    int? activeTab,
  }) {
    return TienIchLoaded(
      amenities: amenities ?? this.amenities,
      myBookings: myBookings ?? this.myBookings,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [amenities, myBookings, activeTab];
}

class TienIchError extends TienIchState {
  final String message;

  const TienIchError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingSuccessState extends TienIchState {
  final String message;

  const BookingSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}
