import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import '../../../data/model/amenity_model.dart';
import '../dat_lich_screen/dat_lich_screen.dart';
import 'cubit/tien_ich_cubit.dart';
import 'cubit/tien_ich_state.dart';

class TienIchScreen extends StatelessWidget {
  final String? residentId;

  const TienIchScreen({super.key, this.residentId});

  void _showBookingBottomSheet(BuildContext context, AmenityModel amenity) {
    int guests = 1;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 18, minute: 0);
    final cubit = context.read<TienIchCubit>();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đặt lịch: ${amenity.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Info
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Giờ mở cửa: ${amenity.openTime} - ${amenity.closeTime}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.groups, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sức chứa tối đa: ${amenity.maxCapacity} người',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Select Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ngày sử dụng:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                        label: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Select Guests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số lượng khách:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondary),
                            onPressed: guests > 1
                                ? () {
                                    setModalState(() {
                                      guests--;
                                    });
                                  }
                                : null,
                          ),
                          Text('$guests', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                            onPressed: guests < amenity.maxCapacity
                                ? () {
                                    setModalState(() {
                                      guests++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      final startTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      final endTime = startTime.add(Duration(minutes: amenity.slotDurationMinutes));

                      Navigator.pop(context); // close bottom sheet

                      final bookingId = await cubit.bookAmenity(
                        amenityId: amenity.id,
                        residentId: residentId ?? 'Res1',
                        startTime: startTime,
                        endTime: endTime,
                        numberOfGuests: guests,
                      );

                      if (parentContext.mounted && bookingId != null && bookingId.isNotEmpty) {
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (context) => DatLichScreen(
                              bookingId: bookingId,
                              residentId: residentId ?? 'Res1',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('XÁC NHẬN ĐẶT LỊCH', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TienIchCubit()..fetchAmenitiesData(residentId: residentId ?? 'Res1'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<TienIchCubit, TienIchState>(
          listener: (context, state) {
            if (state is TienIchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is BookingSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.tertiary,
                  action: state.bookingId != null && state.bookingId!.isNotEmpty
                      ? SnackBarAction(
                          label: 'Xem mã QR',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DatLichScreen(
                                  bookingId: state.bookingId!,
                                  residentId: residentId ?? 'Res1',
                                ),
                              ),
                            );
                          },
                        )
                      : null,
                ),
              );
              if (state.bookingId != null && state.bookingId!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DatLichScreen(
                      bookingId: state.bookingId!,
                      residentId: residentId ?? 'Res1',
                    ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is TienIchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TienIchLoaded) {
              final activeTab = state.activeTab;
              final amenities = state.amenities;
              final myBookings = state.myBookings;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<TienIchCubit>().fetchAmenitiesData(residentId: residentId ?? 'Res1');
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.pool_rounded, color: AppColors.secondary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dịch vụ & Tiện ích Tòa nhà",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Đặt lịch sử dụng tiện ích chung dự án",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Segmented Tab Bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<TienIchCubit>().changeTab(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: activeTab == 0 ? AppColors.secondary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Danh sách tiện ích (${amenities.length})',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: activeTab == 0 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<TienIchCubit>().changeTab(1, residentId: residentId ?? 'Res1'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: activeTab == 1 ? AppColors.secondary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Lịch đặt của tôi (${myBookings.length})',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: activeTab == 1 ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TAB 0: AMENITIES LIST
                      if (activeTab == 0) ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: amenities.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = amenities[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Banner
                                  Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          item.imageUrl ??
                                              'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=1000&auto=format&fit=crop',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.isActive ? AppColors.activeStatusGreenBackground : Colors.red.shade900,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item.isActive ? "Đang mở cửa" : "Bảo trì",
                                              style: TextStyle(
                                                color: item.isActive ? AppColors.mintGreen : Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Details
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule, size: 15, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Giờ mở cửa: ${item.openTime} - ${item.closeTime}',
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.groups, size: 15, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Tối đa: ${item.maxCapacity} người',
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: item.isActive
                                                ? () => _showBookingBottomSheet(context, item)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.secondary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('ĐẶT LỊCH NGAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      // TAB 1: MY BOOKINGS
                      if (activeTab == 1) ...[
                        if (myBookings.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: Text('Bạn chưa có lịch đặt tiện ích nào')),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: myBookings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final b = myBookings[index];
                              final isConfirmed = b.status == 'Confirmed';

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DatLichScreen(
                                        bookingId: b.id,
                                        residentId: residentId ?? 'Res1',
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.cardBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              b.amenityName,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isConfirmed
                                                  ? AppColors.activeStatusGreenBackground
                                                  : Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isConfirmed ? "Đã xác nhận" : (b.status == 'Completed' ? "Đã hoàn thành" : "Đã hủy"),
                                              style: TextStyle(
                                                color: isConfirmed ? AppColors.mintGreen : AppColors.textSecondary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 6),
                                          Text(b.bookingDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.access_time, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 6),
                                          Text('${b.startTime} - ${b.endTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.groups, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 6),
                                          Text('Số lượng: ${b.numberOfGuests} khách', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                      if (isConfirmed) ...[
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                context.read<TienIchCubit>().cancelBooking(b.id, residentId: residentId ?? 'Res1');
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: const Text('Hủy đặt lịch'),
                                            ),
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.qr_code, size: 16),
                                              label: const Text('Mã QR Check-in'),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DatLichScreen(
                                                      bookingId: b.id,
                                                      residentId: residentId ?? 'Res1',
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.lightBlueContainer,
                                                foregroundColor: AppColors.secondary,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
