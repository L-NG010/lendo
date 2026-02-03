import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/services/officer/request.dart';

final officerRequestServiceProvider = Provider<OfficerRequestService>((ref) {
  return OfficerRequestService();
});
