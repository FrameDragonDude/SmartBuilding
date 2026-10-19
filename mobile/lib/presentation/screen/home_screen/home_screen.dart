import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'widgets/resident_welcome_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/invoice_summary_card.dart';
import 'widgets/vehicle_parking_section.dart';
import 'widgets/amenity_booking_card.dart';
import 'widgets/announcement_card.dart';

class HomeScreen extends StatelessWidget {
  final String? residentId;

  const HomeScreen({super.key, this.residentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Lỗi tải dữ liệu: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeCubit>().fetchHomeData(residentId: residentId ?? 'Res1');
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is HomeLoaded) {
          final data = state.homeData;
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeCubit>().fetchHomeData(residentId: residentId ?? 'Res1');
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (data.resident != null)
                    ResidentWelcomeCard(
                      residentName: data.resident!.fullName,
                      apartmentNumber: data.resident!.apartmentNumber,
                      floorNumber: data.resident!.floorNumber,
                      buildingName: data.resident!.buildingName,
                      area: data.resident!.area,
                      contractType: data.resident!.contractType,
                      startDate: data.resident!.startDate,
                      endDate: data.resident!.endDate,
                    )
                  else
                    const ResidentWelcomeCard(),
                  const QuickActionsGrid(),
                  if (data.invoice != null)
                    InvoiceSummaryCard(
                      monthYear: "${data.invoice!.billingMonth.toString().padLeft(2, '0')}/${data.invoice!.billingYear}",
                      invoiceCode: data.invoice!.invoiceCode,
                      totalAmount: data.invoice!.totalAmount,
                      paidAmount: data.invoice!.paidAmount,
                      status: data.invoice!.status,
                      paymentGateway: data.invoice!.paymentMethod,
                      paymentDate: data.invoice!.paymentDate,
                    )
                  else
                    const InvoiceSummaryCard(),
                  VehicleParkingSection(vehicles: data.vehicles),
                  AmenityBookingCard(booking: data.upcomingBooking),
                  AnnouncementCard(announcement: data.announcement),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
