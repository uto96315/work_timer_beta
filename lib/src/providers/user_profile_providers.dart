import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_profile.dart';
import 'auth_providers.dart';
import 'firebase_providers.dart';

part 'user_profile_providers.g.dart';

@riverpod
Stream<UserProfile> userProfile(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(userProfileRepositoryProvider).watch(uid);
}
