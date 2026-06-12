import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/babies/models/baby.dart';

/// Holds the currently selected baby for the active session.
/// Set to null when no baby is selected.
final selectedBabyProvider = StateProvider<Baby?>((ref) => null);
