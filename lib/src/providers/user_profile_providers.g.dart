// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfile)
final userProfileProvider = UserProfileProvider._();

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile>,
          UserProfile,
          Stream<UserProfile>
        >
    with $FutureModifier<UserProfile>, $StreamProvider<UserProfile> {
  UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  $StreamProviderElement<UserProfile> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile> create(Ref ref) {
    return userProfile(ref);
  }
}

String _$userProfileHash() => r'3ca35f2f382676531ffb13637cea563a28b32eaa';
