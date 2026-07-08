import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/time_entry_repository.dart';
import '../repositories/workplace_repository.dart';

part 'firebase_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Signs the user in anonymously on first launch and exposes auth state.
///
/// Anonymous auth means no signup friction; the uid is what scopes every
/// Firestore document, matching the security rules in firestore.rules.
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth.currentUser == null) {
    auth.signInAnonymously();
  }
  return auth.authStateChanges();
}

@Riverpod(keepAlive: true)
WorkplaceRepository workplaceRepository(Ref ref) =>
    WorkplaceRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
TimeEntryRepository timeEntryRepository(Ref ref) =>
    TimeEntryRepository(ref.watch(firestoreProvider));
