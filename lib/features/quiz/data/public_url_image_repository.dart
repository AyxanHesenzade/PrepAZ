import 'dart:io';
import 'dart:typed_data';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/question_image_repository.dart';

/// Açıq linkdən şəkil: `<baseUrl>/<path>` (Cloudflare R2 açıq bucket-i, CDN və s.).
/// Gələcəkdə gizli server olsa, bunun yanında token göndərən yeni implementasiya yazılır.
class PublicUrlImageRepository implements QuestionImageRepository {
  PublicUrlImageRepository(String baseUrl, {HttpClient? client})
    : _base = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl,
      _client = client ?? (HttpClient()..connectionTimeout = _timeout);

  static const _timeout = Duration(seconds: 15);

  final String _base;
  final HttpClient _client;

  Uri urlOf(String path) => Uri.parse('$_base/${Uri.encodeComponent(path)}');

  @override
  Future<Uint8List> fetch(String path) {
    return guard(() async {
      final request = await _client.getUrl(urlOf(path));
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        // Məqsədli xəta: şəkil bu mənbədə yoxdur (məs. hələ R2-yə köçürülməyib), loga texniki xəta kimi düşmür.
        throw AppException(AppStrings.imageFailed);
      }
      final builder = BytesBuilder(copy: false);
      await response.timeout(_timeout).forEach(builder.add);
      return builder.takeBytes();
    });
  }
}
