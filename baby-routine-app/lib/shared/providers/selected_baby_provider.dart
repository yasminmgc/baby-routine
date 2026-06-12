import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected baby for the active session.
/// Set to null when no baby is selected.
typedef Baby = dynamic; // Will be replaced when Baby model is created in US-015

final selectedBabyProvider = StateProvider<Baby?>((ref) => null);
