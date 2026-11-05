import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/error/app_exception.dart';
import '../domain/share_service.dart';

/// Android-in öz paylaşma pəncərəsi (share_plus).
class SystemShareService implements ShareService {
  const SystemShareService();

  @override
  Future<void> shareText(String text, {String? subject}) => guard(
    () => SharePlus.instance.share(ShareParams(text: text, subject: subject)),
    mapper: (error) {
      // istifadəçi ümumi mesaj görür, əsl səbəb yalnız debug konsolunda
      debugPrint('SystemShareService.shareText failed: $error');
      return null;
    },
  );
}
