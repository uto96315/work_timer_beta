// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with an instance that has already had
/// [WidgetSyncService.init] called on it.

@ProviderFor(widgetSyncService)
final widgetSyncServiceProvider = WidgetSyncServiceProvider._();

/// Overridden in `main.dart` with an instance that has already had
/// [WidgetSyncService.init] called on it.

final class WidgetSyncServiceProvider
    extends
        $FunctionalProvider<
          WidgetSyncService,
          WidgetSyncService,
          WidgetSyncService
        >
    with $Provider<WidgetSyncService> {
  /// Overridden in `main.dart` with an instance that has already had
  /// [WidgetSyncService.init] called on it.
  WidgetSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetSyncServiceHash();

  @$internal
  @override
  $ProviderElement<WidgetSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WidgetSyncService create(Ref ref) {
    return widgetSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WidgetSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WidgetSyncService>(value),
    );
  }
}

String _$widgetSyncServiceHash() => r'733940c1faa4151a426976e6861d486c34b18a82';

/// Watching this anywhere keeps the iOS home-screen widget's shared data in
/// sync with today's workplace hours and clock-in/out state.

@ProviderFor(widgetSync)
final widgetSyncProvider = WidgetSyncProvider._();

/// Watching this anywhere keeps the iOS home-screen widget's shared data in
/// sync with today's workplace hours and clock-in/out state.

final class WidgetSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Watching this anywhere keeps the iOS home-screen widget's shared data in
  /// sync with today's workplace hours and clock-in/out state.
  WidgetSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return widgetSync(ref);
  }
}

String _$widgetSyncHash() => r'8469d12a7b7769c5addfc26c1a00528491b964cb';
