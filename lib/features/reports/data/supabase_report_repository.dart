import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/report_repository.dart';

class SupabaseReportRepository implements ReportRepository {
  const SupabaseReportRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<void> submit({
    required String message,
    required String appVersion,
    String? questionId,
    String? questionCode,
  }) {
    return guard(
      () async {
        await _db.from('reports').insert({
          'kind': questionCode == null ? 'app' : 'question',
          'question_id': questionId,
          'question_code': questionCode,
          'message': message.trim(),
          'app_version': appVersion,
        });
      },
      mapper: (error) => error is PostgrestException && error.message.contains('too_many_reports')
          ? AppException(AppStrings.reportTooMany)
          : null,
    );
  }
}
