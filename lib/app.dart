import 'package:flutter/material.dart';

import 'layouts/main_layout.dart';
import 'theme/app_colors.dart';

class RobotApp extends StatelessWidget {
  const RobotApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'agbot control',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        primary: AppColors.accent,
      ),
      useMaterial3: true,
    ),
    home: const MainLayout(),
  );
}
