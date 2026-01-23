import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/screens/auth/login_screen.dart';
import 'package:lendo/screens/admin/dashboard_screen.dart';
import 'package:lendo/screens/officer/dashboard_screen.dart';
import 'package:lendo/screens/borrower/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lendo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          onSurfaceVariant: AppColors.gray,
          outline: AppColors.lightGreen,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: authState.when(
        data: (state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (state.currentUser != null) {
            // User logged in, redirect to appropriate dashboard based on role
            final authService = AuthService();
            final userRole = authService.getUserRole();
            
            switch (userRole) {
              case 'admin':
                return const AdminDashboardScreen();
              case 'officer':
                return const OfficerDashboardScreen();
              case 'borrower':
                return const BorrowerDashboardScreen();
              default:
                // Invalid role, redirect to login
                return const LoginScreen();
            }
          } else {
            // No user logged in, show login screen
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}