import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/services/profile_service.dart';

// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Async notifier for profiles list
class ProfilesNotifier extends AsyncNotifier<List<UserProfile>> {
  @override
  Future<List<UserProfile>> build() async {
    final profileService = ref.read(profileServiceProvider);
    return await profileService.getAllProfiles();
  }

  // Refresh profiles
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profileService = ref.read(profileServiceProvider);
      return await profileService.getAllProfiles();
    });
  }
}

// Provider for profiles list
final profilesProvider =
    AsyncNotifierProvider<ProfilesNotifier, List<UserProfile>>(
      ProfilesNotifier.new,
    );
