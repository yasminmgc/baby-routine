import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // Brief delay so the splash is visible
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final token = await _storage.getToken();
    if (!mounted) return;
    if (token != null) {
      context.go('/babies');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lilac,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon
            Icon(
              Icons.child_care,
              size: 96,
              color: AppColors.white,
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Baby Routine',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe a rotina do seu bebê',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
