import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';

import '../constants/app_strings.dart';

/// Telefonun sabit məlumatı (bir dəfə oxunur): marka, model, Android, RAM.
/// Serverdə `app_devices` cədvəlinə düşür (migration 020), hər log sətrinə yox.
/// Telefonun real ID-si, IMEI, nömrə və s. GÖTÜRÜLMÜR.
Future<Map<String, Object?>> readPhoneInfo() async {
  try {
    if (!Platform.isAndroid) return {'os': Platform.operatingSystem};
    final a = await DeviceInfoPlugin().androidInfo;
    return {
      'brand': a.brand,
      'manufacturer': a.manufacturer,
      'model': a.model,
      'device': a.device,
      'android': a.version.release,
      'sdk': a.version.sdkInt,
      'security_patch': a.version.securityPatch,
      'physical': a.isPhysicalDevice,
      'low_ram': a.isLowRamDevice,
      'ram_mb': a.physicalRamSize,
      'disk_total_gb': (a.totalDiskSize / 1e9).round(),
      'abi': a.supportedAbis.isEmpty ? null : a.supportedAbis.first,
    }..removeWhere((_, v) => v == null);
  } on Object catch (e) {
    // məs. MissingPluginException: paket əlavə olunandan sonra tətbiq tam yenidən yığılmayıb (hot restart kifayət deyil)
    return {'os': Platform.operatingSystem, 'phone_error': e.runtimeType.toString()};
  }
}

/// Dəyişə bilən hissə (hər göndərişdə oxunur): ekran ölçüsü (dp), sıxlıq, şrift böyüklüyü, dil, tema.
/// Ekran xətalarını (overflow) anlamaq üçün ən vacib məlumat budur.
Map<String, Object?> readScreenInfo([PlatformDispatcher? platform]) {
  final dispatcher = platform ?? PlatformDispatcher.instance;
  final views = dispatcher.views;
  final info = <String, Object?>{
    'text_scale': double.parse(dispatcher.textScaleFactor.toStringAsFixed(2)),
    'system_locale': dispatcher.locale.toLanguageTag(),
    'app_language': AppStrings.language.code,
    'dark': dispatcher.platformBrightness == Brightness.dark,
  };
  if (views.isNotEmpty) {
    final view = views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    info['screen'] = '${size.width.round()}x${size.height.round()}';
    info['dpr'] = double.parse(view.devicePixelRatio.toStringAsFixed(2));
  }
  return info;
}
