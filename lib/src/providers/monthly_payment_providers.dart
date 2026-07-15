import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/monthly_payment.dart';
import 'auth_providers.dart';
import 'firebase_providers.dart';
import 'workplace_providers.dart';

part 'monthly_payment_providers.g.dart';

@riverpod
Stream<List<MonthlyPayment>> monthlyPayments(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  if (uid == null || workplace == null) return const Stream.empty();
  return ref.watch(monthlyPaymentRepositoryProvider).watchForWorkplace(uid, workplace.id);
}
