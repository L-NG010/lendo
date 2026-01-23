import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        foregroundColor: Colors.white,
      ),
      drawer: const CustomSidebar(),
      body: const Center(
        child: Text(
          'Welcome to Admin Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ),
        ),
      ),
    );
  }
}