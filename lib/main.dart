import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/remanence_app.dart';
import 'data/data_providers.dart';
import 'data/database/remanence_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = RemanenceDatabase.open();
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const RemanenceApp(),
    ),
  );
}
