import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/config/app_version.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/profile_repository.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/subject_repository.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/home/presentation/home_screen.dart';

class _Subjects implements SubjectRepository {
  @override
  Future<List<Subject>> getSubjects() async => const [];
}

class _Profile implements ProfileRepository {
  @override
  Future<int> getStreakDays() async => 0;
}

void main() {
  test('assets/app.json and pubspec.yaml carry the same version and build', () {
    final json = jsonDecode(File('assets/app.json').readAsStringSync()) as Map<String, dynamic>;
    final app = AppVersion.fromJson(json);
    final pubspec = RegExp(r'^version:\s*(\S+)\+(\d+)\s*$', multiLine: true).firstMatch(File('pubspec.yaml').readAsStringSync())!;
    expect(pubspec.group(1), app.version);
    expect(int.parse(pubspec.group(2)!), app.build);
  });

  testWidgets('home screen shows the version from app.json', (tester) async {
    await tester.pumpWidget(ProviderScope(
      retry: (_, _) => null,
      overrides: [
        subjectRepositoryProvider.overrideWithValue(_Subjects()),
        profileRepositoryProvider.overrideWithValue(_Profile()),
        appVersionProvider.overrideWith((ref) => const AppVersion(version: '0.0.1', build: 1)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.appVersion('0.0.1', 1)), findsOneWidget);
  });

  testWidgets('real app.json loads from the asset bundle', (tester) async {
    late AppVersion loaded;
    await tester.runAsync(() async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      loaded = await container.read(appVersionProvider.future);
    });
    expect(loaded.version, '0.0.1');
    expect(loaded.build, 1);
  });
}
