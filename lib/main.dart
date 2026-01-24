import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/screens/auth/login.dart';
import 'package:lendo/screens/admin/dashboard_screen.dart';
import 'package:lendo/screens/admin/log_activity_screen.dart';
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
    // Check for existing session
    final authService = ref.watch(authServicePod);
    final currentUser = authService.getCurrentUser();
    
    String initialRoute = '/login';
    if (currentUser != null) {
      // User has active session, redirect to appropriate dashboard
      final userRole = authService.getUserRole();
      switch (userRole) {
        case 'admin':
          initialRoute = '/admin-dashboard';
          break;
        case 'officer':
          initialRoute = '/officer-dashboard';
          break;
        case 'borrower':
          initialRoute = '/borrower-dashboard';
          break;
        default:
          initialRoute = '/login';
      }
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lendo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/officer-dashboard': (context) => const OfficerDashboardScreen(),
        '/borrower-dashboard': (context) => const BorrowerDashboardScreen(),
        '/log-activities': (context) => const LogActivityScreen(),
      },
    );
  }
}