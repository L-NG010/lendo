import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import 'package:lendo/config/app_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Image Section
              SvgPicture.asset(
                'assets/images/lendo_login.svg',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              // Email Field
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.secondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outline,
                    ),
                  ),
                  hintText: 'Input Email',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password Field
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Password',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.secondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outline,
                    ),
                  ),
                  hintText: 'Input Password',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.gray,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final authService = ref.read(authServicePod);
                    final state = await authService.signIn(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );
                    
                    if (state.errorMessage != null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                      }
                    } else {
// Login sukses, cek role dan arahkan ke halaman sesuai role
                      await Future.delayed(const Duration(milliseconds: 500)); // Beri sedikit delay agar metadata user tersedia
                      
                      final userRole = authService.getUserRole();
                      String route;
                      
                      switch (userRole) {
                        case 'admin':
                          route = '/admin-dashboard';
                          break;
                        case 'officer':
                          route = '/officer-dashboard';
                          break;
                        case 'borrower':
                          route = '/borrower-dashboard';
                          break;
                        default:
                          // Jika role tidak dikenal, tetap di login
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Role tidak dikenal')),
                            );
                          }
                          return;
                      }
                      
                      // Pindah ke halaman sesuai role dengan pushNamedAndRemoveUntil
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}