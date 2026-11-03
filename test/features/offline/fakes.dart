import 'dart:async';
import 'dart:typed_data';

import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/offline/domain/image_store.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/domain/remote_download_source.dart';
import 'package:prep_az/features/quiz/domain/question.dart';

class FakeRemote implements RemoteDownloadSource {
  final questions = <int, List<Question>>{};
  final downloaded = <String>[];

  /// Bu yol endirilərkən xəta atılır (internet qopdu).
  String? failOn;

  /// Kataloq (`get_download_catalog` cavabı). [catalogError] doludursa, kataloq alınmır (internet yoxdur).
  final catalog = <CatalogTopic>[];
  Object? catalogError;

  /// Doludursa, şəkil endirmə bu qapı açılana qədər gözləyir (irəliləyişi və dayandırmanı görmək üçün).
  Completer<void>? gate;

  @override
  Future<List<CatalogTopic>> fetchCatalog(int subjectId) async {
    if (catalogError != null) throw catalogError!;
    return catalog;
  }

  @override
  Future<List<Question>> fetchTopicQuestions(int topicId) async => questions[topicId] ?? [];

  @override
  Future<Uint8List> downloadImage(String path) async {
    await gate?.future;
    if (path == failOn) throw const AppException('offline');
    downloaded.add(path);
    return Uint8List.fromList(List.filled(10, 1));
  }
}

class FakeImages implements ImageStore {
  final files = <String>{};

  @override
  Future<void> write(String path, Uint8List bytes) async => files.add(path);

  @override
  Future<bool> exists(String path) async => files.contains(path);

  @override
  Future<String?> localPath(String path) async => files.contains(path) ? '/phone/$path' : null;

  @override
  Future<void> delete(String path) async => files.remove(path);
}

Question question(String id, int topic, {String? image, String? solutionImage}) => Question(
  id: id,
  code: 'C-$id',
  topicId: topic,
  type: QuestionType.qapali,
  body: 'sual $id',
  imagePath: image,
  options: const {'A': '1', 'B': '2'},
  correctAnswer: 'A',
  difficulty: 1,
  solution: null,
  solutionImagePath: solutionImage,
);

CatalogTopic catalog(int id, {int version = 1}) => CatalogTopic(
  topicId: id,
  topicName: 'Mövzu $id',
  sectionName: 'Bölmə',
  questionCount: 0,
  version: version,
  imageCount: 0,
  imageBytes: 1000,
);
