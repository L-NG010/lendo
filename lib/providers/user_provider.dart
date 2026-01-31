import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:lendo/models/user_model.dart';
import 'package:lendo/services/user_service.dart';
import 'package:lendo/services/auth_service.dart';

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Async notifier for users list
class UsersNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() async {
    final userService = ref.read(userServiceProvider);
    return await userService.getAllUsers();
  }

  // Refresh users
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userService = ref.read(userServiceProvider);
      return await userService.getAllUsers();
    });
  }

  // Quick refresh without loading state
  void quickRefresh() {
    ref.invalidateSelf();
  }

  // Add new user
  Future<void> addUser({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
  }) async {
    try {
      final userService = ref.read(userServiceProvider);

      final newUser = await userService.createUser(
        email: email,
        password: password,
        role: role,
        name: name, // ✅ DO NOT OVERRIDE
        phone: phone,
      );

      state = await AsyncValue.guard(() async {
        final currentUsers = state.value ?? [];
        return [newUser, ...currentUsers];
      });
    } catch (e) {
      rethrow;
    }
  }

  // ✅ UPDATE USER (ADD PHONE SUPPORT)
  Future<void> updateUser({
    required String id,
    String? email,
    String? name,
    String? role,
    String? phone,
    bool? isActive,
  }) async {
    try {
      final userService = ref.read(userServiceProvider);

      final updatedUser = await userService.updateUser(
        id: id,
        email: email,
        name: name,
        role: role,
        phone: phone,
        isActive: isActive,
      );

      state = await AsyncValue.guard(() async {
        final currentUsers = state.value ?? [];
        return currentUsers.map((u) => u.id == id ? updatedUser : u).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.deleteUser(id);

      // Remove user from state - immediate UI update
      state = await AsyncValue.guard(() async {
        final currentUsers = state.value ?? [];
        return currentUsers.where((user) => user.id != id).toList();
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }
}

// Provider for users list
final usersProvider =
    AsyncNotifierProvider.autoDispose<UsersNotifier, List<UserModel>>(
      UsersNotifier.new,
    );

// Selected role filter
class RoleFilterState {
  final String selectedRole;
  final String searchQuery;

  RoleFilterState({this.selectedRole = 'All', this.searchQuery = ''});

  RoleFilterState copyWith({String? selectedRole, String? searchQuery}) {
    return RoleFilterState(
      selectedRole: selectedRole ?? this.selectedRole,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RoleFilterNotifier extends Notifier<RoleFilterState> {
  Timer? _debounceTimer;

  @override
  RoleFilterState build() {
    return RoleFilterState();
  }

  void setSelectedRole(String role) {
    state = state.copyWith(selectedRole: role);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void debouncedSetSearchQuery(String query, int milliseconds) {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Set up new timer
    _debounceTimer = Timer(Duration(milliseconds: milliseconds), () {
      state = state.copyWith(searchQuery: query);
    });
  }
}

final roleFilterProvider =
    NotifierProvider<RoleFilterNotifier, RoleFilterState>(
      RoleFilterNotifier.new,
    );

final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final usersAsync = ref.watch(usersProvider);
  final filterState = ref.watch(roleFilterProvider);
  final authService = ref.watch(authServicePod);
  final currentUser = authService.getCurrentUser();

  return usersAsync.when(
    data: (users) {
      var filtered = users;

      // Exclude current logged-in admin
      if (currentUser != null) {
        filtered = filtered.where((user) => user.id != currentUser.id).toList();
      }

      // Filter by role
      if (filterState.selectedRole != 'All') {
        filtered = filtered
            .where(
              (user) =>
                  user.rawUserMetadata['role'] == filterState.selectedRole,
            )
            .toList();
      }

      // Filter by search query (name and email)
      if (filterState.searchQuery.isNotEmpty) {
        final query = filterState.searchQuery.toLowerCase().trim();
        filtered = filtered.where((user) {
          final name = (user.rawUserMetadata['name'] as String? ?? '')
              .toLowerCase();
          final email = user.email.toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});
