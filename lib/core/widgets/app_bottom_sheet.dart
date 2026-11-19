import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Tətbiqin bütün aşağıdan açılan panelləri bununla açılır (`showModalBottomSheet` birbaşa çağırılmır).
///
/// Niyə: Android-də tətbiq ekranın altına qədər çəkilir (edge-to-edge), `useSafeArea` isə yalnız
/// yuxarını qoruyur. Panelin aşağı hissəsi sistemin naviqasiya düymələrinin altında qalırdı.
/// Burada məzmun `SafeArea(top: false)` ilə sarılır: panel həmişə o zolağın üstündə bitir.
/// Klaviatura açılanda (məs. xəta bildirişi) panel klaviaturanın üstünə qalxır.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(top: false, child: builder(context)),
    ),
  );
}
