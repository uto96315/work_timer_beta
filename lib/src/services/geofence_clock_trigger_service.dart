import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';
import '../models/workplace.dart';
import '../repositories/time_entry_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../repositories/workplace_repository.dart';

/// The radius, in meters, of the auto clock-in/out geofence around a
/// workplace. Wide enough to absorb typical GPS drift near a building.
const autoClockInGeofenceRadiusMeters = 150.0;

const _geofencePrefix = 'workplace_';

/// Registers/removes a native OS-level geofence per workplace so that
/// clock-in/out can fire even while the app is backgrounded or terminated —
/// see [Workplace.autoClockInLatitude].
///
/// Actual clock-in/out on a geofence event happens in [handleGeofenceEvent],
/// which the OS invokes directly in a background isolate; it does not go
/// through this class.
class GeofenceClockTriggerService {
  Future<void> initialize() async {
    await NativeGeofenceManager.instance.initialize();
  }

  /// Requests the permissions geofencing needs. Must be granted before
  /// [syncGeofence] can succeed — call this from a user-initiated action
  /// (e.g. tapping "register this location"), not silently on launch.
  Future<bool> requestPermissions() async {
    final whenInUse = await Permission.locationWhenInUse.request();
    if (!whenInUse.isGranted) return false;
    final always = await Permission.locationAlways.request();
    return always.isGranted;
  }

  /// Creates/updates the geofence for [workplace] if it has a registered
  /// location, or removes it if the trigger was disabled.
  Future<void> syncGeofence(Workplace workplace) async {
    final id = '$_geofencePrefix${workplace.id}';
    final lat = workplace.autoClockInLatitude;
    final lng = workplace.autoClockInLongitude;
    if (lat == null || lng == null) {
      await NativeGeofenceManager.instance.removeGeofenceById(id);
      return;
    }
    await NativeGeofenceManager.instance.createGeofence(
      Geofence(
        id: id,
        location: Location(latitude: lat, longitude: lng),
        radiusMeters: autoClockInGeofenceRadiusMeters,
        triggers: {GeofenceEvent.enter, GeofenceEvent.exit},
        iosSettings: const IosGeofenceSettings(),
        androidSettings: const AndroidGeofenceSettings(initialTriggers: {}),
      ),
      handleGeofenceEvent,
    );
  }
}

/// Runs in a background isolate — possibly with the app fully terminated —
/// whenever the device enters/exits a registered workplace geofence. Cannot
/// use Riverpod (no widget tree exists here), so it re-initializes Firebase
/// and talks to the repositories directly.
@pragma('vm:entry-point')
Future<void> handleGeofenceEvent(GeofenceCallbackParams params) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final workplaceRepo = WorkplaceRepository(FirebaseFirestore.instance);
  final entryRepo = TimeEntryRepository(FirebaseFirestore.instance);
  final profileRepo = UserProfileRepository(FirebaseFirestore.instance);

  for (final geofence in params.geofences) {
    if (!geofence.id.startsWith(_geofencePrefix)) continue;
    final workplaceId = geofence.id.substring(_geofencePrefix.length);
    final workplace = await workplaceRepo.getPrimary(uid);
    if (workplace == null || workplace.id != workplaceId) continue;

    final now = DateTime.now();
    if (params.event == GeofenceEvent.enter) {
      if (workplace.holidayWeekdays.contains(now.weekday)) continue;
      final activeEntry = await entryRepo.getOpenEntry(uid, workplace.id);
      if (activeEntry != null) continue;
      await entryRepo.clockIn(uid, workplace.id, workplace.breakMinutes);
      await profileRepo.recordWorkedDay(uid, now);
    } else if (params.event == GeofenceEvent.exit) {
      final activeEntry = await entryRepo.getOpenEntry(uid, workplace.id);
      if (activeEntry == null) continue;
      await entryRepo.clockOut(uid, workplace.id, activeEntry.id);
    }
  }
}
