// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firestore)
final firestoreProvider = FirestoreProvider._();

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'864285def6284159b44f9598dcde96347e0c1dce';

@ProviderFor(firebaseAuth)
final firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

/// Signs the user in anonymously on first launch and exposes auth state.
///
/// Anonymous auth means no signup friction; the uid is what scopes every
/// Firestore document, matching the security rules in firestore.rules.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Signs the user in anonymously on first launch and exposes auth state.
///
/// Anonymous auth means no signup friction; the uid is what scopes every
/// Firestore document, matching the security rules in firestore.rules.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Signs the user in anonymously on first launch and exposes auth state.
  ///
  /// Anonymous auth means no signup friction; the uid is what scopes every
  /// Firestore document, matching the security rules in firestore.rules.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'f73de12e44018fcae84f1be356b6d29b5b06c34f';

@ProviderFor(workplaceRepository)
final workplaceRepositoryProvider = WorkplaceRepositoryProvider._();

final class WorkplaceRepositoryProvider
    extends
        $FunctionalProvider<
          WorkplaceRepository,
          WorkplaceRepository,
          WorkplaceRepository
        >
    with $Provider<WorkplaceRepository> {
  WorkplaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workplaceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workplaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkplaceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkplaceRepository create(Ref ref) {
    return workplaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkplaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkplaceRepository>(value),
    );
  }
}

String _$workplaceRepositoryHash() =>
    r'21d49a88a12b87c410b21d22518a24363266c810';

@ProviderFor(timeEntryRepository)
final timeEntryRepositoryProvider = TimeEntryRepositoryProvider._();

final class TimeEntryRepositoryProvider
    extends
        $FunctionalProvider<
          TimeEntryRepository,
          TimeEntryRepository,
          TimeEntryRepository
        >
    with $Provider<TimeEntryRepository> {
  TimeEntryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeEntryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeEntryRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimeEntryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TimeEntryRepository create(Ref ref) {
    return timeEntryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeEntryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeEntryRepository>(value),
    );
  }
}

String _$timeEntryRepositoryHash() =>
    r'dd9ec765424c23377d2852531977764728f0aa20';
