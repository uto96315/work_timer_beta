import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'src/app.dart';

/// Run with `--dart-define=USE_FIREBASE_EMULATOR=true` to point Auth and
/// Firestore at the local Firebase Emulator Suite (`firebase emulators:start`)
/// instead of production. Useful when the real googleapis.com endpoints are
/// unreachable, e.g. behind a corporate proxy that the simulator doesn't trust.
const _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('ja_JP');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8090);
  }

  runApp(const ProviderScope(child: WorkTimerApp()));
}
