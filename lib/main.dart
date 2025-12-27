import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bondhu/core/di/dependency_injector.dart';
import 'package:bondhu/firebase_options.dart';
import 'package:bondhu/core/init/app_widget.dart';
import 'package:bondhu/core/config/env_config.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<FirebaseApp> _initializeFirebase() async {
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      return Firebase.app(); // Return existing app instance
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await _initializeFirebase();

  // Load environment variables
  await EnvConfig.instance.initialize();

  // Setup dependency injection
  injectionSetup();

  // Initialize hydrated storage for state persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  runApp(const AppWidget());
}
