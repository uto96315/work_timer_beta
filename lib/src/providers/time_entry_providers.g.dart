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

@ProviderFor(entriesForDate)
final entriesForDateProvider = EntriesForDateFamily._();

final class EntriesForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TimeEntry>>,
          List<TimeEntry>,
          Stream<List<TimeEntry>>
        >
    with $FutureModifier<List<TimeEntry>>, $StreamProvider<List<TimeEntry>> {
  EntriesForDateProvider._({
    required EntriesForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'entriesForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entriesForDateHash();

  @override
  String toString() {
    return r'entriesForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TimeEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TimeEntry>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return entriesForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EntriesForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entriesForDateHash() => r'8dd377a2fdb680b7f46b3f71a93dbb50a5255dda';

final class EntriesForDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TimeEntry>>, DateTime> {
  EntriesForDateFamily._()
    : super(
        retry: null,
        name: r'entriesForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EntriesForDateProvider call(DateTime date) =>
      EntriesForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'entriesForDateProvider';
}

/// [end] is exclusive.

@ProviderFor(entriesInRange)
final entriesInRangeProvider = EntriesInRangeFamily._();

/// [end] is exclusive.

final class EntriesInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TimeEntry>>,
          List<TimeEntry>,
          Stream<List<TimeEntry>>
        >
    with $FutureModifier<List<TimeEntry>>, $StreamProvider<List<TimeEntry>> {
  /// [end] is exclusive.
  EntriesInRangeProvider._({
    required EntriesInRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'entriesInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entriesInRangeHash();

  @override
  String toString() {
    return r'entriesInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<TimeEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TimeEntry>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return entriesInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EntriesInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entriesInRangeHash() => r'43a3d98b305616f66affda56c2871ed0dbef65f0';

/// [end] is exclusive.

final class EntriesInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TimeEntry>>,
          (DateTime, DateTime)
        > {
  EntriesInRangeFamily._()
    : super(
        retry: null,
        name: r'entriesInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [end] is exclusive.

  EntriesInRangeProvider call(DateTime start, DateTime end) =>
      EntriesInRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'entriesInRangeProvider';
}

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

String _$liveEarningsHash() => r'494e0e70c375ecabccf1d9c5a8280fc462971570';
