import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../update/domain/app_config_repository.dart';
import '../../update/presentation/update_providers.dart';
import '../data/system_share_service.dart';
import '../domain/share_service.dart';

final shareServiceProvider = Provider<ShareService>((ref) => const SystemShareService());

enum ShareAppResult { shared, noLink }

/// "Dostunla paylaş": link koda yazılmır, hər dəfə bazadakı `app_config.update_url`-dan oxunur
/// (admin paneldə dəyişəndə tətbiqi yeniləmək lazım olmur).
class ShareAppAction {
  const ShareAppAction(this._config, this._share);

  final AppConfigRepository _config;
  final ShareService _share;

  /// Link oxunmasa (internet yox) və ya boşdursa pəncərə açılmır: [ShareAppResult.noLink].
  /// Paylaşma pəncərəsi xəta versə [AppException] atır.
  Future<ShareAppResult> run() async {
    final config = await _config.getConfig();
    if (config == null || !config.hasUrl) return ShareAppResult.noLink;
    await _share.shareText(AppStrings.shareAppMessage(config.updateUrl!.trim()), subject: AppStrings.appName);
    return ShareAppResult.shared;
  }
}

final shareAppActionProvider = Provider<ShareAppAction>(
  (ref) => ShareAppAction(ref.watch(appConfigRepositoryProvider), ref.watch(shareServiceProvider)),
);
