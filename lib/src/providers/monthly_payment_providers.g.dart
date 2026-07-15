// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthlyPayments)
final monthlyPaymentsProvider = MonthlyPaymentsProvider._();

final class MonthlyPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyPayment>>,
          List<MonthlyPayment>,
          Stream<List<MonthlyPayment>>
        >
    with
        $FutureModifier<List<MonthlyPayment>>,
        $StreamProvider<List<MonthlyPayment>> {
  MonthlyPaymentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyPaymentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyPaymentsHash();

  @$internal
  @override
  $StreamProviderElement<List<MonthlyPayment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MonthlyPayment>> create(Ref ref) {
    return monthlyPayments(ref);
  }
}

String _$monthlyPaymentsHash() => r'de6edb6753576eefbc429913a8d74540e9cc5a91';
