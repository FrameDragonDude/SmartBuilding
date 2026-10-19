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

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(residentId: widget.residentId),
      const HoaDonScreen(),
      const TienIchScreen(),
      const KhieuNaiScreen(),
      const CuDanScreen(),
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
