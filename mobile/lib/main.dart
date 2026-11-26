import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/common%20widgets/bottom_bar.dart';
import 'package:mobile/presentation/common%20widgets/custom_app_bar.dart';
import 'package:mobile/presentation/screen/auth/login_screen.dart';
import 'package:mobile/presentation/screen/cu_dan_screen/cu_dan_screen.dart';
import 'package:mobile/presentation/screen/hoa_don_screen/hoa_don_screen.dart';
import 'package:mobile/presentation/screen/home_screen/cubit/home_cubit.dart';
import 'package:mobile/presentation/screen/home_screen/cubit/home_state.dart';
import 'package:mobile/presentation/screen/home_screen/home_screen.dart';
import 'package:mobile/presentation/screen/khieu_nai_screen/khieu_nai_screen.dart';
import 'package:mobile/presentation/screen/thong_bao_screen/thong_bao_screen.dart';
import 'package:mobile/presentation/screen/tien_ich_screen/tien_ich_screen.dart';

import 'configs/theme/app_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Building',
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData.light(),
      home: const LoginScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String residentId;

  const MainNavigationScreen({super.key, this.residentId = 'Res1'});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _hasUnreadNotification = true;

  void _showProfileMenu(BuildContext context, String apartmentSubtitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tài khoản Cư dân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          apartmentSubtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Item 1: Thông tin cá nhân
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: AppColors.secondary),
                  ),
                  title: const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text('Xem hồ sơ cư dân & hợp đồng cư trú', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    setState(() {
                      _selectedIndex = 4; // Switch to Cư Dân tab
                    });
                  },
                ),
                const SizedBox(height: 4),

                // Item 2: Đăng xuất
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
                  ),
                  subtitle: const Text('Thoát khỏi tài khoản cư dân hiện tại', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _confirmLogout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                parentContext,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        residentId: widget.residentId,
        onNavigateTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      HoaDonScreen(residentId: widget.residentId),
      TienIchScreen(residentId: widget.residentId),
      KhieuNaiScreen(residentId: widget.residentId),
      CuDanScreen(residentId: widget.residentId),
    ];

    return BlocProvider(
      create: (context) => HomeCubit()..fetchHomeData(residentId: widget.residentId),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final title = (state is HomeLoaded && state.homeData.resident != null)
              ? state.homeData.resident!.buildingName
              : "Tòa Ruby Suites";
          final subtitle = (state is HomeLoaded && state.homeData.resident != null)
              ? "Căn hộ ${state.homeData.resident!.apartmentNumber}"
              : "Căn hộ RB-0101";

          return Scaffold(
            appBar: CustomAppBar(
              title: title,
              subtitle: subtitle,
              hasUnreadNotification: _hasUnreadNotification,
              onNotificationTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThongBaoScreen(
                      residentId: widget.residentId,
                      onUnreadChanged: (hasUnread) {
                        setState(() {
                          _hasUnreadNotification = hasUnread;
                        });
                      },
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _hasUnreadNotification = result;
                  });
                }
              },
              onProfileTap: () => _showProfileMenu(context, subtitle),
            ),
            backgroundColor: AppColors.background,
            bottomNavigationBar: BottomBar(
              selectedIdx: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
          );
        },
      ),
    );
  }
}
