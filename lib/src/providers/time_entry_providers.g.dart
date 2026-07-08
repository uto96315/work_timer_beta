// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeTimeEntry)
final activeTimeEntryProvider = ActiveTimeEntryProvider._();

final class ActiveTimeEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TimeEntry?>,
          TimeEntry?,
          Stream<TimeEntry?>
        >
    with $FutureModifier<TimeEntry?>, $StreamProvider<TimeEntry?> {
  ActiveTimeEntryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTimeEntryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTimeEntryHash();

  @$internal
  @override
  $StreamProviderElement<TimeEntry?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<TimeEntry?> create(Ref ref) {
    return activeTimeEntry(ref);
  }
}

String _$activeTimeEntryHash() => r'c6c32226ba3937a014f20adbb791c501578f0745';

/// Ticks once a second so the live earnings counter can redraw. Kept
/// separate from [activeTimeEntryProvider] so the Firestore stream doesn't
/// need to re-fire every second.

@ProviderFor(secondTicker)
final secondTickerProvider = SecondTickerProvider._();

/// Ticks once a second so the live earnings counter can redraw. Kept
/// separate from [activeTimeEntryProvider] so the Firestore stream doesn't
/// need to re-fire every second.

final class SecondTickerProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Ticks once a second so the live earnings counter can redraw. Kept
  /// separate from [activeTimeEntryProvider] so the Firestore stream doesn't
  /// need to re-fire every second.
  SecondTickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secondTickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secondTickerHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return secondTicker(ref);
  }
}

String _$secondTickerHash() => r'fc737c0ef0fb4b2417699611041a5ecd1a134bb3';

@ProviderFor(liveEarnings)
final liveEarningsProvider = LiveEarningsProvider._();

final class LiveEarningsProvider
    extends
        $FunctionalProvider<EarningsResult?, EarningsResult?, EarningsResult?>
    with $Provider<EarningsResult?> {
  LiveEarningsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveEarningsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveEarningsHash();

  @$internal
  @override
  $ProviderElement<EarningsResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EarningsResult? create(Ref ref) {
    return liveEarnings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EarningsResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EarningsResult?>(value),
    );
  }
}

String _$liveEarningsHash() => r'3b7e6f9ea2e120c19fec9730929799488677ef48';
