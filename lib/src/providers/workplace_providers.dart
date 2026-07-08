import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/workplace.dart';
import 'auth_providers.dart';
import 'firebase_providers.dart';

part 'workplace_providers.g.dart';

@riverpod
Stream<Workplace?> primaryWorkplace(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(workplaceRepositoryProvider).watchPrimary(uid);
}
