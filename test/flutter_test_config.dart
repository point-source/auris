// Test bootstrap auto-discovered by `flutter_test` for every test under `test/`.
import 'dart:async';

import 'package:golden_matrix/golden_matrix.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
