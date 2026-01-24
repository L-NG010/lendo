import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService();
});

class ActivityService {
  // Dummy data for activities
  final List<Activity> _activities = [
    Activity.createDummy(
      id: '1',
      action: 'create',
      entity: 'assets',
      entityName: 'Laptop Dell XPS 13',
      entityId: '18',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-24 10:30:15',
      description: 'Menambahkan asset baru ke dalam sistem',
      dateTime: DateTime(2026, 1, 24, 10, 30, 15),
    ),
    Activity.createDummy(
      id: '2',
      action: 'update',
      entity: 'users',
      entityName: 'John Doe',
      entityId: '25',
      userId: '1b42bffb-4b4b-5f26-c836-54a2e7c7d6f2',
      userName: 'Jane Smith',
      timestamp: '2026-01-24 09:45:30',
      description: 'Memperbarui informasi pengguna',
      dateTime: DateTime(2026, 1, 24, 9, 45, 30),
    ),
    Activity.createDummy(
      id: '3',
      action: 'delete',
      entity: 'loans',
      entityName: 'Loan #002',
      entityId: '9',
      userId: '2c53cggc-5c5c-6g37-d947-65b3f8d8e7g3',
      userName: 'Mike Johnson',
      timestamp: '2026-01-24 08:20:45',
      description: 'Menghapus pinjaman yang sudah lunas',
      dateTime: DateTime(2026, 1, 24, 8, 20, 45),
    ),
    Activity.createDummy(
      id: '4',
      action: 'create',
      entity: 'categories',
      entityName: 'Office Equipment',
      entityId: '6',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-24 07:15:20',
      description: 'Menambahkan kategori baru untuk peralatan kantor',
      dateTime: DateTime(2026, 1, 24, 7, 15, 20),
    ),
    Activity.createDummy(
      id: '5',
      action: 'update',
      entity: 'assets',
      entityName: 'Printer HP LaserJet',
      entityId: '12',
      userId: '1b42bffb-4b4b-5f26-c836-54a2e7c7d6f2',
      userName: 'Jane Smith',
      timestamp: '2026-01-24 06:30:10',
      description: 'Memperbarui status printer menjadi maintenance',
      dateTime: DateTime(2026, 1, 24, 6, 30, 10),
    ),
    Activity.createDummy(
      id: '6',
      action: 'create',
      entity: 'users',
      entityName: 'Sarah Wilson',
      entityId: '26',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-24 05:45:05',
      description: 'Menambahkan pengguna baru ke sistem',
      dateTime: DateTime(2026, 1, 24, 5, 45, 5),
    ),
    Activity.createDummy(
      id: '7',
      action: 'create',
      entity: 'assets',
      entityName: 'MacBook Pro 16"',
      entityId: '19',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-23 16:20:30',
      description: 'Menambahkan laptop baru untuk departemen IT',
      dateTime: DateTime(2026, 1, 23, 16, 20, 30),
    ),
    Activity.createDummy(
      id: '8',
      action: 'update',
      entity: 'loans',
      entityName: 'Loan #003',
      entityId: '10',
      userId: '1b42bffb-4b4b-5f26-c836-54a2e7c7d6f2',
      userName: 'Jane Smith',
      timestamp: '2026-01-23 14:15:45',
      description: 'Memperbarui status pembayaran pinjaman',
      dateTime: DateTime(2026, 1, 23, 14, 15, 45),
    ),
    Activity.createDummy(
      id: '9',
      action: 'delete',
      entity: 'users',
      entityName: 'Robert Brown',
      entityId: '24',
      userId: '2c53cggc-5c5c-6g37-d947-65b3f8d8e7g3',
      userName: 'Mike Johnson',
      timestamp: '2026-01-23 11:30:20',
      description: 'Menghapus akun pengguna yang tidak aktif',
      dateTime: DateTime(2026, 1, 23, 11, 30, 20),
    ),
    Activity.createDummy(
      id: '10',
      action: 'create',
      entity: 'categories',
      entityName: 'Mobile Devices',
      entityId: '7',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-23 09:45:10',
      description: 'Menambahkan kategori untuk perangkat mobile',
      dateTime: DateTime(2026, 1, 23, 9, 45, 10),
    ),
    Activity.createDummy(
      id: '11',
      action: 'update',
      entity: 'assets',
      entityName: 'Projector Epson',
      entityId: '15',
      userId: '1b42bffb-4b4b-5f26-c836-54a2e7c7d6f2',
      userName: 'Jane Smith',
      timestamp: '2026-01-22 13:20:15',
      description: 'Memperbarui lokasi projector ke ruang meeting A',
      dateTime: DateTime(2026, 1, 22, 13, 20, 15),
    ),
    Activity.createDummy(
      id: '12',
      action: 'create',
      entity: 'loans',
      entityName: 'Loan #004',
      entityId: '11',
      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
      userName: 'Admin User',
      timestamp: '2026-01-22 10:15:30',
      description: 'Membuat pinjaman baru untuk kebutuhan proyek',
      dateTime: DateTime(2026, 1, 22, 10, 15, 30),
    ),
  ];

  List<Activity> getAllActivities() {
    return _activities;
  }

  List<Activity> filterByAction(List<Activity> activities, String action) {
    if (action == 'all') return activities;
    return activities.where((activity) => activity.action == action).toList();
  }

  List<Activity> filterByDateRange(List<Activity> activities, DateTime startDate, DateTime endDate) {
    return activities.where((activity) {
      return activity.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
             activity.dateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Activity> filterByToday(List<Activity> activities) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    return filterByDateRange(activities, startOfDay, endOfDay);
  }

  List<Activity> filterByLast7Days(List<Activity> activities) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return filterByDateRange(activities, sevenDaysAgo, now);
  }

  List<Activity> filterByLast30Days(List<Activity> activities) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return filterByDateRange(activities, thirtyDaysAgo, now);
  }
}