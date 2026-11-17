import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of the random draws (asked face).
/// Overridden by tests with a seeded generator.
final randomProvider = Provider<Random>((ref) => Random());
