import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/services/loan_service.dart';
import 'package:lendo/services/auth_service.dart';

// Loan service provider
final loanServiceProvider = Provider<LoanService>((ref) {
  return LoanService();
});

// Async notifier for loans list
class LoansNotifier extends AsyncNotifier<List<LoanModel>> {
  @override
  Future<List<LoanModel>> build() async {
    final loanService = ref.read(loanServiceProvider);
    return await loanService.getAllLoans();
  }

  // Refresh loans
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loanService = ref.read(loanServiceProvider);
      return await loanService.getAllLoans();
    });
  }

  // Add new loan
  Future<void> addLoan({
    required String userId,
    required String status,
    required String dueDate,
    required String loanDate,
    String? reason,
    List<Map<String, dynamic>>? loanDetails,
  }) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      final newLoan = await loanService.createLoan(
        userId: userId,
        status: status,
        dueDate: dueDate,
        loanDate: loanDate,
        reason: reason,
        loanDetails: loanDetails,
      );

      // Update state with new loan
      state.whenData((loans) {
        state = AsyncData([newLoan, ...loans]);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update existing loan
  Future<void> updateLoan({
    required String id,
    String? userId,
    String? status,
    String? dueDate,
    String? returnedAt,
    String? loanDate,
    String? reason,
  }) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      final updatedLoan = await loanService.updateLoan(
        id: id,
        userId: userId,
        status: status,
        dueDate: dueDate,
        returnedAt: returnedAt,
        loanDate: loanDate,
        reason: reason,
      );

      // Update state with modified loan
      state.whenData((loans) {
        final index = loans.indexWhere((loan) => loan.id == id);
        if (index != -1) {
          final updatedLoans = [...loans];
          updatedLoans[index] = updatedLoan;
          state = AsyncData(updatedLoans);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Mark loan as returned
  Future<void> markLoanReturned(String id) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      final updatedLoan = await loanService.markLoanReturned(id: id);

      // Update state with modified loan
      state.whenData((loans) {
        final index = loans.indexWhere((loan) => loan.id == id);
        if (index != -1) {
          final updatedLoans = [...loans];
          updatedLoans[index] = updatedLoan;
          state = AsyncData(updatedLoans);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete loan
  Future<void> deleteLoan(String id) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      await loanService.deleteLoan(id);

      // Remove loan from state
      state.whenData((loans) {
        state = AsyncData(loans.where((loan) => loan.id != id).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add loan details
  Future<void> addLoanDetails({
    required String loanId,
    required String assetId,
    required String condBorrow,
    String? condReturn,
  }) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      await loanService.updateLoanDetails(
        loanId: loanId,
        assetId: assetId,
        condBorrow: condBorrow,
        condReturn: condReturn,
      );

      // Refresh the loan details
      state.whenData((loans) {
        final index = loans.indexWhere((loan) => loan.id == loanId);
        if (index != -1) {
          // Note: We can't update loan details directly here since we don't store them in the loan model
          // The details will be loaded separately when needed
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get loan details
  Future<List<LoanDetailModel>> getLoanDetails(String loanId) async {
    final loanService = ref.read(loanServiceProvider);
    return await loanService.getLoanDetails(loanId);
  }

  // Create loan details
  Future<void> createLoanDetails({
    required String loanId,
    required String assetId,
    String? condBorrow,
    String? condReturn,
  }) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      await loanService.createLoanDetails(
        loanId: loanId,
        assetId: assetId,
        condBorrow: condBorrow,
        condReturn: condReturn,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Delete loan details
  Future<void> deleteLoanDetails({
    required String loanId,
    required String assetId,
  }) async {
    try {
      final loanService = ref.read(loanServiceProvider);
      await loanService.deleteLoanDetails(loanId: loanId, assetId: assetId);
    } catch (e) {
      rethrow;
    }
  }

  // Search loans
  Future<void> searchLoans(String query) async {
    if (query.isEmpty) {
      refresh();
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loanService = ref.read(loanServiceProvider);
      return await loanService.searchLoans(query);
    });
  }

  // Filter by status
  Future<void> filterByStatus(String status) async {
    if (status == 'All') {
      refresh();
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loanService = ref.read(loanServiceProvider);
      return await loanService.getLoansByStatus(status);
    });
  }
}

// Main loans provider
final loansProvider = AsyncNotifierProvider<LoansNotifier, List<LoanModel>>(() {
  return LoansNotifier();
});

// Simple state management using Notifier pattern
class LoanFilterState {
  final String selectedStatus;
  final String searchQuery;

  LoanFilterState({this.selectedStatus = 'All', this.searchQuery = ''});

  LoanFilterState copyWith({String? selectedStatus, String? searchQuery}) {
    return LoanFilterState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LoanFilterNotifier extends Notifier<LoanFilterState> {
  @override
  LoanFilterState build() {
    return LoanFilterState();
  }

  void setSelectedStatus(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = LoanFilterState();
  }
}

// Filter notifier provider
final loanFilterProvider =
    NotifierProvider<LoanFilterNotifier, LoanFilterState>(
      LoanFilterNotifier.new,
    );

// Filtered loans provider
final filteredLoansProvider = Provider<List<LoanModel>>((ref) {
  final loansAsync = ref.watch(loansProvider);
  final filterState = ref.watch(loanFilterProvider);

  return loansAsync.when(
    data: (loans) {
      // Apply status filter
      List<LoanModel> filtered = loans;
      if (filterState.selectedStatus != 'All') {
        filtered = loans
            .where((loan) => loan.status == filterState.selectedStatus)
            .toList();
      }

      // Apply search filter
      if (filterState.searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (loan) => loan.id.toLowerCase().contains(
                filterState.searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for current user's approved loans
final userApprovedLoansProvider = FutureProvider.autoDispose<List<LoanModel>>((
  ref,
) async {
  final authService = ref.watch(authServicePod);
  final user = authService.getCurrentUser();

  if (user == null) return [];

  final loanService = ref.watch(loanServiceProvider);
  // Fetch all loans for the user then filter locally or use a specific service method if available
  // Using getLoansForUser which fetches details too
  final loans = await loanService.getLoansForUser(user.id);

  // Filter for approved loans that haven't been returned yet (returned_at is null)
  return loans
      .where((loan) => loan.status == 'approved' && loan.returnedAt == null)
      .toList();
});
