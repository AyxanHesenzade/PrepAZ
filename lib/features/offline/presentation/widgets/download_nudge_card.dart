import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/mascot/mascot.dart';
import '../../../../core/widgets/mascot/mascot_behavior.dart';
import '../../../home/domain/subject.dart';
import '../../../home/presentation/home_providers.dart';
import '../../../home/presentation/widgets/subject_sheet.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../../tour/presentation/tour_controller.dart';
import '../../domain/download_nudge.dart';
import '../download_screen.dart';
import '../offline_providers.dart';

/// Testlərdə defolt false-dur (ana ekran testləri bu kartı gözləmir), `main.dart` true edir.
final downloadNudgeEnabledProvider = Provider<bool>((ref) => false);

/// Ana ekranda köməkçi balonda deyir: "mövzunu telefona yüklə, yolda internetsiz həll et".
/// Telefona yüklənməmiş mövzu qaldıqca, gündə ən çox bir dəfə ([isNudgeDue]), say limiti yoxdur.
/// İnternet olanda, tur getmirkən və tur görülübsə çıxır. "Sonra" bu açılış üçün gizlədir.
/// "Mövzu yüklə": yüklənməmiş mövzusu olan fənn birdirsə onun yükləmə ekranı, bir neçədirsə əvvəl fənn seçimi.
class DownloadNudgeCard extends ConsumerStatefulWidget {
  const DownloadNudgeCard({super.key});

  @override
  ConsumerState<DownloadNudgeCard> createState() => _DownloadNudgeCardState();
}

class _DownloadNudgeCardState extends ConsumerState<DownloadNudgeCard> {
  /// Bu açılışda yoxlama bir dəfə edilir (sonra şərtlər dəyişsə də kart yerində qalır, titrəmir).
  bool _decided = false;
  bool _closed = false;
  int _lineIndex = 0;

  /// Yüklənməmiş mövzusu olan fənlər (boş = kart göstərilmir).
  List<Subject> _missing = const [];

  Future<void> _decide(List<Subject> subjects) async {
    if (_decided || subjects.isEmpty) return;
    _decided = true;
    final settings = ref.read(settingsControllerProvider);
    if (!isNudgeDue(now: DateTime.now(), lastShown: settings.downloadNudgeAt)) return;
    final missing = <Subject>[];
    try {
      final stored = await ref.read(offlineStoreProvider).watchAllTopics().first;
      final remote = ref.read(remoteDownloadSourceProvider);
      for (final subject in subjects) {
        try {
          final catalog = await remote.fetchCatalog(subject.id);
          if (firstMissingTopic(catalog, stored) != null) missing.add(subject);
        } catch (_) {
          // bu fənnin kataloqu alınmadı: onu təklif etmirik
        }
      }
    } catch (_) {
      return;
    }
    if (!mounted || missing.isEmpty) return;
    setState(() {
      _missing = missing;
      _lineIndex = settings.downloadNudgeCount;
    });
    await ref.read(settingsControllerProvider.notifier).markDownloadNudged(DateTime.now());
  }

  Future<void> _download() async {
    setState(() => _closed = true);
    var subject = _missing.first;
    if (_missing.length > 1) {
      final id = await showSubjectSheet(context, subjects: _missing, selectedId: subject.id);
      if (id == null || !mounted) return;
      subject = _missing.firstWhere((s) => s.id == id, orElse: () => subject);
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DownloadScreen(subject: subject)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(downloadNudgeEnabledProvider)) return const SizedBox.shrink();
    final offline = ref.watch(offlineModeProvider);
    final touring = ref.watch(tourControllerProvider) != null;
    final tourSeen = ref.watch(settingsControllerProvider.select((s) => s.tourSeen));
    final subjects = ref.watch(subjectsProvider).asData?.value ?? const <Subject>[];
    if (!offline && !touring && tourSeen && !_decided && subjects.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _decide(subjects);
      });
    }
    if (_missing.isEmpty || _closed || offline || touring) return const SizedBox.shrink();
    final lines = AppStrings.downloadNudgeLines;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: FadeSlideIn(
        child: _Bubble(
          message: lines[_lineIndex % lines.length],
          animateMascot: ref.watch(mascotMotionProvider),
          onDownload: _download,
          onLater: () => setState(() => _closed = true),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.animateMascot,
    required this.onDownload,
    required this.onLater,
  });

  final String message;
  final bool animateMascot;
  final VoidCallback onDownload;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Mascot(behavior: const TalkingMascot(), size: 64, animate: animateMascot),
        AppSpacing.gapS,
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.s, AppSpacing.s),
            decoration: BoxDecoration(
              // köməkçinin balonu hər yerdə ağdır (məşqdəki kimi)
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.l),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: Text(
                    message,
                    style: text.titleSmall?.copyWith(
                      color: const Color(0xFF1B1F2A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.gapS,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onLater,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
                      child: Text(AppStrings.downloadNudgeLater),
                    ),
                    AppSpacing.gapXs,
                    FilledButton.icon(
                      onPressed: onDownload,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(AppStrings.downloadNudgeAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
