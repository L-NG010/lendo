import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/services/borrower/return_service.dart';

final returnServiceProvider = Provider<ReturnService>((ref) {
  return ReturnService();
});
