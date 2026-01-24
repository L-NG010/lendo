class LoanModel {
  final String id;
  final String userId;
  final String status;
  final String dueDate;
  final String? returnedAt;
  final String? lateDays;
  final String createdAt;
  final String loanDate;
  final String? reason;

  LoanModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.dueDate,
    this.returnedAt,
    this.lateDays,
    required this.createdAt,
    required this.loanDate,
    this.reason,
  });

  // Factory method to create from JSON
  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      status: json['status'] ?? '',
      dueDate: json['due_date'] ?? '',
      returnedAt: json['returned_at'],
      lateDays: json['late_days'],
      createdAt: json['created_at'] ?? '',
      loanDate: json['loan_date'] ?? '',
      reason: json['reason'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'due_date': dueDate,
      'returned_at': returnedAt,
      'late_days': lateDays,
      'created_at': createdAt,
      'loan_date': loanDate,
      'reason': reason,
    };
  }
}

class LoanDetailModel {
  final String id;
  final String loanId;
  final String assetId;
  final String condBorrow;
  final String? condReturn;

  LoanDetailModel({
    required this.id,
    required this.loanId,
    required this.assetId,
    required this.condBorrow,
    this.condReturn,
  });

  // Factory method to create from JSON
  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    return LoanDetailModel(
      id: json['id'] ?? '',
      loanId: json['loan_id'] ?? '',
      assetId: json['asset_id'] ?? '',
      condBorrow: json['cond_borrow'] ?? '',
      condReturn: json['cond_return'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'asset_id': assetId,
      'cond_borrow': condBorrow,
      'cond_return': condReturn,
    };
  }
}