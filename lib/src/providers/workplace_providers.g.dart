// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(primaryWorkplace)
final primaryWorkplaceProvider = PrimaryWorkplaceProvider._();

final class PrimaryWorkplaceProvider
    extends
        $FunctionalProvider<
          AsyncValue<Workplace?>,
          Workplace?,
          Stream<Workplace?>
        >
    with $FutureModifier<Workplace?>, $StreamProvider<Workplace?> {
  PrimaryWorkplaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'primaryWorkplaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$primaryWorkplaceHash();

  @$internal
  @override
  $StreamProviderElement<Workplace?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Workplace?> create(Ref ref) {
    return primaryWorkplace(ref);
  }
}

String _$primaryWorkplaceHash() => r'219b6651dbb710687c28a844bc426c5b724a565f';
