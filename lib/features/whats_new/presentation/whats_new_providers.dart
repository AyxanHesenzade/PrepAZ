import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/release_notes.dart';
import '../domain/release_note.dart';

/// Testlərdə defolt false (panel başqa ekran testlərinə qarışmasın); `main.dart` true edir.
final whatsNewEnabledProvider = Provider<bool>((ref) => false);

final releaseNotesProvider = Provider<List<ReleaseNote>>((ref) => releaseNotes);
