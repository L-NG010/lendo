import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/screens/router.dart';
import 'package:lendo/screens/auth/login_screen.dart';

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
            return const SplashScreen();
          }
          return state.currentUser != null
              ? const MainRouter()
              : const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
