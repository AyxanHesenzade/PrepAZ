import 'dart:math';

final _random = Random.secure();

/// Cavab üçün təsadüfi UUID v4. Serverdə `answers.client_id` ilə eyni cavabın təkrar yazılmasının qarşısını alır.
String newClientId() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // versiya 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')].join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
