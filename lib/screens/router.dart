import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'admin/dashboard_screen.dart';
import 'borrower/dashboard_screen.dart';
import 'officer/dashboard_screen.dart';

class MainRouter extends ConsumerWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServicePod);
    final userRole = authService.getUserRole();

    switch (userRole) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'officer':
        return const OfficerDashboardScreen();
      case 'borrower':
        return const BorrowerDashboardScreen();
      default:
        return const Scaffold(
          body: Center(
            child: Text('Unknown user role'),
          ),
        );
    }
  }
}