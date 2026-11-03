// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalQuestionsTable extends LocalQuestions
    with TableInfo<$LocalQuestionsTable, LocalQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solutionMeta = const VerificationMeta(
    'solution',
  );
  @override
  late final GeneratedColumn<String> solution = GeneratedColumn<String>(
    'solution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _solutionImagePathMeta = const VerificationMeta(
    'solutionImagePath',
  );
  @override
  late final GeneratedColumn<String> solutionImagePath =
      GeneratedColumn<String>(
        'solution_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    topicId,
    type,
    body,
    imagePath,
    optionsJson,
    correctAnswer,
    difficulty,
    solution,
    solutionImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('solution')) {
      context.handle(
        _solutionMeta,
        solution.isAcceptableOrUnknown(data['solution']!, _solutionMeta),
      );
    }
    if (data.containsKey('solution_image_path')) {
      context.handle(
        _solutionImagePathMeta,
        solutionImagePath.isAcceptableOrUnknown(
          data['solution_image_path']!,
          _solutionImagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      solution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solution'],
      ),
      solutionImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solution_image_path'],
      ),
    );
  }

  @override
  $LocalQuestionsTable createAlias(String alias) {
    return $LocalQuestionsTable(attachedDatabase, alias);
  }
}

class LocalQuestion extends DataClass implements Insertable<LocalQuestion> {
  final String id;
  final String? code;
  final int topicId;
  final String type;
  final String body;
  final String? imagePath;

  /// `{"A": "...", "B": "..."}` JSON kimi (serverdəki jsonb ilə eyni).
  final String optionsJson;
  final String correctAnswer;
  final int difficulty;
  final String? solution;
  final String? solutionImagePath;
  const LocalQuestion({
    required this.id,
    this.code,
    required this.topicId,
    required this.type,
    required this.body,
    this.imagePath,
    required this.optionsJson,
    required this.correctAnswer,
    required this.difficulty,
    this.solution,
    this.solutionImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['topic_id'] = Variable<int>(topicId);
    map['type'] = Variable<String>(type);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['difficulty'] = Variable<int>(difficulty);
    if (!nullToAbsent || solution != null) {
      map['solution'] = Variable<String>(solution);
    }
    if (!nullToAbsent || solutionImagePath != null) {
      map['solution_image_path'] = Variable<String>(solutionImagePath);
    }
    return map;
  }

  LocalQuestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionsCompanion(
      id: Value(id),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      topicId: Value(topicId),
      type: Value(type),
      body: Value(body),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      optionsJson: Value(optionsJson),
      correctAnswer: Value(correctAnswer),
      difficulty: Value(difficulty),
      solution: solution == null && nullToAbsent
          ? const Value.absent()
          : Value(solution),
      solutionImagePath: solutionImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(solutionImagePath),
    );
  }

  factory LocalQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestion(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String?>(json['code']),
      topicId: serializer.fromJson<int>(json['topicId']),
      type: serializer.fromJson<String>(json['type']),
      body: serializer.fromJson<String>(json['body']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      solution: serializer.fromJson<String?>(json['solution']),
      solutionImagePath: serializer.fromJson<String?>(
        json['solutionImagePath'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String?>(code),
      'topicId': serializer.toJson<int>(topicId),
      'type': serializer.toJson<String>(type),
      'body': serializer.toJson<String>(body),
      'imagePath': serializer.toJson<String?>(imagePath),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'difficulty': serializer.toJson<int>(difficulty),
      'solution': serializer.toJson<String?>(solution),
      'solutionImagePath': serializer.toJson<String?>(solutionImagePath),
    };
  }

  LocalQuestion copyWith({
    String? id,
    Value<String?> code = const Value.absent(),
    int? topicId,
    String? type,
    String? body,
    Value<String?> imagePath = const Value.absent(),
    String? optionsJson,
    String? correctAnswer,
    int? difficulty,
    Value<String?> solution = const Value.absent(),
    Value<String?> solutionImagePath = const Value.absent(),
  }) => LocalQuestion(
    id: id ?? this.id,
    code: code.present ? code.value : this.code,
    topicId: topicId ?? this.topicId,
    type: type ?? this.type,
    body: body ?? this.body,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    optionsJson: optionsJson ?? this.optionsJson,
    correctAnswer: correctAnswer ?? this.correctAnswer,
    difficulty: difficulty ?? this.difficulty,
    solution: solution.present ? solution.value : this.solution,
    solutionImagePath: solutionImagePath.present
        ? solutionImagePath.value
        : this.solutionImagePath,
  );
  LocalQuestion copyWithCompanion(LocalQuestionsCompanion data) {
    return LocalQuestion(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      solution: data.solution.present ? data.solution.value : this.solution,
      solutionImagePath: data.solutionImagePath.present
          ? data.solutionImagePath.value
          : this.solutionImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('topicId: $topicId, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('imagePath: $imagePath, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('difficulty: $difficulty, ')
          ..write('solution: $solution, ')
          ..write('solutionImagePath: $solutionImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    topicId,
    type,
    body,
    imagePath,
    optionsJson,
    correctAnswer,
    difficulty,
    solution,
    solutionImagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestion &&
          other.id == this.id &&
          other.code == this.code &&
          other.topicId == this.topicId &&
          other.type == this.type &&
          other.body == this.body &&
          other.imagePath == this.imagePath &&
          other.optionsJson == this.optionsJson &&
          other.correctAnswer == this.correctAnswer &&
          other.difficulty == this.difficulty &&
          other.solution == this.solution &&
          other.solutionImagePath == this.solutionImagePath);
}

class LocalQuestionsCompanion extends UpdateCompanion<LocalQuestion> {
  final Value<String> id;
  final Value<String?> code;
  final Value<int> topicId;
  final Value<String> type;
  final Value<String> body;
  final Value<String?> imagePath;
  final Value<String> optionsJson;
  final Value<String> correctAnswer;
  final Value<int> difficulty;
  final Value<String?> solution;
  final Value<String?> solutionImagePath;
  final Value<int> rowid;
  const LocalQuestionsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.topicId = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.solution = const Value.absent(),
    this.solutionImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuestionsCompanion.insert({
    required String id,
    this.code = const Value.absent(),
    required int topicId,
    required String type,
    required String body,
    this.imagePath = const Value.absent(),
    required String optionsJson,
    required String correctAnswer,
    required int difficulty,
    this.solution = const Value.absent(),
    this.solutionImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       topicId = Value(topicId),
       type = Value(type),
       body = Value(body),
       optionsJson = Value(optionsJson),
       correctAnswer = Value(correctAnswer),
       difficulty = Value(difficulty);
  static Insertable<LocalQuestion> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<int>? topicId,
    Expression<String>? type,
    Expression<String>? body,
    Expression<String>? imagePath,
    Expression<String>? optionsJson,
    Expression<String>? correctAnswer,
    Expression<int>? difficulty,
    Expression<String>? solution,
    Expression<String>? solutionImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (topicId != null) 'topic_id': topicId,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (imagePath != null) 'image_path': imagePath,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (difficulty != null) 'difficulty': difficulty,
      if (solution != null) 'solution': solution,
      if (solutionImagePath != null) 'solution_image_path': solutionImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? code,
    Value<int>? topicId,
    Value<String>? type,
    Value<String>? body,
    Value<String?>? imagePath,
    Value<String>? optionsJson,
    Value<String>? correctAnswer,
    Value<int>? difficulty,
    Value<String?>? solution,
    Value<String?>? solutionImagePath,
    Value<int>? rowid,
  }) {
    return LocalQuestionsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      topicId: topicId ?? this.topicId,
      type: type ?? this.type,
      body: body ?? this.body,
      imagePath: imagePath ?? this.imagePath,
      optionsJson: optionsJson ?? this.optionsJson,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficulty: difficulty ?? this.difficulty,
      solution: solution ?? this.solution,
      solutionImagePath: solutionImagePath ?? this.solutionImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (solution.present) {
      map['solution'] = Variable<String>(solution.value);
    }
    if (solutionImagePath.present) {
      map['solution_image_path'] = Variable<String>(solutionImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('topicId: $topicId, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('imagePath: $imagePath, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('difficulty: $difficulty, ')
          ..write('solution: $solution, ')
          ..write('solutionImagePath: $solutionImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedTopicsTable extends DownloadedTopics
    with TableInfo<$DownloadedTopicsTable, DownloadedTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicNameMeta = const VerificationMeta(
    'topicName',
  );
  @override
  late final GeneratedColumn<String> topicName = GeneratedColumn<String>(
    'topic_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionNameMeta = const VerificationMeta(
    'sectionName',
  );
  @override
  late final GeneratedColumn<String> sectionName = GeneratedColumn<String>(
    'section_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageCountMeta = const VerificationMeta(
    'imageCount',
  );
  @override
  late final GeneratedColumn<int> imageCount = GeneratedColumn<int>(
    'image_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageBytesMeta = const VerificationMeta(
    'imageBytes',
  );
  @override
  late final GeneratedColumn<int> imageBytes = GeneratedColumn<int>(
    'image_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagesDoneMeta = const VerificationMeta(
    'imagesDone',
  );
  @override
  late final GeneratedColumn<int> imagesDone = GeneratedColumn<int>(
    'images_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    topicId,
    subjectId,
    topicName,
    sectionName,
    questionCount,
    version,
    imageCount,
    imageBytes,
    imagesDone,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('topic_name')) {
      context.handle(
        _topicNameMeta,
        topicName.isAcceptableOrUnknown(data['topic_name']!, _topicNameMeta),
      );
    } else if (isInserting) {
      context.missing(_topicNameMeta);
    }
    if (data.containsKey('section_name')) {
      context.handle(
        _sectionNameMeta,
        sectionName.isAcceptableOrUnknown(
          data['section_name']!,
          _sectionNameMeta,
        ),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCountMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('image_count')) {
      context.handle(
        _imageCountMeta,
        imageCount.isAcceptableOrUnknown(data['image_count']!, _imageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_imageCountMeta);
    }
    if (data.containsKey('image_bytes')) {
      context.handle(
        _imageBytesMeta,
        imageBytes.isAcceptableOrUnknown(data['image_bytes']!, _imageBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_imageBytesMeta);
    }
    if (data.containsKey('images_done')) {
      context.handle(
        _imagesDoneMeta,
        imagesDone.isAcceptableOrUnknown(data['images_done']!, _imagesDoneMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topicId};
  @override
  DownloadedTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedTopic(
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      topicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_name'],
      )!,
      sectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_name'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      imageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_count'],
      )!,
      imageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_bytes'],
      )!,
      imagesDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}images_done'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $DownloadedTopicsTable createAlias(String alias) {
    return $DownloadedTopicsTable(attachedDatabase, alias);
  }
}

class DownloadedTopic extends DataClass implements Insertable<DownloadedTopic> {
  final int topicId;
  final int subjectId;
  final String topicName;
  final String? sectionName;
  final int questionCount;

  /// Yükləmə anında serverdəki `get_download_catalog().version`. Fərqlidirsə, "yenilənmə var".
  final int version;
  final int imageCount;
  final int imageBytes;

  /// Endirilmiş şəkil sayı. `imagesDone == imageCount` olanda mövzu tam hazırdır.
  final int imagesDone;
  final DateTime downloadedAt;
  const DownloadedTopic({
    required this.topicId,
    required this.subjectId,
    required this.topicName,
    this.sectionName,
    required this.questionCount,
    required this.version,
    required this.imageCount,
    required this.imageBytes,
    required this.imagesDone,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic_id'] = Variable<int>(topicId);
    map['subject_id'] = Variable<int>(subjectId);
    map['topic_name'] = Variable<String>(topicName);
    if (!nullToAbsent || sectionName != null) {
      map['section_name'] = Variable<String>(sectionName);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['version'] = Variable<int>(version);
    map['image_count'] = Variable<int>(imageCount);
    map['image_bytes'] = Variable<int>(imageBytes);
    map['images_done'] = Variable<int>(imagesDone);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  DownloadedTopicsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTopicsCompanion(
      topicId: Value(topicId),
      subjectId: Value(subjectId),
      topicName: Value(topicName),
      sectionName: sectionName == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionName),
      questionCount: Value(questionCount),
      version: Value(version),
      imageCount: Value(imageCount),
      imageBytes: Value(imageBytes),
      imagesDone: Value(imagesDone),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory DownloadedTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedTopic(
      topicId: serializer.fromJson<int>(json['topicId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      topicName: serializer.fromJson<String>(json['topicName']),
      sectionName: serializer.fromJson<String?>(json['sectionName']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      version: serializer.fromJson<int>(json['version']),
      imageCount: serializer.fromJson<int>(json['imageCount']),
      imageBytes: serializer.fromJson<int>(json['imageBytes']),
      imagesDone: serializer.fromJson<int>(json['imagesDone']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topicId': serializer.toJson<int>(topicId),
      'subjectId': serializer.toJson<int>(subjectId),
      'topicName': serializer.toJson<String>(topicName),
      'sectionName': serializer.toJson<String?>(sectionName),
      'questionCount': serializer.toJson<int>(questionCount),
      'version': serializer.toJson<int>(version),
      'imageCount': serializer.toJson<int>(imageCount),
      'imageBytes': serializer.toJson<int>(imageBytes),
      'imagesDone': serializer.toJson<int>(imagesDone),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  DownloadedTopic copyWith({
    int? topicId,
    int? subjectId,
    String? topicName,
    Value<String?> sectionName = const Value.absent(),
    int? questionCount,
    int? version,
    int? imageCount,
    int? imageBytes,
    int? imagesDone,
    DateTime? downloadedAt,
  }) => DownloadedTopic(
    topicId: topicId ?? this.topicId,
    subjectId: subjectId ?? this.subjectId,
    topicName: topicName ?? this.topicName,
    sectionName: sectionName.present ? sectionName.value : this.sectionName,
    questionCount: questionCount ?? this.questionCount,
    version: version ?? this.version,
    imageCount: imageCount ?? this.imageCount,
    imageBytes: imageBytes ?? this.imageBytes,
    imagesDone: imagesDone ?? this.imagesDone,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  DownloadedTopic copyWithCompanion(DownloadedTopicsCompanion data) {
    return DownloadedTopic(
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      topicName: data.topicName.present ? data.topicName.value : this.topicName,
      sectionName: data.sectionName.present
          ? data.sectionName.value
          : this.sectionName,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      version: data.version.present ? data.version.value : this.version,
      imageCount: data.imageCount.present
          ? data.imageCount.value
          : this.imageCount,
      imageBytes: data.imageBytes.present
          ? data.imageBytes.value
          : this.imageBytes,
      imagesDone: data.imagesDone.present
          ? data.imagesDone.value
          : this.imagesDone,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTopic(')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('topicName: $topicName, ')
          ..write('sectionName: $sectionName, ')
          ..write('questionCount: $questionCount, ')
          ..write('version: $version, ')
          ..write('imageCount: $imageCount, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('imagesDone: $imagesDone, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    topicId,
    subjectId,
    topicName,
    sectionName,
    questionCount,
    version,
    imageCount,
    imageBytes,
    imagesDone,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTopic &&
          other.topicId == this.topicId &&
          other.subjectId == this.subjectId &&
          other.topicName == this.topicName &&
          other.sectionName == this.sectionName &&
          other.questionCount == this.questionCount &&
          other.version == this.version &&
          other.imageCount == this.imageCount &&
          other.imageBytes == this.imageBytes &&
          other.imagesDone == this.imagesDone &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadedTopicsCompanion extends UpdateCompanion<DownloadedTopic> {
  final Value<int> topicId;
  final Value<int> subjectId;
  final Value<String> topicName;
  final Value<String?> sectionName;
  final Value<int> questionCount;
  final Value<int> version;
  final Value<int> imageCount;
  final Value<int> imageBytes;
  final Value<int> imagesDone;
  final Value<DateTime> downloadedAt;
  const DownloadedTopicsCompanion({
    this.topicId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.topicName = const Value.absent(),
    this.sectionName = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.version = const Value.absent(),
    this.imageCount = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.imagesDone = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  DownloadedTopicsCompanion.insert({
    this.topicId = const Value.absent(),
    required int subjectId,
    required String topicName,
    this.sectionName = const Value.absent(),
    required int questionCount,
    required int version,
    required int imageCount,
    required int imageBytes,
    this.imagesDone = const Value.absent(),
    required DateTime downloadedAt,
  }) : subjectId = Value(subjectId),
       topicName = Value(topicName),
       questionCount = Value(questionCount),
       version = Value(version),
       imageCount = Value(imageCount),
       imageBytes = Value(imageBytes),
       downloadedAt = Value(downloadedAt);
  static Insertable<DownloadedTopic> custom({
    Expression<int>? topicId,
    Expression<int>? subjectId,
    Expression<String>? topicName,
    Expression<String>? sectionName,
    Expression<int>? questionCount,
    Expression<int>? version,
    Expression<int>? imageCount,
    Expression<int>? imageBytes,
    Expression<int>? imagesDone,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (topicId != null) 'topic_id': topicId,
      if (subjectId != null) 'subject_id': subjectId,
      if (topicName != null) 'topic_name': topicName,
      if (sectionName != null) 'section_name': sectionName,
      if (questionCount != null) 'question_count': questionCount,
      if (version != null) 'version': version,
      if (imageCount != null) 'image_count': imageCount,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (imagesDone != null) 'images_done': imagesDone,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  DownloadedTopicsCompanion copyWith({
    Value<int>? topicId,
    Value<int>? subjectId,
    Value<String>? topicName,
    Value<String?>? sectionName,
    Value<int>? questionCount,
    Value<int>? version,
    Value<int>? imageCount,
    Value<int>? imageBytes,
    Value<int>? imagesDone,
    Value<DateTime>? downloadedAt,
  }) {
    return DownloadedTopicsCompanion(
      topicId: topicId ?? this.topicId,
      subjectId: subjectId ?? this.subjectId,
      topicName: topicName ?? this.topicName,
      sectionName: sectionName ?? this.sectionName,
      questionCount: questionCount ?? this.questionCount,
      version: version ?? this.version,
      imageCount: imageCount ?? this.imageCount,
      imageBytes: imageBytes ?? this.imageBytes,
      imagesDone: imagesDone ?? this.imagesDone,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (topicName.present) {
      map['topic_name'] = Variable<String>(topicName.value);
    }
    if (sectionName.present) {
      map['section_name'] = Variable<String>(sectionName.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (imageCount.present) {
      map['image_count'] = Variable<int>(imageCount.value);
    }
    if (imageBytes.present) {
      map['image_bytes'] = Variable<int>(imageBytes.value);
    }
    if (imagesDone.present) {
      map['images_done'] = Variable<int>(imagesDone.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTopicsCompanion(')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('topicName: $topicName, ')
          ..write('sectionName: $sectionName, ')
          ..write('questionCount: $questionCount, ')
          ..write('version: $version, ')
          ..write('imageCount: $imageCount, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('imagesDone: $imagesDone, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalImagesTable extends LocalImages
    with TableInfo<$LocalImagesTable, LocalImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [path, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  LocalImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalImage(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
    );
  }

  @override
  $LocalImagesTable createAlias(String alias) {
    return $LocalImagesTable(attachedDatabase, alias);
  }
}

class LocalImage extends DataClass implements Insertable<LocalImage> {
  final String path;
  final int bytes;
  const LocalImage({required this.path, required this.bytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['bytes'] = Variable<int>(bytes);
    return map;
  }

  LocalImagesCompanion toCompanion(bool nullToAbsent) {
    return LocalImagesCompanion(path: Value(path), bytes: Value(bytes));
  }

  factory LocalImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalImage(
      path: serializer.fromJson<String>(json['path']),
      bytes: serializer.fromJson<int>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'bytes': serializer.toJson<int>(bytes),
    };
  }

  LocalImage copyWith({String? path, int? bytes}) =>
      LocalImage(path: path ?? this.path, bytes: bytes ?? this.bytes);
  LocalImage copyWithCompanion(LocalImagesCompanion data) {
    return LocalImage(
      path: data.path.present ? data.path.value : this.path,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalImage(')
          ..write('path: $path, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, bytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalImage &&
          other.path == this.path &&
          other.bytes == this.bytes);
}

class LocalImagesCompanion extends UpdateCompanion<LocalImage> {
  final Value<String> path;
  final Value<int> bytes;
  final Value<int> rowid;
  const LocalImagesCompanion({
    this.path = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalImagesCompanion.insert({
    required String path,
    required int bytes,
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       bytes = Value(bytes);
  static Insertable<LocalImage> custom({
    Expression<String>? path,
    Expression<int>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalImagesCompanion copyWith({
    Value<String>? path,
    Value<int>? bytes,
    Value<int>? rowid,
  }) {
    return LocalImagesCompanion(
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalImagesCompanion(')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingAnswersTable extends PendingAnswers
    with TableInfo<$PendingAnswersTable, PendingAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _givenAnswerMeta = const VerificationMeta(
    'givenAnswer',
  );
  @override
  late final GeneratedColumn<String> givenAnswer = GeneratedColumn<String>(
    'given_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
    'time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    questionId,
    topicId,
    subjectId,
    givenAnswer,
    isCorrect,
    timeMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('given_answer')) {
      context.handle(
        _givenAnswerMeta,
        givenAnswer.isAcceptableOrUnknown(
          data['given_answer']!,
          _givenAnswerMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(
        _timeMsMeta,
        timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      givenAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_answer'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      timeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $PendingAnswersTable createAlias(String alias) {
    return $PendingAnswersTable(attachedDatabase, alias);
  }
}

class PendingAnswer extends DataClass implements Insertable<PendingAnswer> {
  final int id;
  final String clientId;
  final String questionId;
  final int topicId;
  final int subjectId;
  final String? givenAnswer;

  /// Telefonda hesablanmış nəticə (nəticə ekranı üçün). Əsl qərarı server göndərəndə verir.
  final bool isCorrect;
  final int timeMs;
  final DateTime answeredAt;
  const PendingAnswer({
    required this.id,
    required this.clientId,
    required this.questionId,
    required this.topicId,
    required this.subjectId,
    this.givenAnswer,
    required this.isCorrect,
    required this.timeMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<String>(clientId);
    map['question_id'] = Variable<String>(questionId);
    map['topic_id'] = Variable<int>(topicId);
    map['subject_id'] = Variable<int>(subjectId);
    if (!nullToAbsent || givenAnswer != null) {
      map['given_answer'] = Variable<String>(givenAnswer);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['time_ms'] = Variable<int>(timeMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  PendingAnswersCompanion toCompanion(bool nullToAbsent) {
    return PendingAnswersCompanion(
      id: Value(id),
      clientId: Value(clientId),
      questionId: Value(questionId),
      topicId: Value(topicId),
      subjectId: Value(subjectId),
      givenAnswer: givenAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(givenAnswer),
      isCorrect: Value(isCorrect),
      timeMs: Value(timeMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory PendingAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingAnswer(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      topicId: serializer.fromJson<int>(json['topicId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      givenAnswer: serializer.fromJson<String?>(json['givenAnswer']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<String>(clientId),
      'questionId': serializer.toJson<String>(questionId),
      'topicId': serializer.toJson<int>(topicId),
      'subjectId': serializer.toJson<int>(subjectId),
      'givenAnswer': serializer.toJson<String?>(givenAnswer),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'timeMs': serializer.toJson<int>(timeMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  PendingAnswer copyWith({
    int? id,
    String? clientId,
    String? questionId,
    int? topicId,
    int? subjectId,
    Value<String?> givenAnswer = const Value.absent(),
    bool? isCorrect,
    int? timeMs,
    DateTime? answeredAt,
  }) => PendingAnswer(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    questionId: questionId ?? this.questionId,
    topicId: topicId ?? this.topicId,
    subjectId: subjectId ?? this.subjectId,
    givenAnswer: givenAnswer.present ? givenAnswer.value : this.givenAnswer,
    isCorrect: isCorrect ?? this.isCorrect,
    timeMs: timeMs ?? this.timeMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  PendingAnswer copyWithCompanion(PendingAnswersCompanion data) {
    return PendingAnswer(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      givenAnswer: data.givenAnswer.present
          ? data.givenAnswer.value
          : this.givenAnswer,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingAnswer(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('questionId: $questionId, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('givenAnswer: $givenAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    questionId,
    topicId,
    subjectId,
    givenAnswer,
    isCorrect,
    timeMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingAnswer &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.questionId == this.questionId &&
          other.topicId == this.topicId &&
          other.subjectId == this.subjectId &&
          other.givenAnswer == this.givenAnswer &&
          other.isCorrect == this.isCorrect &&
          other.timeMs == this.timeMs &&
          other.answeredAt == this.answeredAt);
}

class PendingAnswersCompanion extends UpdateCompanion<PendingAnswer> {
  final Value<int> id;
  final Value<String> clientId;
  final Value<String> questionId;
  final Value<int> topicId;
  final Value<int> subjectId;
  final Value<String?> givenAnswer;
  final Value<bool> isCorrect;
  final Value<int> timeMs;
  final Value<DateTime> answeredAt;
  const PendingAnswersCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.givenAnswer = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  PendingAnswersCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    required String questionId,
    required int topicId,
    required int subjectId,
    this.givenAnswer = const Value.absent(),
    required bool isCorrect,
    this.timeMs = const Value.absent(),
    required DateTime answeredAt,
  }) : clientId = Value(clientId),
       questionId = Value(questionId),
       topicId = Value(topicId),
       subjectId = Value(subjectId),
       isCorrect = Value(isCorrect),
       answeredAt = Value(answeredAt);
  static Insertable<PendingAnswer> custom({
    Expression<int>? id,
    Expression<String>? clientId,
    Expression<String>? questionId,
    Expression<int>? topicId,
    Expression<int>? subjectId,
    Expression<String>? givenAnswer,
    Expression<bool>? isCorrect,
    Expression<int>? timeMs,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (questionId != null) 'question_id': questionId,
      if (topicId != null) 'topic_id': topicId,
      if (subjectId != null) 'subject_id': subjectId,
      if (givenAnswer != null) 'given_answer': givenAnswer,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (timeMs != null) 'time_ms': timeMs,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  PendingAnswersCompanion copyWith({
    Value<int>? id,
    Value<String>? clientId,
    Value<String>? questionId,
    Value<int>? topicId,
    Value<int>? subjectId,
    Value<String?>? givenAnswer,
    Value<bool>? isCorrect,
    Value<int>? timeMs,
    Value<DateTime>? answeredAt,
  }) {
    return PendingAnswersCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      questionId: questionId ?? this.questionId,
      topicId: topicId ?? this.topicId,
      subjectId: subjectId ?? this.subjectId,
      givenAnswer: givenAnswer ?? this.givenAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      timeMs: timeMs ?? this.timeMs,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (givenAnswer.present) {
      map['given_answer'] = Variable<String>(givenAnswer.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingAnswersCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('questionId: $questionId, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('givenAnswer: $givenAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timeMs: $timeMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $LocalLatestAnswersTable extends LocalLatestAnswers
    with TableInfo<$LocalLatestAnswersTable, LocalLatestAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLatestAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, topicId, isCorrect];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_latest_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLatestAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  LocalLatestAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLatestAnswer(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_id'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
    );
  }

  @override
  $LocalLatestAnswersTable createAlias(String alias) {
    return $LocalLatestAnswersTable(attachedDatabase, alias);
  }
}

class LocalLatestAnswer extends DataClass
    implements Insertable<LocalLatestAnswer> {
  final String questionId;
  final int topicId;
  final bool isCorrect;
  const LocalLatestAnswer({
    required this.questionId,
    required this.topicId,
    required this.isCorrect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['topic_id'] = Variable<int>(topicId);
    map['is_correct'] = Variable<bool>(isCorrect);
    return map;
  }

  LocalLatestAnswersCompanion toCompanion(bool nullToAbsent) {
    return LocalLatestAnswersCompanion(
      questionId: Value(questionId),
      topicId: Value(topicId),
      isCorrect: Value(isCorrect),
    );
  }

  factory LocalLatestAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLatestAnswer(
      questionId: serializer.fromJson<String>(json['questionId']),
      topicId: serializer.fromJson<int>(json['topicId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'topicId': serializer.toJson<int>(topicId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
    };
  }

  LocalLatestAnswer copyWith({
    String? questionId,
    int? topicId,
    bool? isCorrect,
  }) => LocalLatestAnswer(
    questionId: questionId ?? this.questionId,
    topicId: topicId ?? this.topicId,
    isCorrect: isCorrect ?? this.isCorrect,
  );
  LocalLatestAnswer copyWithCompanion(LocalLatestAnswersCompanion data) {
    return LocalLatestAnswer(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLatestAnswer(')
          ..write('questionId: $questionId, ')
          ..write('topicId: $topicId, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, topicId, isCorrect);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLatestAnswer &&
          other.questionId == this.questionId &&
          other.topicId == this.topicId &&
          other.isCorrect == this.isCorrect);
}

class LocalLatestAnswersCompanion extends UpdateCompanion<LocalLatestAnswer> {
  final Value<String> questionId;
  final Value<int> topicId;
  final Value<bool> isCorrect;
  final Value<int> rowid;
  const LocalLatestAnswersCompanion({
    this.questionId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLatestAnswersCompanion.insert({
    required String questionId,
    required int topicId,
    required bool isCorrect,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       topicId = Value(topicId),
       isCorrect = Value(isCorrect);
  static Insertable<LocalLatestAnswer> custom({
    Expression<String>? questionId,
    Expression<int>? topicId,
    Expression<bool>? isCorrect,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (topicId != null) 'topic_id': topicId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLatestAnswersCompanion copyWith({
    Value<String>? questionId,
    Value<int>? topicId,
    Value<bool>? isCorrect,
    Value<int>? rowid,
  }) {
    return LocalLatestAnswersCompanion(
      questionId: questionId ?? this.questionId,
      topicId: topicId ?? this.topicId,
      isCorrect: isCorrect ?? this.isCorrect,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLatestAnswersCompanion(')
          ..write('questionId: $questionId, ')
          ..write('topicId: $topicId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSubjectsTable extends LocalSubjects
    with TableInfo<$LocalSubjectsTable, LocalSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, slug, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $LocalSubjectsTable createAlias(String alias) {
    return $LocalSubjectsTable(attachedDatabase, alias);
  }
}

class LocalSubject extends DataClass implements Insertable<LocalSubject> {
  final int id;
  final String slug;
  final String name;

  /// Serverdəki sıra (siyahı eyni sıra ilə göstərilsin).
  final int position;
  const LocalSubject({
    required this.id,
    required this.slug,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  LocalSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalSubjectsCompanion(
      id: Value(id),
      slug: Value(slug),
      name: Value(name),
      position: Value(position),
    );
  }

  factory LocalSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubject(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  LocalSubject copyWith({int? id, String? slug, String? name, int? position}) =>
      LocalSubject(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        position: position ?? this.position,
      );
  LocalSubject copyWithCompanion(LocalSubjectsCompanion data) {
    return LocalSubject(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubject(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSubject &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.position == this.position);
}

class LocalSubjectsCompanion extends UpdateCompanion<LocalSubject> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> name;
  final Value<int> position;
  const LocalSubjectsCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
  });
  LocalSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String name,
    required int position,
  }) : slug = Value(slug),
       name = Value(name),
       position = Value(position);
  static Insertable<LocalSubject> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
    });
  }

  LocalSubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? name,
    Value<int>? position,
  }) {
    return LocalSubjectsCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalQuestionsTable localQuestions = $LocalQuestionsTable(this);
  late final $DownloadedTopicsTable downloadedTopics = $DownloadedTopicsTable(
    this,
  );
  late final $LocalImagesTable localImages = $LocalImagesTable(this);
  late final $PendingAnswersTable pendingAnswers = $PendingAnswersTable(this);
  late final $LocalLatestAnswersTable localLatestAnswers =
      $LocalLatestAnswersTable(this);
  late final $LocalSubjectsTable localSubjects = $LocalSubjectsTable(this);
  late final Index localQuestionsTopic = Index(
    'local_questions_topic',
    'CREATE INDEX local_questions_topic ON local_questions (topic_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localQuestions,
    downloadedTopics,
    localImages,
    pendingAnswers,
    localLatestAnswers,
    localSubjects,
    localQuestionsTopic,
  ];
}

typedef $$LocalQuestionsTableCreateCompanionBuilder =
    LocalQuestionsCompanion Function({
      required String id,
      Value<String?> code,
      required int topicId,
      required String type,
      required String body,
      Value<String?> imagePath,
      required String optionsJson,
      required String correctAnswer,
      required int difficulty,
      Value<String?> solution,
      Value<String?> solutionImagePath,
      Value<int> rowid,
    });
typedef $$LocalQuestionsTableUpdateCompanionBuilder =
    LocalQuestionsCompanion Function({
      Value<String> id,
      Value<String?> code,
      Value<int> topicId,
      Value<String> type,
      Value<String> body,
      Value<String?> imagePath,
      Value<String> optionsJson,
      Value<String> correctAnswer,
      Value<int> difficulty,
      Value<String?> solution,
      Value<String?> solutionImagePath,
      Value<int> rowid,
    });

class $$LocalQuestionsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solution => $composableBuilder(
    column: $table.solution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solutionImagePath => $composableBuilder(
    column: $table.solutionImagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuestionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solution => $composableBuilder(
    column: $table.solution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solutionImagePath => $composableBuilder(
    column: $table.solutionImagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuestionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get solution =>
      $composableBuilder(column: $table.solution, builder: (column) => column);

  GeneratedColumn<String> get solutionImagePath => $composableBuilder(
    column: $table.solutionImagePath,
    builder: (column) => column,
  );
}

class $$LocalQuestionsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalQuestionsTable,
          LocalQuestion,
          $$LocalQuestionsTableFilterComposer,
          $$LocalQuestionsTableOrderingComposer,
          $$LocalQuestionsTableAnnotationComposer,
          $$LocalQuestionsTableCreateCompanionBuilder,
          $$LocalQuestionsTableUpdateCompanionBuilder,
          (
            LocalQuestion,
            BaseReferences<
              _$LocalDatabase,
              $LocalQuestionsTable,
              LocalQuestion
            >,
          ),
          LocalQuestion,
          PrefetchHooks Function()
        > {
  $$LocalQuestionsTableTableManager(
    _$LocalDatabase db,
    $LocalQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> topicId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<String> correctAnswer = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String?> solution = const Value.absent(),
                Value<String?> solutionImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionsCompanion(
                id: id,
                code: code,
                topicId: topicId,
                type: type,
                body: body,
                imagePath: imagePath,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
                difficulty: difficulty,
                solution: solution,
                solutionImagePath: solutionImagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> code = const Value.absent(),
                required int topicId,
                required String type,
                required String body,
                Value<String?> imagePath = const Value.absent(),
                required String optionsJson,
                required String correctAnswer,
                required int difficulty,
                Value<String?> solution = const Value.absent(),
                Value<String?> solutionImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionsCompanion.insert(
                id: id,
                code: code,
                topicId: topicId,
                type: type,
                body: body,
                imagePath: imagePath,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
                difficulty: difficulty,
                solution: solution,
                solutionImagePath: solutionImagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalQuestionsTable, LocalQuestion>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $LocalQuestionsTable,
                    LocalQuestion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalQuestionsTable,
      LocalQuestion,
      $$LocalQuestionsTableFilterComposer,
      $$LocalQuestionsTableOrderingComposer,
      $$LocalQuestionsTableAnnotationComposer,
      $$LocalQuestionsTableCreateCompanionBuilder,
      $$LocalQuestionsTableUpdateCompanionBuilder,
      (
        LocalQuestion,
        BaseReferences<_$LocalDatabase, $LocalQuestionsTable, LocalQuestion>,
      ),
      LocalQuestion,
      PrefetchHooks Function()
    >;
typedef $$DownloadedTopicsTableCreateCompanionBuilder =
    DownloadedTopicsCompanion Function({
      Value<int> topicId,
      required int subjectId,
      required String topicName,
      Value<String?> sectionName,
      required int questionCount,
      required int version,
      required int imageCount,
      required int imageBytes,
      Value<int> imagesDone,
      required DateTime downloadedAt,
    });
typedef $$DownloadedTopicsTableUpdateCompanionBuilder =
    DownloadedTopicsCompanion Function({
      Value<int> topicId,
      Value<int> subjectId,
      Value<String> topicName,
      Value<String?> sectionName,
      Value<int> questionCount,
      Value<int> version,
      Value<int> imageCount,
      Value<int> imageBytes,
      Value<int> imagesDone,
      Value<DateTime> downloadedAt,
    });

class $$DownloadedTopicsTableFilterComposer
    extends Composer<_$LocalDatabase, $DownloadedTopicsTable> {
  $$DownloadedTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicName => $composableBuilder(
    column: $table.topicName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageCount => $composableBuilder(
    column: $table.imageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imagesDone => $composableBuilder(
    column: $table.imagesDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedTopicsTableOrderingComposer
    extends Composer<_$LocalDatabase, $DownloadedTopicsTable> {
  $$DownloadedTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicName => $composableBuilder(
    column: $table.topicName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageCount => $composableBuilder(
    column: $table.imageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imagesDone => $composableBuilder(
    column: $table.imagesDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedTopicsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $DownloadedTopicsTable> {
  $$DownloadedTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get topicName =>
      $composableBuilder(column: $table.topicName, builder: (column) => column);

  GeneratedColumn<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get imageCount => $composableBuilder(
    column: $table.imageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imagesDone => $composableBuilder(
    column: $table.imagesDone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$DownloadedTopicsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $DownloadedTopicsTable,
          DownloadedTopic,
          $$DownloadedTopicsTableFilterComposer,
          $$DownloadedTopicsTableOrderingComposer,
          $$DownloadedTopicsTableAnnotationComposer,
          $$DownloadedTopicsTableCreateCompanionBuilder,
          $$DownloadedTopicsTableUpdateCompanionBuilder,
          (
            DownloadedTopic,
            BaseReferences<
              _$LocalDatabase,
              $DownloadedTopicsTable,
              DownloadedTopic
            >,
          ),
          DownloadedTopic,
          PrefetchHooks Function()
        > {
  $$DownloadedTopicsTableTableManager(
    _$LocalDatabase db,
    $DownloadedTopicsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> topicId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<String> topicName = const Value.absent(),
                Value<String?> sectionName = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> imageCount = const Value.absent(),
                Value<int> imageBytes = const Value.absent(),
                Value<int> imagesDone = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => DownloadedTopicsCompanion(
                topicId: topicId,
                subjectId: subjectId,
                topicName: topicName,
                sectionName: sectionName,
                questionCount: questionCount,
                version: version,
                imageCount: imageCount,
                imageBytes: imageBytes,
                imagesDone: imagesDone,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> topicId = const Value.absent(),
                required int subjectId,
                required String topicName,
                Value<String?> sectionName = const Value.absent(),
                required int questionCount,
                required int version,
                required int imageCount,
                required int imageBytes,
                Value<int> imagesDone = const Value.absent(),
                required DateTime downloadedAt,
              }) => DownloadedTopicsCompanion.insert(
                topicId: topicId,
                subjectId: subjectId,
                topicName: topicName,
                sectionName: sectionName,
                questionCount: questionCount,
                version: version,
                imageCount: imageCount,
                imageBytes: imageBytes,
                imagesDone: imagesDone,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadedTopicsTable, DownloadedTopic>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $DownloadedTopicsTable,
                    DownloadedTopic
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $DownloadedTopicsTable,
      DownloadedTopic,
      $$DownloadedTopicsTableFilterComposer,
      $$DownloadedTopicsTableOrderingComposer,
      $$DownloadedTopicsTableAnnotationComposer,
      $$DownloadedTopicsTableCreateCompanionBuilder,
      $$DownloadedTopicsTableUpdateCompanionBuilder,
      (
        DownloadedTopic,
        BaseReferences<
          _$LocalDatabase,
          $DownloadedTopicsTable,
          DownloadedTopic
        >,
      ),
      DownloadedTopic,
      PrefetchHooks Function()
    >;
typedef $$LocalImagesTableCreateCompanionBuilder =
    LocalImagesCompanion Function({
      required String path,
      required int bytes,
      Value<int> rowid,
    });
typedef $$LocalImagesTableUpdateCompanionBuilder =
    LocalImagesCompanion Function({
      Value<String> path,
      Value<int> bytes,
      Value<int> rowid,
    });

class $$LocalImagesTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalImagesTable> {
  $$LocalImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalImagesTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalImagesTable> {
  $$LocalImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalImagesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalImagesTable> {
  $$LocalImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$LocalImagesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalImagesTable,
          LocalImage,
          $$LocalImagesTableFilterComposer,
          $$LocalImagesTableOrderingComposer,
          $$LocalImagesTableAnnotationComposer,
          $$LocalImagesTableCreateCompanionBuilder,
          $$LocalImagesTableUpdateCompanionBuilder,
          (
            LocalImage,
            BaseReferences<_$LocalDatabase, $LocalImagesTable, LocalImage>,
          ),
          LocalImage,
          PrefetchHooks Function()
        > {
  $$LocalImagesTableTableManager(_$LocalDatabase db, $LocalImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> path = const Value.absent(),
            Value<int> bytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalImagesCompanion(path: path, bytes: bytes, rowid: rowid),
          createCompanionCallback:
              ({
                required String path,
                required int bytes,
                Value<int> rowid = const Value.absent(),
              }) => LocalImagesCompanion.insert(
                path: path,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalImagesTable, LocalImage>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $LocalImagesTable,
                    LocalImage
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalImagesTable,
      LocalImage,
      $$LocalImagesTableFilterComposer,
      $$LocalImagesTableOrderingComposer,
      $$LocalImagesTableAnnotationComposer,
      $$LocalImagesTableCreateCompanionBuilder,
      $$LocalImagesTableUpdateCompanionBuilder,
      (
        LocalImage,
        BaseReferences<_$LocalDatabase, $LocalImagesTable, LocalImage>,
      ),
      LocalImage,
      PrefetchHooks Function()
    >;
typedef $$PendingAnswersTableCreateCompanionBuilder =
    PendingAnswersCompanion Function({
      Value<int> id,
      required String clientId,
      required String questionId,
      required int topicId,
      required int subjectId,
      Value<String?> givenAnswer,
      required bool isCorrect,
      Value<int> timeMs,
      required DateTime answeredAt,
    });
typedef $$PendingAnswersTableUpdateCompanionBuilder =
    PendingAnswersCompanion Function({
      Value<int> id,
      Value<String> clientId,
      Value<String> questionId,
      Value<int> topicId,
      Value<int> subjectId,
      Value<String?> givenAnswer,
      Value<bool> isCorrect,
      Value<int> timeMs,
      Value<DateTime> answeredAt,
    });

class $$PendingAnswersTableFilterComposer
    extends Composer<_$LocalDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingAnswersTableOrderingComposer
    extends Composer<_$LocalDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingAnswersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$PendingAnswersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PendingAnswersTable,
          PendingAnswer,
          $$PendingAnswersTableFilterComposer,
          $$PendingAnswersTableOrderingComposer,
          $$PendingAnswersTableAnnotationComposer,
          $$PendingAnswersTableCreateCompanionBuilder,
          $$PendingAnswersTableUpdateCompanionBuilder,
          (
            PendingAnswer,
            BaseReferences<
              _$LocalDatabase,
              $PendingAnswersTable,
              PendingAnswer
            >,
          ),
          PendingAnswer,
          PrefetchHooks Function()
        > {
  $$PendingAnswersTableTableManager(
    _$LocalDatabase db,
    $PendingAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<int> topicId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<String?> givenAnswer = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => PendingAnswersCompanion(
                id: id,
                clientId: clientId,
                questionId: questionId,
                topicId: topicId,
                subjectId: subjectId,
                givenAnswer: givenAnswer,
                isCorrect: isCorrect,
                timeMs: timeMs,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientId,
                required String questionId,
                required int topicId,
                required int subjectId,
                Value<String?> givenAnswer = const Value.absent(),
                required bool isCorrect,
                Value<int> timeMs = const Value.absent(),
                required DateTime answeredAt,
              }) => PendingAnswersCompanion.insert(
                id: id,
                clientId: clientId,
                questionId: questionId,
                topicId: topicId,
                subjectId: subjectId,
                givenAnswer: givenAnswer,
                isCorrect: isCorrect,
                timeMs: timeMs,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingAnswersTable, PendingAnswer>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $PendingAnswersTable,
                    PendingAnswer
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PendingAnswersTable,
      PendingAnswer,
      $$PendingAnswersTableFilterComposer,
      $$PendingAnswersTableOrderingComposer,
      $$PendingAnswersTableAnnotationComposer,
      $$PendingAnswersTableCreateCompanionBuilder,
      $$PendingAnswersTableUpdateCompanionBuilder,
      (
        PendingAnswer,
        BaseReferences<_$LocalDatabase, $PendingAnswersTable, PendingAnswer>,
      ),
      PendingAnswer,
      PrefetchHooks Function()
    >;
typedef $$LocalLatestAnswersTableCreateCompanionBuilder =
    LocalLatestAnswersCompanion Function({
      required String questionId,
      required int topicId,
      required bool isCorrect,
      Value<int> rowid,
    });
typedef $$LocalLatestAnswersTableUpdateCompanionBuilder =
    LocalLatestAnswersCompanion Function({
      Value<String> questionId,
      Value<int> topicId,
      Value<bool> isCorrect,
      Value<int> rowid,
    });

class $$LocalLatestAnswersTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalLatestAnswersTable> {
  $$LocalLatestAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLatestAnswersTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalLatestAnswersTable> {
  $$LocalLatestAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLatestAnswersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalLatestAnswersTable> {
  $$LocalLatestAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);
}

class $$LocalLatestAnswersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalLatestAnswersTable,
          LocalLatestAnswer,
          $$LocalLatestAnswersTableFilterComposer,
          $$LocalLatestAnswersTableOrderingComposer,
          $$LocalLatestAnswersTableAnnotationComposer,
          $$LocalLatestAnswersTableCreateCompanionBuilder,
          $$LocalLatestAnswersTableUpdateCompanionBuilder,
          (
            LocalLatestAnswer,
            BaseReferences<
              _$LocalDatabase,
              $LocalLatestAnswersTable,
              LocalLatestAnswer
            >,
          ),
          LocalLatestAnswer,
          PrefetchHooks Function()
        > {
  $$LocalLatestAnswersTableTableManager(
    _$LocalDatabase db,
    $LocalLatestAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLatestAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLatestAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLatestAnswersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> topicId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLatestAnswersCompanion(
                questionId: questionId,
                topicId: topicId,
                isCorrect: isCorrect,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required int topicId,
                required bool isCorrect,
                Value<int> rowid = const Value.absent(),
              }) => LocalLatestAnswersCompanion.insert(
                questionId: questionId,
                topicId: topicId,
                isCorrect: isCorrect,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalLatestAnswersTable, LocalLatestAnswer>(
                    table,
                  ),
                  BaseReferences<
                    _$LocalDatabase,
                    $LocalLatestAnswersTable,
                    LocalLatestAnswer
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLatestAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalLatestAnswersTable,
      LocalLatestAnswer,
      $$LocalLatestAnswersTableFilterComposer,
      $$LocalLatestAnswersTableOrderingComposer,
      $$LocalLatestAnswersTableAnnotationComposer,
      $$LocalLatestAnswersTableCreateCompanionBuilder,
      $$LocalLatestAnswersTableUpdateCompanionBuilder,
      (
        LocalLatestAnswer,
        BaseReferences<
          _$LocalDatabase,
          $LocalLatestAnswersTable,
          LocalLatestAnswer
        >,
      ),
      LocalLatestAnswer,
      PrefetchHooks Function()
    >;
typedef $$LocalSubjectsTableCreateCompanionBuilder =
    LocalSubjectsCompanion Function({
      Value<int> id,
      required String slug,
      required String name,
      required int position,
    });
typedef $$LocalSubjectsTableUpdateCompanionBuilder =
    LocalSubjectsCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> name,
      Value<int> position,
    });

class $$LocalSubjectsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSubjectsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSubjectsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$LocalSubjectsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalSubjectsTable,
          LocalSubject,
          $$LocalSubjectsTableFilterComposer,
          $$LocalSubjectsTableOrderingComposer,
          $$LocalSubjectsTableAnnotationComposer,
          $$LocalSubjectsTableCreateCompanionBuilder,
          $$LocalSubjectsTableUpdateCompanionBuilder,
          (
            LocalSubject,
            BaseReferences<_$LocalDatabase, $LocalSubjectsTable, LocalSubject>,
          ),
          LocalSubject,
          PrefetchHooks Function()
        > {
  $$LocalSubjectsTableTableManager(
    _$LocalDatabase db,
    $LocalSubjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => LocalSubjectsCompanion(
                id: id,
                slug: slug,
                name: name,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String name,
                required int position,
              }) => LocalSubjectsCompanion.insert(
                id: id,
                slug: slug,
                name: name,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSubjectsTable, LocalSubject>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $LocalSubjectsTable,
                    LocalSubject
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalSubjectsTable,
      LocalSubject,
      $$LocalSubjectsTableFilterComposer,
      $$LocalSubjectsTableOrderingComposer,
      $$LocalSubjectsTableAnnotationComposer,
      $$LocalSubjectsTableCreateCompanionBuilder,
      $$LocalSubjectsTableUpdateCompanionBuilder,
      (
        LocalSubject,
        BaseReferences<_$LocalDatabase, $LocalSubjectsTable, LocalSubject>,
      ),
      LocalSubject,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(_db, _db.localQuestions);
  $$DownloadedTopicsTableTableManager get downloadedTopics =>
      $$DownloadedTopicsTableTableManager(_db, _db.downloadedTopics);
  $$LocalImagesTableTableManager get localImages =>
      $$LocalImagesTableTableManager(_db, _db.localImages);
  $$PendingAnswersTableTableManager get pendingAnswers =>
      $$PendingAnswersTableTableManager(_db, _db.pendingAnswers);
  $$LocalLatestAnswersTableTableManager get localLatestAnswers =>
      $$LocalLatestAnswersTableTableManager(_db, _db.localLatestAnswers);
  $$LocalSubjectsTableTableManager get localSubjects =>
      $$LocalSubjectsTableTableManager(_db, _db.localSubjects);
}
