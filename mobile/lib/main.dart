import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/presentation/common%20widgets/bottom_bar.dart';
import 'package:mobile/presentation/common%20widgets/custom_app_bar.dart';
import 'package:mobile/presentation/screen/cu_dan_screen/cu_dan_screen.dart';
import 'package:mobile/presentation/screen/hoa_don_screen/hoa_don_screen.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HoaDonScreen(),
    TienIchScreen(),
    KhieuNaiScreen(),
    CuDanScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Building',
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: CustomAppBar(),
        backgroundColor: AppColors.textSecondary,
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
          children: _screens,
        ),
      ),
    );
  }
}

