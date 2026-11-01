import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';
import 'package:prep_az/features/auth/presentation/widgets/delete_account_dialog.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDeleteAccountDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel deletes nothing', (tester) async {
    await open(tester);
    expect(find.text(AppStrings.deleteAccountWarning), findsOneWidget);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(repo.deleteCalls, 0);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });

  testWidgets('confirming deletes once and closes', (tester) async {
    await open(tester);
    await tester.tap(find.text(AppStrings.deleteAccountConfirm));
    await tester.pumpAndSettle();
    expect(repo.deleteCalls, 1);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });

  testWidgets('a failure stays open and shows why', (tester) async {
    repo.deleteError = AppException(AppStrings.deleteAccountAdmin);
    await open(tester);
    await tester.tap(find.text(AppStrings.deleteAccountConfirm));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.deleteAccountAdmin), findsOneWidget);
    expect(find.byType(DeleteAccountDialog), findsOneWidget);
  });
}
