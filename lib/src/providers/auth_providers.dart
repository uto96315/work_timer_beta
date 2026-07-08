import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_providers.dart';

part 'auth_providers.g.dart';

@riverpod
String? currentUid(Ref ref) {
  return ref.watch(authStateProvider).value?.uid;
}
