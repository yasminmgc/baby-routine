import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/babies/presentation/caregivers_screen.dart';
import 'features/babies/presentation/create_baby_screen.dart';
import 'features/babies/presentation/edit_baby_screen.dart';
import 'features/babies/presentation/select_baby_screen.dart';
import 'features/events/presentation/appointment_screen.dart';
import 'features/events/presentation/bath_screen.dart';
import 'features/events/presentation/diaper_screen.dart';
import 'features/events/presentation/feeding_screen.dart';
import 'features/events/presentation/medication_screen.dart';
import 'features/events/presentation/sleep_screen.dart';
import 'features/events/presentation/vaccination_screen.dart';
import 'features/health/presentation/health_history_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/notes/presentation/notes_screen.dart';
import 'features/reports/presentation/reports_screen.dart';
import 'features/routines/presentation/configure_routines_screen.dart';

final _secureStorage = SecureStorage();

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final token = await _secureStorage.getToken();
    final isLoggedIn = token != null;
    final location = state.matchedLocation;
    final publicRoutes = ['/splash', '/login', '/register'];

    // Redirect authenticated users away from login/register/splash
    if (isLoggedIn && publicRoutes.contains(location)) {
      return '/babies';
    }

    // Redirect unauthenticated users to /login
    if (!isLoggedIn && !publicRoutes.contains(location)) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/babies',
      builder: (_, __) => const SelectBabyScreen(),
    ),
    GoRoute(
      path: '/babies/create',
      builder: (_, __) => const CreateBabyScreen(),
    ),
    GoRoute(
      path: '/babies/edit',
      builder: (_, __) => const EditBabyScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/feeding',
      builder: (_, __) => const FeedingScreen(),
    ),
    GoRoute(
      path: '/sleep',
      builder: (_, __) => const SleepScreen(),
    ),
    GoRoute(
      path: '/diaper',
      builder: (_, __) => const DiaperScreen(),
    ),
    GoRoute(
      path: '/bath',
      builder: (_, __) => const BathScreen(),
    ),
    GoRoute(
      path: '/appointment',
      builder: (_, __) => const AppointmentScreen(),
    ),
    GoRoute(
      path: '/vaccination',
      builder: (_, __) => const VaccinationScreen(),
    ),
    GoRoute(
      path: '/medication',
      builder: (_, __) => const MedicationScreen(),
    ),
    GoRoute(
      path: '/routines',
      builder: (_, __) => const ConfigureRoutinesScreen(),
    ),
    GoRoute(
      path: '/health',
      builder: (_, __) => const HealthHistoryScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (_, __) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/notes',
      builder: (_, __) => const NotesScreen(),
    ),
    GoRoute(
      path: '/caregivers',
      builder: (_, __) => const CaregiversScreen(),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Baby Routine',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lilac),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.lightGray,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lilacDark,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ),
    );
  }
}
