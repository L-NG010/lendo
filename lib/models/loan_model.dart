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
  final String? officerReason;
  final double? penaltyAmount;
  final String? userName;

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
    this.officerReason,
    this.penaltyAmount,
    this.userName,
  });

  // Factory method to create from JSON
  factory LoanModel.fromJson(Map<String, dynamic> json) {
    // Calculate total penalty amount if penalties exist
    double? totalPenalty;
    if (json['penalties'] != null && (json['penalties'] as List).isNotEmpty) {
      totalPenalty = (json['penalties'] as List).fold<double>(
        0,
        (sum, item) => sum + (num.tryParse(item['amount'].toString()) ?? 0).toDouble(),
      );
    }
    
    // Parse user name from profiles
    String? name;
    if (json['profiles'] != null) {
      name = json['profiles']['name']?.toString();
    }

    return LoanModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      returnedAt: json['returned_at']?.toString(),
      lateDays: json['late_days']?.toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      loanDate: (json['loan_date'] ?? '').toString(),
      reason: json['reason']?.toString(),
      officerReason: json['officer_reason']?.toString(),
      penaltyAmount: totalPenalty,
      userName: name,
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
      'officer_reason': officerReason,
    };
  }
}

class LoanDetailModel {
  final String id;
  final String loanId;
  final String assetId;
  final String condBorrow;
  final String? condReturn;
  final String? assetName;

  LoanDetailModel({
    required this.id,
    required this.loanId,
    required this.assetId,
    required this.condBorrow,
    this.condReturn,
    this.assetName,
  });

  // Factory method to create from JSON
  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    return LoanDetailModel(
      id: (json['id'] ?? '').toString(),
      loanId: (json['loan_id'] ?? '').toString(),
      assetId: (json['asset_id'] ?? '').toString(),
      condBorrow: (json['cond_borrow'] ?? '').toString(),
      condReturn: json['cond_return']?.toString(),
      assetName: json['assets'] != null
          ? json['assets']['name']?.toString()
          : null,
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
      'asset_name': assetName,
    };
  }
}
