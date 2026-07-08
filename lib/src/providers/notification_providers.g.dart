// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with an instance that has already had
/// [NotificationService.init] called on it.

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Overridden in `main.dart` with an instance that has already had
/// [NotificationService.init] called on it.

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// Overridden in `main.dart` with an instance that has already had
  /// [NotificationService.init] called on it.
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'169e0e270c3c6610fb9e6c201b082c2388a8f63c';

/// Watching this anywhere keeps the scheduled reminders in sync with the
/// current workplace hours and notification preferences.

@ProviderFor(notificationSync)
final notificationSyncProvider = NotificationSyncProvider._();

/// Watching this anywhere keeps the scheduled reminders in sync with the
/// current workplace hours and notification preferences.

final class NotificationSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Watching this anywhere keeps the scheduled reminders in sync with the
  /// current workplace hours and notification preferences.
  NotificationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return notificationSync(ref);
  }
}

String _$notificationSyncHash() => r'4b045b23099ccd19148fc0b01c9521e8f5970df7';
