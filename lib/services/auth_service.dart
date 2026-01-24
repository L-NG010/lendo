import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final session = data.session;
      return AuthState(
        currentUser: session?.user,
        isLoading: false,
      );
    });
  }

  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Tunggu sebentar untuk memastikan metadata sudah termuat
        await Future.delayed(const Duration(milliseconds: 100));
        return AuthState(currentUser: response.user);
      } else {
        return AuthState(errorMessage: 'Invalid credentials');
      }
    } on AuthException catch (e) {
      return AuthState(errorMessage: e.message);
    } catch (e) {
      return AuthState(errorMessage: 'An error occurred during sign in');
    }
  }

  Future<AuthState> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
      
      if (response.user != null) {
        return AuthState(currentUser: response.user);
      } else {
        return AuthState(errorMessage: 'Failed to create account');
      }
    } on AuthException catch (e) {
      return AuthState(errorMessage: e.message);
    } catch (e) {
      return AuthState(errorMessage: 'An error occurred during sign up');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getUserRole() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    // Ambil role dari user metadata
    String? role = user.userMetadata?['role'] as String?;
    
    return role;
  }
  
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  bool isAdmin() => getUserRole() == 'admin';
  bool isOfficer() => getUserRole() == 'officer';
  bool isBorrower() => getUserRole() == 'borrower';
}

final authServiceProvider = StreamProvider<AuthState>((ref) {
  final authService = AuthService();
  return authService.authStateChanges;
});

final authServicePod = Provider<AuthService>((ref) {
  return AuthService();
});