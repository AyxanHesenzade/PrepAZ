import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version.dart';
import '../../../core/providers.dart';
import '../data/supabase_app_config_repository.dart';
import '../domain/app_config.dart';
import '../domain/app_config_repository.dart';

final appConfigRepositoryProvider = Provider<AppConfigRepository>(
  (ref) => SupabaseAppConfigRepository(ref.watch(supabaseClientProvider)),
);

/// Bu tətbiq versiyası yeniləmə tələb edirmi? Açılışda bir dəfə yoxlanır.
final updateInfoProvider = FutureProvider<UpdateInfo>((ref) async {
  final version = await ref.watch(appVersionProvider.future);
  final current = VersionCode.tryParse('${version.version}+${version.build}');
  if (current == null) return UpdateInfo.none;
  return UpdateInfo.decide(current, await ref.watch(appConfigRepositoryProvider).getConfig());
});
