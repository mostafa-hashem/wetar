// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wetar_database.dart';

// ignore_for_file: type=lint
class $SelectedFoldersTable extends SelectedFolders
    with TableInfo<$SelectedFoldersTable, SelectedFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectedFoldersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _rootPathMeta = const VerificationMeta(
    'rootPath',
  );
  @override
  late final GeneratedColumn<String> rootPath = GeneratedColumn<String>(
    'root_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mediastore'),
  );
  static const VerificationMeta _bookmarkDataMeta = const VerificationMeta(
    'bookmarkData',
  );
  @override
  late final GeneratedColumn<String> bookmarkData = GeneratedColumn<String>(
    'bookmark_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeLabelMeta = const VerificationMeta(
    'volumeLabel',
  );
  @override
  late final GeneratedColumn<String> volumeLabel = GeneratedColumn<String>(
    'volume_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Device Storage'),
  );
  static const VerificationMeta _includeSubfoldersMeta = const VerificationMeta(
    'includeSubfolders',
  );
  @override
  late final GeneratedColumn<bool> includeSubfolders = GeneratedColumn<bool>(
    'include_subfolders',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_subfolders" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _excludedSubfoldersJsonMeta =
      const VerificationMeta('excludedSubfoldersJson');
  @override
  late final GeneratedColumn<String> excludedSubfoldersJson =
      GeneratedColumn<String>(
        'excluded_subfolders_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastScannedAtMeta = const VerificationMeta(
    'lastScannedAt',
  );
  @override
  late final GeneratedColumn<int> lastScannedAt = GeneratedColumn<int>(
    'last_scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootPath,
    sourceKind,
    bookmarkData,
    displayName,
    volumeLabel,
    includeSubfolders,
    excludedSubfoldersJson,
    isAvailable,
    addedAt,
    lastScannedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selected_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelectedFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('root_path')) {
      context.handle(
        _rootPathMeta,
        rootPath.isAcceptableOrUnknown(data['root_path']!, _rootPathMeta),
      );
    } else if (isInserting) {
      context.missing(_rootPathMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    }
    if (data.containsKey('bookmark_data')) {
      context.handle(
        _bookmarkDataMeta,
        bookmarkData.isAcceptableOrUnknown(
          data['bookmark_data']!,
          _bookmarkDataMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('volume_label')) {
      context.handle(
        _volumeLabelMeta,
        volumeLabel.isAcceptableOrUnknown(
          data['volume_label']!,
          _volumeLabelMeta,
        ),
      );
    }
    if (data.containsKey('include_subfolders')) {
      context.handle(
        _includeSubfoldersMeta,
        includeSubfolders.isAcceptableOrUnknown(
          data['include_subfolders']!,
          _includeSubfoldersMeta,
        ),
      );
    }
    if (data.containsKey('excluded_subfolders_json')) {
      context.handle(
        _excludedSubfoldersJsonMeta,
        excludedSubfoldersJson.isAcceptableOrUnknown(
          data['excluded_subfolders_json']!,
          _excludedSubfoldersJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_scanned_at')) {
      context.handle(
        _lastScannedAtMeta,
        lastScannedAt.isAcceptableOrUnknown(
          data['last_scanned_at']!,
          _lastScannedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SelectedFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectedFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rootPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_path'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      bookmarkData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmark_data'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      volumeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_label'],
      )!,
      includeSubfolders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_subfolders'],
      )!,
      excludedSubfoldersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excluded_subfolders_json'],
      )!,
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
      lastScannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scanned_at'],
      )!,
    );
  }

  @override
  $SelectedFoldersTable createAlias(String alias) {
    return $SelectedFoldersTable(attachedDatabase, alias);
  }
}

class SelectedFolder extends DataClass implements Insertable<SelectedFolder> {
  final int id;
  final String rootPath;
  final String sourceKind;
  final String? bookmarkData;
  final String displayName;
  final String volumeLabel;
  final bool includeSubfolders;
  final String excludedSubfoldersJson;
  final bool isAvailable;
  final int addedAt;
  final int lastScannedAt;
  const SelectedFolder({
    required this.id,
    required this.rootPath,
    required this.sourceKind,
    this.bookmarkData,
    required this.displayName,
    required this.volumeLabel,
    required this.includeSubfolders,
    required this.excludedSubfoldersJson,
    required this.isAvailable,
    required this.addedAt,
    required this.lastScannedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['root_path'] = Variable<String>(rootPath);
    map['source_kind'] = Variable<String>(sourceKind);
    if (!nullToAbsent || bookmarkData != null) {
      map['bookmark_data'] = Variable<String>(bookmarkData);
    }
    map['display_name'] = Variable<String>(displayName);
    map['volume_label'] = Variable<String>(volumeLabel);
    map['include_subfolders'] = Variable<bool>(includeSubfolders);
    map['excluded_subfolders_json'] = Variable<String>(excludedSubfoldersJson);
    map['is_available'] = Variable<bool>(isAvailable);
    map['added_at'] = Variable<int>(addedAt);
    map['last_scanned_at'] = Variable<int>(lastScannedAt);
    return map;
  }

  SelectedFoldersCompanion toCompanion(bool nullToAbsent) {
    return SelectedFoldersCompanion(
      id: Value(id),
      rootPath: Value(rootPath),
      sourceKind: Value(sourceKind),
      bookmarkData: bookmarkData == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkData),
      displayName: Value(displayName),
      volumeLabel: Value(volumeLabel),
      includeSubfolders: Value(includeSubfolders),
      excludedSubfoldersJson: Value(excludedSubfoldersJson),
      isAvailable: Value(isAvailable),
      addedAt: Value(addedAt),
      lastScannedAt: Value(lastScannedAt),
    );
  }

  factory SelectedFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectedFolder(
      id: serializer.fromJson<int>(json['id']),
      rootPath: serializer.fromJson<String>(json['rootPath']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      bookmarkData: serializer.fromJson<String?>(json['bookmarkData']),
      displayName: serializer.fromJson<String>(json['displayName']),
      volumeLabel: serializer.fromJson<String>(json['volumeLabel']),
      includeSubfolders: serializer.fromJson<bool>(json['includeSubfolders']),
      excludedSubfoldersJson: serializer.fromJson<String>(
        json['excludedSubfoldersJson'],
      ),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
      lastScannedAt: serializer.fromJson<int>(json['lastScannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rootPath': serializer.toJson<String>(rootPath),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'bookmarkData': serializer.toJson<String?>(bookmarkData),
      'displayName': serializer.toJson<String>(displayName),
      'volumeLabel': serializer.toJson<String>(volumeLabel),
      'includeSubfolders': serializer.toJson<bool>(includeSubfolders),
      'excludedSubfoldersJson': serializer.toJson<String>(
        excludedSubfoldersJson,
      ),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'addedAt': serializer.toJson<int>(addedAt),
      'lastScannedAt': serializer.toJson<int>(lastScannedAt),
    };
  }

  SelectedFolder copyWith({
    int? id,
    String? rootPath,
    String? sourceKind,
    Value<String?> bookmarkData = const Value.absent(),
    String? displayName,
    String? volumeLabel,
    bool? includeSubfolders,
    String? excludedSubfoldersJson,
    bool? isAvailable,
    int? addedAt,
    int? lastScannedAt,
  }) => SelectedFolder(
    id: id ?? this.id,
    rootPath: rootPath ?? this.rootPath,
    sourceKind: sourceKind ?? this.sourceKind,
    bookmarkData: bookmarkData.present ? bookmarkData.value : this.bookmarkData,
    displayName: displayName ?? this.displayName,
    volumeLabel: volumeLabel ?? this.volumeLabel,
    includeSubfolders: includeSubfolders ?? this.includeSubfolders,
    excludedSubfoldersJson:
        excludedSubfoldersJson ?? this.excludedSubfoldersJson,
    isAvailable: isAvailable ?? this.isAvailable,
    addedAt: addedAt ?? this.addedAt,
    lastScannedAt: lastScannedAt ?? this.lastScannedAt,
  );
  SelectedFolder copyWithCompanion(SelectedFoldersCompanion data) {
    return SelectedFolder(
      id: data.id.present ? data.id.value : this.id,
      rootPath: data.rootPath.present ? data.rootPath.value : this.rootPath,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      bookmarkData: data.bookmarkData.present
          ? data.bookmarkData.value
          : this.bookmarkData,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      volumeLabel: data.volumeLabel.present
          ? data.volumeLabel.value
          : this.volumeLabel,
      includeSubfolders: data.includeSubfolders.present
          ? data.includeSubfolders.value
          : this.includeSubfolders,
      excludedSubfoldersJson: data.excludedSubfoldersJson.present
          ? data.excludedSubfoldersJson.value
          : this.excludedSubfoldersJson,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastScannedAt: data.lastScannedAt.present
          ? data.lastScannedAt.value
          : this.lastScannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectedFolder(')
          ..write('id: $id, ')
          ..write('rootPath: $rootPath, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('bookmarkData: $bookmarkData, ')
          ..write('displayName: $displayName, ')
          ..write('volumeLabel: $volumeLabel, ')
          ..write('includeSubfolders: $includeSubfolders, ')
          ..write('excludedSubfoldersJson: $excludedSubfoldersJson, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastScannedAt: $lastScannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rootPath,
    sourceKind,
    bookmarkData,
    displayName,
    volumeLabel,
    includeSubfolders,
    excludedSubfoldersJson,
    isAvailable,
    addedAt,
    lastScannedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectedFolder &&
          other.id == this.id &&
          other.rootPath == this.rootPath &&
          other.sourceKind == this.sourceKind &&
          other.bookmarkData == this.bookmarkData &&
          other.displayName == this.displayName &&
          other.volumeLabel == this.volumeLabel &&
          other.includeSubfolders == this.includeSubfolders &&
          other.excludedSubfoldersJson == this.excludedSubfoldersJson &&
          other.isAvailable == this.isAvailable &&
          other.addedAt == this.addedAt &&
          other.lastScannedAt == this.lastScannedAt);
}

class SelectedFoldersCompanion extends UpdateCompanion<SelectedFolder> {
  final Value<int> id;
  final Value<String> rootPath;
  final Value<String> sourceKind;
  final Value<String?> bookmarkData;
  final Value<String> displayName;
  final Value<String> volumeLabel;
  final Value<bool> includeSubfolders;
  final Value<String> excludedSubfoldersJson;
  final Value<bool> isAvailable;
  final Value<int> addedAt;
  final Value<int> lastScannedAt;
  const SelectedFoldersCompanion({
    this.id = const Value.absent(),
    this.rootPath = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.bookmarkData = const Value.absent(),
    this.displayName = const Value.absent(),
    this.volumeLabel = const Value.absent(),
    this.includeSubfolders = const Value.absent(),
    this.excludedSubfoldersJson = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
  });
  SelectedFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String rootPath,
    this.sourceKind = const Value.absent(),
    this.bookmarkData = const Value.absent(),
    required String displayName,
    this.volumeLabel = const Value.absent(),
    this.includeSubfolders = const Value.absent(),
    this.excludedSubfoldersJson = const Value.absent(),
    this.isAvailable = const Value.absent(),
    required int addedAt,
    this.lastScannedAt = const Value.absent(),
  }) : rootPath = Value(rootPath),
       displayName = Value(displayName),
       addedAt = Value(addedAt);
  static Insertable<SelectedFolder> custom({
    Expression<int>? id,
    Expression<String>? rootPath,
    Expression<String>? sourceKind,
    Expression<String>? bookmarkData,
    Expression<String>? displayName,
    Expression<String>? volumeLabel,
    Expression<bool>? includeSubfolders,
    Expression<String>? excludedSubfoldersJson,
    Expression<bool>? isAvailable,
    Expression<int>? addedAt,
    Expression<int>? lastScannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootPath != null) 'root_path': rootPath,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (bookmarkData != null) 'bookmark_data': bookmarkData,
      if (displayName != null) 'display_name': displayName,
      if (volumeLabel != null) 'volume_label': volumeLabel,
      if (includeSubfolders != null) 'include_subfolders': includeSubfolders,
      if (excludedSubfoldersJson != null)
        'excluded_subfolders_json': excludedSubfoldersJson,
      if (isAvailable != null) 'is_available': isAvailable,
      if (addedAt != null) 'added_at': addedAt,
      if (lastScannedAt != null) 'last_scanned_at': lastScannedAt,
    });
  }

  SelectedFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? rootPath,
    Value<String>? sourceKind,
    Value<String?>? bookmarkData,
    Value<String>? displayName,
    Value<String>? volumeLabel,
    Value<bool>? includeSubfolders,
    Value<String>? excludedSubfoldersJson,
    Value<bool>? isAvailable,
    Value<int>? addedAt,
    Value<int>? lastScannedAt,
  }) {
    return SelectedFoldersCompanion(
      id: id ?? this.id,
      rootPath: rootPath ?? this.rootPath,
      sourceKind: sourceKind ?? this.sourceKind,
      bookmarkData: bookmarkData ?? this.bookmarkData,
      displayName: displayName ?? this.displayName,
      volumeLabel: volumeLabel ?? this.volumeLabel,
      includeSubfolders: includeSubfolders ?? this.includeSubfolders,
      excludedSubfoldersJson:
          excludedSubfoldersJson ?? this.excludedSubfoldersJson,
      isAvailable: isAvailable ?? this.isAvailable,
      addedAt: addedAt ?? this.addedAt,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rootPath.present) {
      map['root_path'] = Variable<String>(rootPath.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (bookmarkData.present) {
      map['bookmark_data'] = Variable<String>(bookmarkData.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (volumeLabel.present) {
      map['volume_label'] = Variable<String>(volumeLabel.value);
    }
    if (includeSubfolders.present) {
      map['include_subfolders'] = Variable<bool>(includeSubfolders.value);
    }
    if (excludedSubfoldersJson.present) {
      map['excluded_subfolders_json'] = Variable<String>(
        excludedSubfoldersJson.value,
      );
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (lastScannedAt.present) {
      map['last_scanned_at'] = Variable<int>(lastScannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectedFoldersCompanion(')
          ..write('id: $id, ')
          ..write('rootPath: $rootPath, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('bookmarkData: $bookmarkData, ')
          ..write('displayName: $displayName, ')
          ..write('volumeLabel: $volumeLabel, ')
          ..write('includeSubfolders: $includeSubfolders, ')
          ..write('excludedSubfoldersJson: $excludedSubfoldersJson, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastScannedAt: $lastScannedAt')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  @override
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES selected_folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderPathMeta = const VerificationMeta(
    'folderPath',
  );
  @override
  late final GeneratedColumn<String> folderPath = GeneratedColumn<String>(
    'folder_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNormalizedMeta = const VerificationMeta(
    'titleNormalized',
  );
  @override
  late final GeneratedColumn<String> titleNormalized = GeneratedColumn<String>(
    'title_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artistNormalizedMeta = const VerificationMeta(
    'artistNormalized',
  );
  @override
  late final GeneratedColumn<String> artistNormalized = GeneratedColumn<String>(
    'artist_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumNormalizedMeta = const VerificationMeta(
    'albumNormalized',
  );
  @override
  late final GeneratedColumn<String> albumNormalized = GeneratedColumn<String>(
    'album_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bitrateKbpsMeta = const VerificationMeta(
    'bitrateKbps',
  );
  @override
  late final GeneratedColumn<int> bitrateKbps = GeneratedColumn<int>(
    'bitrate_kbps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sampleRateHzMeta = const VerificationMeta(
    'sampleRateHz',
  );
  @override
  late final GeneratedColumn<int> sampleRateHz = GeneratedColumn<int>(
    'sample_rate_hz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _channelsMeta = const VerificationMeta(
    'channels',
  );
  @override
  late final GeneratedColumn<int> channels = GeneratedColumn<int>(
    'channels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('audio/*'),
  );
  static const VerificationMeta _dateModifiedSecMeta = const VerificationMeta(
    'dateModifiedSec',
  );
  @override
  late final GeneratedColumn<int> dateModifiedSec = GeneratedColumn<int>(
    'date_modified_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateAddedSecMeta = const VerificationMeta(
    'dateAddedSec',
  );
  @override
  late final GeneratedColumn<int> dateAddedSec = GeneratedColumn<int>(
    'date_added_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embeddedLyricsMeta = const VerificationMeta(
    'embeddedLyrics',
  );
  @override
  late final GeneratedColumn<String> embeddedLyrics = GeneratedColumn<String>(
    'embedded_lyrics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replayGainTrackDbMeta = const VerificationMeta(
    'replayGainTrackDb',
  );
  @override
  late final GeneratedColumn<double> replayGainTrackDb =
      GeneratedColumn<double>(
        'replay_gain_track_db',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _replayGainAlbumDbMeta = const VerificationMeta(
    'replayGainAlbumDb',
  );
  @override
  late final GeneratedColumn<double> replayGainAlbumDb =
      GeneratedColumn<double>(
        'replay_gain_album_db',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isCloudPendingMeta = const VerificationMeta(
    'isCloudPending',
  );
  @override
  late final GeneratedColumn<bool> isCloudPending = GeneratedColumn<bool>(
    'is_cloud_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cloud_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCorruptOrMissingMeta =
      const VerificationMeta('isCorruptOrMissing');
  @override
  late final GeneratedColumn<bool> isCorruptOrMissing = GeneratedColumn<bool>(
    'is_corrupt_or_missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_corrupt_or_missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableKey,
    folderId,
    uri,
    filePath,
    folderPath,
    title,
    titleNormalized,
    artist,
    artistNormalized,
    album,
    albumNormalized,
    albumArtist,
    genre,
    year,
    trackNumber,
    discNumber,
    durationMs,
    bitrateKbps,
    sampleRateHz,
    channels,
    sizeBytes,
    mimeType,
    dateModifiedSec,
    dateAddedSec,
    artworkUri,
    embeddedLyrics,
    replayGainTrackDb,
    replayGainAlbumDb,
    isCloudPending,
    isCorruptOrMissing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stableKeyMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('folder_path')) {
      context.handle(
        _folderPathMeta,
        folderPath.isAcceptableOrUnknown(data['folder_path']!, _folderPathMeta),
      );
    } else if (isInserting) {
      context.missing(_folderPathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_normalized')) {
      context.handle(
        _titleNormalizedMeta,
        titleNormalized.isAcceptableOrUnknown(
          data['title_normalized']!,
          _titleNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleNormalizedMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('artist_normalized')) {
      context.handle(
        _artistNormalizedMeta,
        artistNormalized.isAcceptableOrUnknown(
          data['artist_normalized']!,
          _artistNormalizedMeta,
        ),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('album_normalized')) {
      context.handle(
        _albumNormalizedMeta,
        albumNormalized.isAcceptableOrUnknown(
          data['album_normalized']!,
          _albumNormalizedMeta,
        ),
      );
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('bitrate_kbps')) {
      context.handle(
        _bitrateKbpsMeta,
        bitrateKbps.isAcceptableOrUnknown(
          data['bitrate_kbps']!,
          _bitrateKbpsMeta,
        ),
      );
    }
    if (data.containsKey('sample_rate_hz')) {
      context.handle(
        _sampleRateHzMeta,
        sampleRateHz.isAcceptableOrUnknown(
          data['sample_rate_hz']!,
          _sampleRateHzMeta,
        ),
      );
    }
    if (data.containsKey('channels')) {
      context.handle(
        _channelsMeta,
        channels.isAcceptableOrUnknown(data['channels']!, _channelsMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('date_modified_sec')) {
      context.handle(
        _dateModifiedSecMeta,
        dateModifiedSec.isAcceptableOrUnknown(
          data['date_modified_sec']!,
          _dateModifiedSecMeta,
        ),
      );
    }
    if (data.containsKey('date_added_sec')) {
      context.handle(
        _dateAddedSecMeta,
        dateAddedSec.isAcceptableOrUnknown(
          data['date_added_sec']!,
          _dateAddedSecMeta,
        ),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    }
    if (data.containsKey('embedded_lyrics')) {
      context.handle(
        _embeddedLyricsMeta,
        embeddedLyrics.isAcceptableOrUnknown(
          data['embedded_lyrics']!,
          _embeddedLyricsMeta,
        ),
      );
    }
    if (data.containsKey('replay_gain_track_db')) {
      context.handle(
        _replayGainTrackDbMeta,
        replayGainTrackDb.isAcceptableOrUnknown(
          data['replay_gain_track_db']!,
          _replayGainTrackDbMeta,
        ),
      );
    }
    if (data.containsKey('replay_gain_album_db')) {
      context.handle(
        _replayGainAlbumDbMeta,
        replayGainAlbumDb.isAcceptableOrUnknown(
          data['replay_gain_album_db']!,
          _replayGainAlbumDbMeta,
        ),
      );
    }
    if (data.containsKey('is_cloud_pending')) {
      context.handle(
        _isCloudPendingMeta,
        isCloudPending.isAcceptableOrUnknown(
          data['is_cloud_pending']!,
          _isCloudPendingMeta,
        ),
      );
    }
    if (data.containsKey('is_corrupt_or_missing')) {
      context.handle(
        _isCorruptOrMissingMeta,
        isCorruptOrMissing.isAcceptableOrUnknown(
          data['is_corrupt_or_missing']!,
          _isCorruptOrMissingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      folderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_normalized'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      artistNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_normalized'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_normalized'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      )!,
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      bitrateKbps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitrate_kbps'],
      )!,
      sampleRateHz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate_hz'],
      )!,
      channels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channels'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      dateModifiedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_modified_sec'],
      )!,
      dateAddedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added_sec'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      ),
      embeddedLyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedded_lyrics'],
      ),
      replayGainTrackDb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}replay_gain_track_db'],
      ),
      replayGainAlbumDb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}replay_gain_album_db'],
      ),
      isCloudPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cloud_pending'],
      )!,
      isCorruptOrMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_corrupt_or_missing'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final int id;
  final String stableKey;
  final int folderId;
  final String uri;
  final String filePath;
  final String folderPath;
  final String title;
  final String titleNormalized;
  final String artist;
  final String artistNormalized;
  final String album;
  final String albumNormalized;
  final String albumArtist;
  final String genre;
  final int year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
  final int bitrateKbps;
  final int sampleRateHz;
  final int channels;
  final int sizeBytes;
  final String mimeType;
  final int dateModifiedSec;
  final int dateAddedSec;
  final String? artworkUri;
  final String? embeddedLyrics;
  final double? replayGainTrackDb;
  final double? replayGainAlbumDb;
  final bool isCloudPending;
  final bool isCorruptOrMissing;
  const Track({
    required this.id,
    required this.stableKey,
    required this.folderId,
    required this.uri,
    required this.filePath,
    required this.folderPath,
    required this.title,
    required this.titleNormalized,
    required this.artist,
    required this.artistNormalized,
    required this.album,
    required this.albumNormalized,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.discNumber,
    required this.durationMs,
    required this.bitrateKbps,
    required this.sampleRateHz,
    required this.channels,
    required this.sizeBytes,
    required this.mimeType,
    required this.dateModifiedSec,
    required this.dateAddedSec,
    this.artworkUri,
    this.embeddedLyrics,
    this.replayGainTrackDb,
    this.replayGainAlbumDb,
    required this.isCloudPending,
    required this.isCorruptOrMissing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stable_key'] = Variable<String>(stableKey);
    map['folder_id'] = Variable<int>(folderId);
    map['uri'] = Variable<String>(uri);
    map['file_path'] = Variable<String>(filePath);
    map['folder_path'] = Variable<String>(folderPath);
    map['title'] = Variable<String>(title);
    map['title_normalized'] = Variable<String>(titleNormalized);
    map['artist'] = Variable<String>(artist);
    map['artist_normalized'] = Variable<String>(artistNormalized);
    map['album'] = Variable<String>(album);
    map['album_normalized'] = Variable<String>(albumNormalized);
    map['album_artist'] = Variable<String>(albumArtist);
    map['genre'] = Variable<String>(genre);
    map['year'] = Variable<int>(year);
    map['track_number'] = Variable<int>(trackNumber);
    map['disc_number'] = Variable<int>(discNumber);
    map['duration_ms'] = Variable<int>(durationMs);
    map['bitrate_kbps'] = Variable<int>(bitrateKbps);
    map['sample_rate_hz'] = Variable<int>(sampleRateHz);
    map['channels'] = Variable<int>(channels);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['mime_type'] = Variable<String>(mimeType);
    map['date_modified_sec'] = Variable<int>(dateModifiedSec);
    map['date_added_sec'] = Variable<int>(dateAddedSec);
    if (!nullToAbsent || artworkUri != null) {
      map['artwork_uri'] = Variable<String>(artworkUri);
    }
    if (!nullToAbsent || embeddedLyrics != null) {
      map['embedded_lyrics'] = Variable<String>(embeddedLyrics);
    }
    if (!nullToAbsent || replayGainTrackDb != null) {
      map['replay_gain_track_db'] = Variable<double>(replayGainTrackDb);
    }
    if (!nullToAbsent || replayGainAlbumDb != null) {
      map['replay_gain_album_db'] = Variable<double>(replayGainAlbumDb);
    }
    map['is_cloud_pending'] = Variable<bool>(isCloudPending);
    map['is_corrupt_or_missing'] = Variable<bool>(isCorruptOrMissing);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      stableKey: Value(stableKey),
      folderId: Value(folderId),
      uri: Value(uri),
      filePath: Value(filePath),
      folderPath: Value(folderPath),
      title: Value(title),
      titleNormalized: Value(titleNormalized),
      artist: Value(artist),
      artistNormalized: Value(artistNormalized),
      album: Value(album),
      albumNormalized: Value(albumNormalized),
      albumArtist: Value(albumArtist),
      genre: Value(genre),
      year: Value(year),
      trackNumber: Value(trackNumber),
      discNumber: Value(discNumber),
      durationMs: Value(durationMs),
      bitrateKbps: Value(bitrateKbps),
      sampleRateHz: Value(sampleRateHz),
      channels: Value(channels),
      sizeBytes: Value(sizeBytes),
      mimeType: Value(mimeType),
      dateModifiedSec: Value(dateModifiedSec),
      dateAddedSec: Value(dateAddedSec),
      artworkUri: artworkUri == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUri),
      embeddedLyrics: embeddedLyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddedLyrics),
      replayGainTrackDb: replayGainTrackDb == null && nullToAbsent
          ? const Value.absent()
          : Value(replayGainTrackDb),
      replayGainAlbumDb: replayGainAlbumDb == null && nullToAbsent
          ? const Value.absent()
          : Value(replayGainAlbumDb),
      isCloudPending: Value(isCloudPending),
      isCorruptOrMissing: Value(isCorruptOrMissing),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<int>(json['id']),
      stableKey: serializer.fromJson<String>(json['stableKey']),
      folderId: serializer.fromJson<int>(json['folderId']),
      uri: serializer.fromJson<String>(json['uri']),
      filePath: serializer.fromJson<String>(json['filePath']),
      folderPath: serializer.fromJson<String>(json['folderPath']),
      title: serializer.fromJson<String>(json['title']),
      titleNormalized: serializer.fromJson<String>(json['titleNormalized']),
      artist: serializer.fromJson<String>(json['artist']),
      artistNormalized: serializer.fromJson<String>(json['artistNormalized']),
      album: serializer.fromJson<String>(json['album']),
      albumNormalized: serializer.fromJson<String>(json['albumNormalized']),
      albumArtist: serializer.fromJson<String>(json['albumArtist']),
      genre: serializer.fromJson<String>(json['genre']),
      year: serializer.fromJson<int>(json['year']),
      trackNumber: serializer.fromJson<int>(json['trackNumber']),
      discNumber: serializer.fromJson<int>(json['discNumber']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      bitrateKbps: serializer.fromJson<int>(json['bitrateKbps']),
      sampleRateHz: serializer.fromJson<int>(json['sampleRateHz']),
      channels: serializer.fromJson<int>(json['channels']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      dateModifiedSec: serializer.fromJson<int>(json['dateModifiedSec']),
      dateAddedSec: serializer.fromJson<int>(json['dateAddedSec']),
      artworkUri: serializer.fromJson<String?>(json['artworkUri']),
      embeddedLyrics: serializer.fromJson<String?>(json['embeddedLyrics']),
      replayGainTrackDb: serializer.fromJson<double?>(
        json['replayGainTrackDb'],
      ),
      replayGainAlbumDb: serializer.fromJson<double?>(
        json['replayGainAlbumDb'],
      ),
      isCloudPending: serializer.fromJson<bool>(json['isCloudPending']),
      isCorruptOrMissing: serializer.fromJson<bool>(json['isCorruptOrMissing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stableKey': serializer.toJson<String>(stableKey),
      'folderId': serializer.toJson<int>(folderId),
      'uri': serializer.toJson<String>(uri),
      'filePath': serializer.toJson<String>(filePath),
      'folderPath': serializer.toJson<String>(folderPath),
      'title': serializer.toJson<String>(title),
      'titleNormalized': serializer.toJson<String>(titleNormalized),
      'artist': serializer.toJson<String>(artist),
      'artistNormalized': serializer.toJson<String>(artistNormalized),
      'album': serializer.toJson<String>(album),
      'albumNormalized': serializer.toJson<String>(albumNormalized),
      'albumArtist': serializer.toJson<String>(albumArtist),
      'genre': serializer.toJson<String>(genre),
      'year': serializer.toJson<int>(year),
      'trackNumber': serializer.toJson<int>(trackNumber),
      'discNumber': serializer.toJson<int>(discNumber),
      'durationMs': serializer.toJson<int>(durationMs),
      'bitrateKbps': serializer.toJson<int>(bitrateKbps),
      'sampleRateHz': serializer.toJson<int>(sampleRateHz),
      'channels': serializer.toJson<int>(channels),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'mimeType': serializer.toJson<String>(mimeType),
      'dateModifiedSec': serializer.toJson<int>(dateModifiedSec),
      'dateAddedSec': serializer.toJson<int>(dateAddedSec),
      'artworkUri': serializer.toJson<String?>(artworkUri),
      'embeddedLyrics': serializer.toJson<String?>(embeddedLyrics),
      'replayGainTrackDb': serializer.toJson<double?>(replayGainTrackDb),
      'replayGainAlbumDb': serializer.toJson<double?>(replayGainAlbumDb),
      'isCloudPending': serializer.toJson<bool>(isCloudPending),
      'isCorruptOrMissing': serializer.toJson<bool>(isCorruptOrMissing),
    };
  }

  Track copyWith({
    int? id,
    String? stableKey,
    int? folderId,
    String? uri,
    String? filePath,
    String? folderPath,
    String? title,
    String? titleNormalized,
    String? artist,
    String? artistNormalized,
    String? album,
    String? albumNormalized,
    String? albumArtist,
    String? genre,
    int? year,
    int? trackNumber,
    int? discNumber,
    int? durationMs,
    int? bitrateKbps,
    int? sampleRateHz,
    int? channels,
    int? sizeBytes,
    String? mimeType,
    int? dateModifiedSec,
    int? dateAddedSec,
    Value<String?> artworkUri = const Value.absent(),
    Value<String?> embeddedLyrics = const Value.absent(),
    Value<double?> replayGainTrackDb = const Value.absent(),
    Value<double?> replayGainAlbumDb = const Value.absent(),
    bool? isCloudPending,
    bool? isCorruptOrMissing,
  }) => Track(
    id: id ?? this.id,
    stableKey: stableKey ?? this.stableKey,
    folderId: folderId ?? this.folderId,
    uri: uri ?? this.uri,
    filePath: filePath ?? this.filePath,
    folderPath: folderPath ?? this.folderPath,
    title: title ?? this.title,
    titleNormalized: titleNormalized ?? this.titleNormalized,
    artist: artist ?? this.artist,
    artistNormalized: artistNormalized ?? this.artistNormalized,
    album: album ?? this.album,
    albumNormalized: albumNormalized ?? this.albumNormalized,
    albumArtist: albumArtist ?? this.albumArtist,
    genre: genre ?? this.genre,
    year: year ?? this.year,
    trackNumber: trackNumber ?? this.trackNumber,
    discNumber: discNumber ?? this.discNumber,
    durationMs: durationMs ?? this.durationMs,
    bitrateKbps: bitrateKbps ?? this.bitrateKbps,
    sampleRateHz: sampleRateHz ?? this.sampleRateHz,
    channels: channels ?? this.channels,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    mimeType: mimeType ?? this.mimeType,
    dateModifiedSec: dateModifiedSec ?? this.dateModifiedSec,
    dateAddedSec: dateAddedSec ?? this.dateAddedSec,
    artworkUri: artworkUri.present ? artworkUri.value : this.artworkUri,
    embeddedLyrics: embeddedLyrics.present
        ? embeddedLyrics.value
        : this.embeddedLyrics,
    replayGainTrackDb: replayGainTrackDb.present
        ? replayGainTrackDb.value
        : this.replayGainTrackDb,
    replayGainAlbumDb: replayGainAlbumDb.present
        ? replayGainAlbumDb.value
        : this.replayGainAlbumDb,
    isCloudPending: isCloudPending ?? this.isCloudPending,
    isCorruptOrMissing: isCorruptOrMissing ?? this.isCorruptOrMissing,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      uri: data.uri.present ? data.uri.value : this.uri,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      folderPath: data.folderPath.present
          ? data.folderPath.value
          : this.folderPath,
      title: data.title.present ? data.title.value : this.title,
      titleNormalized: data.titleNormalized.present
          ? data.titleNormalized.value
          : this.titleNormalized,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistNormalized: data.artistNormalized.present
          ? data.artistNormalized.value
          : this.artistNormalized,
      album: data.album.present ? data.album.value : this.album,
      albumNormalized: data.albumNormalized.present
          ? data.albumNormalized.value
          : this.albumNormalized,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      bitrateKbps: data.bitrateKbps.present
          ? data.bitrateKbps.value
          : this.bitrateKbps,
      sampleRateHz: data.sampleRateHz.present
          ? data.sampleRateHz.value
          : this.sampleRateHz,
      channels: data.channels.present ? data.channels.value : this.channels,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      dateModifiedSec: data.dateModifiedSec.present
          ? data.dateModifiedSec.value
          : this.dateModifiedSec,
      dateAddedSec: data.dateAddedSec.present
          ? data.dateAddedSec.value
          : this.dateAddedSec,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      embeddedLyrics: data.embeddedLyrics.present
          ? data.embeddedLyrics.value
          : this.embeddedLyrics,
      replayGainTrackDb: data.replayGainTrackDb.present
          ? data.replayGainTrackDb.value
          : this.replayGainTrackDb,
      replayGainAlbumDb: data.replayGainAlbumDb.present
          ? data.replayGainAlbumDb.value
          : this.replayGainAlbumDb,
      isCloudPending: data.isCloudPending.present
          ? data.isCloudPending.value
          : this.isCloudPending,
      isCorruptOrMissing: data.isCorruptOrMissing.present
          ? data.isCorruptOrMissing.value
          : this.isCorruptOrMissing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('stableKey: $stableKey, ')
          ..write('folderId: $folderId, ')
          ..write('uri: $uri, ')
          ..write('filePath: $filePath, ')
          ..write('folderPath: $folderPath, ')
          ..write('title: $title, ')
          ..write('titleNormalized: $titleNormalized, ')
          ..write('artist: $artist, ')
          ..write('artistNormalized: $artistNormalized, ')
          ..write('album: $album, ')
          ..write('albumNormalized: $albumNormalized, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('sampleRateHz: $sampleRateHz, ')
          ..write('channels: $channels, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('dateModifiedSec: $dateModifiedSec, ')
          ..write('dateAddedSec: $dateAddedSec, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('embeddedLyrics: $embeddedLyrics, ')
          ..write('replayGainTrackDb: $replayGainTrackDb, ')
          ..write('replayGainAlbumDb: $replayGainAlbumDb, ')
          ..write('isCloudPending: $isCloudPending, ')
          ..write('isCorruptOrMissing: $isCorruptOrMissing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    stableKey,
    folderId,
    uri,
    filePath,
    folderPath,
    title,
    titleNormalized,
    artist,
    artistNormalized,
    album,
    albumNormalized,
    albumArtist,
    genre,
    year,
    trackNumber,
    discNumber,
    durationMs,
    bitrateKbps,
    sampleRateHz,
    channels,
    sizeBytes,
    mimeType,
    dateModifiedSec,
    dateAddedSec,
    artworkUri,
    embeddedLyrics,
    replayGainTrackDb,
    replayGainAlbumDb,
    isCloudPending,
    isCorruptOrMissing,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.stableKey == this.stableKey &&
          other.folderId == this.folderId &&
          other.uri == this.uri &&
          other.filePath == this.filePath &&
          other.folderPath == this.folderPath &&
          other.title == this.title &&
          other.titleNormalized == this.titleNormalized &&
          other.artist == this.artist &&
          other.artistNormalized == this.artistNormalized &&
          other.album == this.album &&
          other.albumNormalized == this.albumNormalized &&
          other.albumArtist == this.albumArtist &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.trackNumber == this.trackNumber &&
          other.discNumber == this.discNumber &&
          other.durationMs == this.durationMs &&
          other.bitrateKbps == this.bitrateKbps &&
          other.sampleRateHz == this.sampleRateHz &&
          other.channels == this.channels &&
          other.sizeBytes == this.sizeBytes &&
          other.mimeType == this.mimeType &&
          other.dateModifiedSec == this.dateModifiedSec &&
          other.dateAddedSec == this.dateAddedSec &&
          other.artworkUri == this.artworkUri &&
          other.embeddedLyrics == this.embeddedLyrics &&
          other.replayGainTrackDb == this.replayGainTrackDb &&
          other.replayGainAlbumDb == this.replayGainAlbumDb &&
          other.isCloudPending == this.isCloudPending &&
          other.isCorruptOrMissing == this.isCorruptOrMissing);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<int> id;
  final Value<String> stableKey;
  final Value<int> folderId;
  final Value<String> uri;
  final Value<String> filePath;
  final Value<String> folderPath;
  final Value<String> title;
  final Value<String> titleNormalized;
  final Value<String> artist;
  final Value<String> artistNormalized;
  final Value<String> album;
  final Value<String> albumNormalized;
  final Value<String> albumArtist;
  final Value<String> genre;
  final Value<int> year;
  final Value<int> trackNumber;
  final Value<int> discNumber;
  final Value<int> durationMs;
  final Value<int> bitrateKbps;
  final Value<int> sampleRateHz;
  final Value<int> channels;
  final Value<int> sizeBytes;
  final Value<String> mimeType;
  final Value<int> dateModifiedSec;
  final Value<int> dateAddedSec;
  final Value<String?> artworkUri;
  final Value<String?> embeddedLyrics;
  final Value<double?> replayGainTrackDb;
  final Value<double?> replayGainAlbumDb;
  final Value<bool> isCloudPending;
  final Value<bool> isCorruptOrMissing;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.folderId = const Value.absent(),
    this.uri = const Value.absent(),
    this.filePath = const Value.absent(),
    this.folderPath = const Value.absent(),
    this.title = const Value.absent(),
    this.titleNormalized = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistNormalized = const Value.absent(),
    this.album = const Value.absent(),
    this.albumNormalized = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.bitrateKbps = const Value.absent(),
    this.sampleRateHz = const Value.absent(),
    this.channels = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.dateModifiedSec = const Value.absent(),
    this.dateAddedSec = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.embeddedLyrics = const Value.absent(),
    this.replayGainTrackDb = const Value.absent(),
    this.replayGainAlbumDb = const Value.absent(),
    this.isCloudPending = const Value.absent(),
    this.isCorruptOrMissing = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required String stableKey,
    required int folderId,
    required String uri,
    required String filePath,
    required String folderPath,
    required String title,
    required String titleNormalized,
    this.artist = const Value.absent(),
    this.artistNormalized = const Value.absent(),
    this.album = const Value.absent(),
    this.albumNormalized = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.bitrateKbps = const Value.absent(),
    this.sampleRateHz = const Value.absent(),
    this.channels = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.dateModifiedSec = const Value.absent(),
    this.dateAddedSec = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.embeddedLyrics = const Value.absent(),
    this.replayGainTrackDb = const Value.absent(),
    this.replayGainAlbumDb = const Value.absent(),
    this.isCloudPending = const Value.absent(),
    this.isCorruptOrMissing = const Value.absent(),
  }) : stableKey = Value(stableKey),
       folderId = Value(folderId),
       uri = Value(uri),
       filePath = Value(filePath),
       folderPath = Value(folderPath),
       title = Value(title),
       titleNormalized = Value(titleNormalized);
  static Insertable<Track> custom({
    Expression<int>? id,
    Expression<String>? stableKey,
    Expression<int>? folderId,
    Expression<String>? uri,
    Expression<String>? filePath,
    Expression<String>? folderPath,
    Expression<String>? title,
    Expression<String>? titleNormalized,
    Expression<String>? artist,
    Expression<String>? artistNormalized,
    Expression<String>? album,
    Expression<String>? albumNormalized,
    Expression<String>? albumArtist,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? trackNumber,
    Expression<int>? discNumber,
    Expression<int>? durationMs,
    Expression<int>? bitrateKbps,
    Expression<int>? sampleRateHz,
    Expression<int>? channels,
    Expression<int>? sizeBytes,
    Expression<String>? mimeType,
    Expression<int>? dateModifiedSec,
    Expression<int>? dateAddedSec,
    Expression<String>? artworkUri,
    Expression<String>? embeddedLyrics,
    Expression<double>? replayGainTrackDb,
    Expression<double>? replayGainAlbumDb,
    Expression<bool>? isCloudPending,
    Expression<bool>? isCorruptOrMissing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableKey != null) 'stable_key': stableKey,
      if (folderId != null) 'folder_id': folderId,
      if (uri != null) 'uri': uri,
      if (filePath != null) 'file_path': filePath,
      if (folderPath != null) 'folder_path': folderPath,
      if (title != null) 'title': title,
      if (titleNormalized != null) 'title_normalized': titleNormalized,
      if (artist != null) 'artist': artist,
      if (artistNormalized != null) 'artist_normalized': artistNormalized,
      if (album != null) 'album': album,
      if (albumNormalized != null) 'album_normalized': albumNormalized,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (trackNumber != null) 'track_number': trackNumber,
      if (discNumber != null) 'disc_number': discNumber,
      if (durationMs != null) 'duration_ms': durationMs,
      if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
      if (sampleRateHz != null) 'sample_rate_hz': sampleRateHz,
      if (channels != null) 'channels': channels,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (dateModifiedSec != null) 'date_modified_sec': dateModifiedSec,
      if (dateAddedSec != null) 'date_added_sec': dateAddedSec,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (embeddedLyrics != null) 'embedded_lyrics': embeddedLyrics,
      if (replayGainTrackDb != null) 'replay_gain_track_db': replayGainTrackDb,
      if (replayGainAlbumDb != null) 'replay_gain_album_db': replayGainAlbumDb,
      if (isCloudPending != null) 'is_cloud_pending': isCloudPending,
      if (isCorruptOrMissing != null)
        'is_corrupt_or_missing': isCorruptOrMissing,
    });
  }

  TracksCompanion copyWith({
    Value<int>? id,
    Value<String>? stableKey,
    Value<int>? folderId,
    Value<String>? uri,
    Value<String>? filePath,
    Value<String>? folderPath,
    Value<String>? title,
    Value<String>? titleNormalized,
    Value<String>? artist,
    Value<String>? artistNormalized,
    Value<String>? album,
    Value<String>? albumNormalized,
    Value<String>? albumArtist,
    Value<String>? genre,
    Value<int>? year,
    Value<int>? trackNumber,
    Value<int>? discNumber,
    Value<int>? durationMs,
    Value<int>? bitrateKbps,
    Value<int>? sampleRateHz,
    Value<int>? channels,
    Value<int>? sizeBytes,
    Value<String>? mimeType,
    Value<int>? dateModifiedSec,
    Value<int>? dateAddedSec,
    Value<String?>? artworkUri,
    Value<String?>? embeddedLyrics,
    Value<double?>? replayGainTrackDb,
    Value<double?>? replayGainAlbumDb,
    Value<bool>? isCloudPending,
    Value<bool>? isCorruptOrMissing,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      stableKey: stableKey ?? this.stableKey,
      folderId: folderId ?? this.folderId,
      uri: uri ?? this.uri,
      filePath: filePath ?? this.filePath,
      folderPath: folderPath ?? this.folderPath,
      title: title ?? this.title,
      titleNormalized: titleNormalized ?? this.titleNormalized,
      artist: artist ?? this.artist,
      artistNormalized: artistNormalized ?? this.artistNormalized,
      album: album ?? this.album,
      albumNormalized: albumNormalized ?? this.albumNormalized,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      durationMs: durationMs ?? this.durationMs,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      sampleRateHz: sampleRateHz ?? this.sampleRateHz,
      channels: channels ?? this.channels,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      dateModifiedSec: dateModifiedSec ?? this.dateModifiedSec,
      dateAddedSec: dateAddedSec ?? this.dateAddedSec,
      artworkUri: artworkUri ?? this.artworkUri,
      embeddedLyrics: embeddedLyrics ?? this.embeddedLyrics,
      replayGainTrackDb: replayGainTrackDb ?? this.replayGainTrackDb,
      replayGainAlbumDb: replayGainAlbumDb ?? this.replayGainAlbumDb,
      isCloudPending: isCloudPending ?? this.isCloudPending,
      isCorruptOrMissing: isCorruptOrMissing ?? this.isCorruptOrMissing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (folderPath.present) {
      map['folder_path'] = Variable<String>(folderPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleNormalized.present) {
      map['title_normalized'] = Variable<String>(titleNormalized.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistNormalized.present) {
      map['artist_normalized'] = Variable<String>(artistNormalized.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumNormalized.present) {
      map['album_normalized'] = Variable<String>(albumNormalized.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (bitrateKbps.present) {
      map['bitrate_kbps'] = Variable<int>(bitrateKbps.value);
    }
    if (sampleRateHz.present) {
      map['sample_rate_hz'] = Variable<int>(sampleRateHz.value);
    }
    if (channels.present) {
      map['channels'] = Variable<int>(channels.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (dateModifiedSec.present) {
      map['date_modified_sec'] = Variable<int>(dateModifiedSec.value);
    }
    if (dateAddedSec.present) {
      map['date_added_sec'] = Variable<int>(dateAddedSec.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (embeddedLyrics.present) {
      map['embedded_lyrics'] = Variable<String>(embeddedLyrics.value);
    }
    if (replayGainTrackDb.present) {
      map['replay_gain_track_db'] = Variable<double>(replayGainTrackDb.value);
    }
    if (replayGainAlbumDb.present) {
      map['replay_gain_album_db'] = Variable<double>(replayGainAlbumDb.value);
    }
    if (isCloudPending.present) {
      map['is_cloud_pending'] = Variable<bool>(isCloudPending.value);
    }
    if (isCorruptOrMissing.present) {
      map['is_corrupt_or_missing'] = Variable<bool>(isCorruptOrMissing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('stableKey: $stableKey, ')
          ..write('folderId: $folderId, ')
          ..write('uri: $uri, ')
          ..write('filePath: $filePath, ')
          ..write('folderPath: $folderPath, ')
          ..write('title: $title, ')
          ..write('titleNormalized: $titleNormalized, ')
          ..write('artist: $artist, ')
          ..write('artistNormalized: $artistNormalized, ')
          ..write('album: $album, ')
          ..write('albumNormalized: $albumNormalized, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('sampleRateHz: $sampleRateHz, ')
          ..write('channels: $channels, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('dateModifiedSec: $dateModifiedSec, ')
          ..write('dateAddedSec: $dateAddedSec, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('embeddedLyrics: $embeddedLyrics, ')
          ..write('replayGainTrackDb: $replayGainTrackDb, ')
          ..write('replayGainAlbumDb: $replayGainAlbumDb, ')
          ..write('isCloudPending: $isCloudPending, ')
          ..write('isCorruptOrMissing: $isCorruptOrMissing')
          ..write(')'))
        .toString();
  }
}

class $AlbumPalettesTable extends AlbumPalettes
    with TableInfo<$AlbumPalettesTable, AlbumPalette> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumPalettesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _albumKeyMeta = const VerificationMeta(
    'albumKey',
  );
  @override
  late final GeneratedColumn<String> albumKey = GeneratedColumn<String>(
    'album_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryArgbMeta = const VerificationMeta(
    'primaryArgb',
  );
  @override
  late final GeneratedColumn<int> primaryArgb = GeneratedColumn<int>(
    'primary_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryArgbMeta = const VerificationMeta(
    'secondaryArgb',
  );
  @override
  late final GeneratedColumn<int> secondaryArgb = GeneratedColumn<int>(
    'secondary_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundArgbMeta = const VerificationMeta(
    'backgroundArgb',
  );
  @override
  late final GeneratedColumn<int> backgroundArgb = GeneratedColumn<int>(
    'background_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDarkMeta = const VerificationMeta('isDark');
  @override
  late final GeneratedColumn<bool> isDark = GeneratedColumn<bool>(
    'is_dark',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dark" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    albumKey,
    primaryArgb,
    secondaryArgb,
    backgroundArgb,
    isDark,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_palettes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumPalette> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('album_key')) {
      context.handle(
        _albumKeyMeta,
        albumKey.isAcceptableOrUnknown(data['album_key']!, _albumKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_albumKeyMeta);
    }
    if (data.containsKey('primary_argb')) {
      context.handle(
        _primaryArgbMeta,
        primaryArgb.isAcceptableOrUnknown(
          data['primary_argb']!,
          _primaryArgbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryArgbMeta);
    }
    if (data.containsKey('secondary_argb')) {
      context.handle(
        _secondaryArgbMeta,
        secondaryArgb.isAcceptableOrUnknown(
          data['secondary_argb']!,
          _secondaryArgbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryArgbMeta);
    }
    if (data.containsKey('background_argb')) {
      context.handle(
        _backgroundArgbMeta,
        backgroundArgb.isAcceptableOrUnknown(
          data['background_argb']!,
          _backgroundArgbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backgroundArgbMeta);
    }
    if (data.containsKey('is_dark')) {
      context.handle(
        _isDarkMeta,
        isDark.isAcceptableOrUnknown(data['is_dark']!, _isDarkMeta),
      );
    } else if (isInserting) {
      context.missing(_isDarkMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {albumKey};
  @override
  AlbumPalette map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumPalette(
      albumKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_key'],
      )!,
      primaryArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_argb'],
      )!,
      secondaryArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}secondary_argb'],
      )!,
      backgroundArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}background_argb'],
      )!,
      isDark: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dark'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AlbumPalettesTable createAlias(String alias) {
    return $AlbumPalettesTable(attachedDatabase, alias);
  }
}

class AlbumPalette extends DataClass implements Insertable<AlbumPalette> {
  final String albumKey;
  final int primaryArgb;
  final int secondaryArgb;
  final int backgroundArgb;
  final bool isDark;
  final int updatedAt;
  const AlbumPalette({
    required this.albumKey,
    required this.primaryArgb,
    required this.secondaryArgb,
    required this.backgroundArgb,
    required this.isDark,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['album_key'] = Variable<String>(albumKey);
    map['primary_argb'] = Variable<int>(primaryArgb);
    map['secondary_argb'] = Variable<int>(secondaryArgb);
    map['background_argb'] = Variable<int>(backgroundArgb);
    map['is_dark'] = Variable<bool>(isDark);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AlbumPalettesCompanion toCompanion(bool nullToAbsent) {
    return AlbumPalettesCompanion(
      albumKey: Value(albumKey),
      primaryArgb: Value(primaryArgb),
      secondaryArgb: Value(secondaryArgb),
      backgroundArgb: Value(backgroundArgb),
      isDark: Value(isDark),
      updatedAt: Value(updatedAt),
    );
  }

  factory AlbumPalette.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumPalette(
      albumKey: serializer.fromJson<String>(json['albumKey']),
      primaryArgb: serializer.fromJson<int>(json['primaryArgb']),
      secondaryArgb: serializer.fromJson<int>(json['secondaryArgb']),
      backgroundArgb: serializer.fromJson<int>(json['backgroundArgb']),
      isDark: serializer.fromJson<bool>(json['isDark']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'albumKey': serializer.toJson<String>(albumKey),
      'primaryArgb': serializer.toJson<int>(primaryArgb),
      'secondaryArgb': serializer.toJson<int>(secondaryArgb),
      'backgroundArgb': serializer.toJson<int>(backgroundArgb),
      'isDark': serializer.toJson<bool>(isDark),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AlbumPalette copyWith({
    String? albumKey,
    int? primaryArgb,
    int? secondaryArgb,
    int? backgroundArgb,
    bool? isDark,
    int? updatedAt,
  }) => AlbumPalette(
    albumKey: albumKey ?? this.albumKey,
    primaryArgb: primaryArgb ?? this.primaryArgb,
    secondaryArgb: secondaryArgb ?? this.secondaryArgb,
    backgroundArgb: backgroundArgb ?? this.backgroundArgb,
    isDark: isDark ?? this.isDark,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AlbumPalette copyWithCompanion(AlbumPalettesCompanion data) {
    return AlbumPalette(
      albumKey: data.albumKey.present ? data.albumKey.value : this.albumKey,
      primaryArgb: data.primaryArgb.present
          ? data.primaryArgb.value
          : this.primaryArgb,
      secondaryArgb: data.secondaryArgb.present
          ? data.secondaryArgb.value
          : this.secondaryArgb,
      backgroundArgb: data.backgroundArgb.present
          ? data.backgroundArgb.value
          : this.backgroundArgb,
      isDark: data.isDark.present ? data.isDark.value : this.isDark,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPalette(')
          ..write('albumKey: $albumKey, ')
          ..write('primaryArgb: $primaryArgb, ')
          ..write('secondaryArgb: $secondaryArgb, ')
          ..write('backgroundArgb: $backgroundArgb, ')
          ..write('isDark: $isDark, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    albumKey,
    primaryArgb,
    secondaryArgb,
    backgroundArgb,
    isDark,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumPalette &&
          other.albumKey == this.albumKey &&
          other.primaryArgb == this.primaryArgb &&
          other.secondaryArgb == this.secondaryArgb &&
          other.backgroundArgb == this.backgroundArgb &&
          other.isDark == this.isDark &&
          other.updatedAt == this.updatedAt);
}

class AlbumPalettesCompanion extends UpdateCompanion<AlbumPalette> {
  final Value<String> albumKey;
  final Value<int> primaryArgb;
  final Value<int> secondaryArgb;
  final Value<int> backgroundArgb;
  final Value<bool> isDark;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AlbumPalettesCompanion({
    this.albumKey = const Value.absent(),
    this.primaryArgb = const Value.absent(),
    this.secondaryArgb = const Value.absent(),
    this.backgroundArgb = const Value.absent(),
    this.isDark = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumPalettesCompanion.insert({
    required String albumKey,
    required int primaryArgb,
    required int secondaryArgb,
    required int backgroundArgb,
    required bool isDark,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : albumKey = Value(albumKey),
       primaryArgb = Value(primaryArgb),
       secondaryArgb = Value(secondaryArgb),
       backgroundArgb = Value(backgroundArgb),
       isDark = Value(isDark),
       updatedAt = Value(updatedAt);
  static Insertable<AlbumPalette> custom({
    Expression<String>? albumKey,
    Expression<int>? primaryArgb,
    Expression<int>? secondaryArgb,
    Expression<int>? backgroundArgb,
    Expression<bool>? isDark,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (albumKey != null) 'album_key': albumKey,
      if (primaryArgb != null) 'primary_argb': primaryArgb,
      if (secondaryArgb != null) 'secondary_argb': secondaryArgb,
      if (backgroundArgb != null) 'background_argb': backgroundArgb,
      if (isDark != null) 'is_dark': isDark,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumPalettesCompanion copyWith({
    Value<String>? albumKey,
    Value<int>? primaryArgb,
    Value<int>? secondaryArgb,
    Value<int>? backgroundArgb,
    Value<bool>? isDark,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AlbumPalettesCompanion(
      albumKey: albumKey ?? this.albumKey,
      primaryArgb: primaryArgb ?? this.primaryArgb,
      secondaryArgb: secondaryArgb ?? this.secondaryArgb,
      backgroundArgb: backgroundArgb ?? this.backgroundArgb,
      isDark: isDark ?? this.isDark,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (albumKey.present) {
      map['album_key'] = Variable<String>(albumKey.value);
    }
    if (primaryArgb.present) {
      map['primary_argb'] = Variable<int>(primaryArgb.value);
    }
    if (secondaryArgb.present) {
      map['secondary_argb'] = Variable<int>(secondaryArgb.value);
    }
    if (backgroundArgb.present) {
      map['background_argb'] = Variable<int>(backgroundArgb.value);
    }
    if (isDark.present) {
      map['is_dark'] = Variable<bool>(isDark.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPalettesCompanion(')
          ..write('albumKey: $albumKey, ')
          ..write('primaryArgb: $primaryArgb, ')
          ..write('secondaryArgb: $secondaryArgb, ')
          ..write('backgroundArgb: $backgroundArgb, ')
          ..write('isDark: $isDark, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackUserMetaTable extends TrackUserMeta
    with TableInfo<$TrackUserMetaTable, TrackUserMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackUserMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  @override
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rememberedPositionMsMeta =
      const VerificationMeta('rememberedPositionMs');
  @override
  late final GeneratedColumn<int> rememberedPositionMs = GeneratedColumn<int>(
    'remembered_position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachedLrcPathMeta = const VerificationMeta(
    'attachedLrcPath',
  );
  @override
  late final GeneratedColumn<String> attachedLrcPath = GeneratedColumn<String>(
    'attached_lrc_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lyricOffsetMsMeta = const VerificationMeta(
    'lyricOffsetMs',
  );
  @override
  late final GeneratedColumn<int> lyricOffsetMs = GeneratedColumn<int>(
    'lyric_offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customArtPathMeta = const VerificationMeta(
    'customArtPath',
  );
  @override
  late final GeneratedColumn<String> customArtPath = GeneratedColumn<String>(
    'custom_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stableKey,
    isFavorite,
    playCount,
    lastPlayedAt,
    rememberedPositionMs,
    attachedLrcPath,
    lyricOffsetMs,
    customArtPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_user_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackUserMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stableKeyMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('remembered_position_ms')) {
      context.handle(
        _rememberedPositionMsMeta,
        rememberedPositionMs.isAcceptableOrUnknown(
          data['remembered_position_ms']!,
          _rememberedPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('attached_lrc_path')) {
      context.handle(
        _attachedLrcPathMeta,
        attachedLrcPath.isAcceptableOrUnknown(
          data['attached_lrc_path']!,
          _attachedLrcPathMeta,
        ),
      );
    }
    if (data.containsKey('lyric_offset_ms')) {
      context.handle(
        _lyricOffsetMsMeta,
        lyricOffsetMs.isAcceptableOrUnknown(
          data['lyric_offset_ms']!,
          _lyricOffsetMsMeta,
        ),
      );
    }
    if (data.containsKey('custom_art_path')) {
      context.handle(
        _customArtPathMeta,
        customArtPath.isAcceptableOrUnknown(
          data['custom_art_path']!,
          _customArtPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stableKey};
  @override
  TrackUserMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackUserMetaData(
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_at'],
      ),
      rememberedPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remembered_position_ms'],
      ),
      attachedLrcPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attached_lrc_path'],
      ),
      lyricOffsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lyric_offset_ms'],
      )!,
      customArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_art_path'],
      ),
    );
  }

  @override
  $TrackUserMetaTable createAlias(String alias) {
    return $TrackUserMetaTable(attachedDatabase, alias);
  }
}

class TrackUserMetaData extends DataClass
    implements Insertable<TrackUserMetaData> {
  final String stableKey;
  final bool isFavorite;
  final int playCount;
  final int? lastPlayedAt;
  final int? rememberedPositionMs;
  final String? attachedLrcPath;
  final int lyricOffsetMs;
  final String? customArtPath;
  const TrackUserMetaData({
    required this.stableKey,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayedAt,
    this.rememberedPositionMs,
    this.attachedLrcPath,
    required this.lyricOffsetMs,
    this.customArtPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stable_key'] = Variable<String>(stableKey);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    if (!nullToAbsent || rememberedPositionMs != null) {
      map['remembered_position_ms'] = Variable<int>(rememberedPositionMs);
    }
    if (!nullToAbsent || attachedLrcPath != null) {
      map['attached_lrc_path'] = Variable<String>(attachedLrcPath);
    }
    map['lyric_offset_ms'] = Variable<int>(lyricOffsetMs);
    if (!nullToAbsent || customArtPath != null) {
      map['custom_art_path'] = Variable<String>(customArtPath);
    }
    return map;
  }

  TrackUserMetaCompanion toCompanion(bool nullToAbsent) {
    return TrackUserMetaCompanion(
      stableKey: Value(stableKey),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      rememberedPositionMs: rememberedPositionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(rememberedPositionMs),
      attachedLrcPath: attachedLrcPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachedLrcPath),
      lyricOffsetMs: Value(lyricOffsetMs),
      customArtPath: customArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customArtPath),
    );
  }

  factory TrackUserMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackUserMetaData(
      stableKey: serializer.fromJson<String>(json['stableKey']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<int?>(json['lastPlayedAt']),
      rememberedPositionMs: serializer.fromJson<int?>(
        json['rememberedPositionMs'],
      ),
      attachedLrcPath: serializer.fromJson<String?>(json['attachedLrcPath']),
      lyricOffsetMs: serializer.fromJson<int>(json['lyricOffsetMs']),
      customArtPath: serializer.fromJson<String?>(json['customArtPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stableKey': serializer.toJson<String>(stableKey),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<int?>(lastPlayedAt),
      'rememberedPositionMs': serializer.toJson<int?>(rememberedPositionMs),
      'attachedLrcPath': serializer.toJson<String?>(attachedLrcPath),
      'lyricOffsetMs': serializer.toJson<int>(lyricOffsetMs),
      'customArtPath': serializer.toJson<String?>(customArtPath),
    };
  }

  TrackUserMetaData copyWith({
    String? stableKey,
    bool? isFavorite,
    int? playCount,
    Value<int?> lastPlayedAt = const Value.absent(),
    Value<int?> rememberedPositionMs = const Value.absent(),
    Value<String?> attachedLrcPath = const Value.absent(),
    int? lyricOffsetMs,
    Value<String?> customArtPath = const Value.absent(),
  }) => TrackUserMetaData(
    stableKey: stableKey ?? this.stableKey,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    rememberedPositionMs: rememberedPositionMs.present
        ? rememberedPositionMs.value
        : this.rememberedPositionMs,
    attachedLrcPath: attachedLrcPath.present
        ? attachedLrcPath.value
        : this.attachedLrcPath,
    lyricOffsetMs: lyricOffsetMs ?? this.lyricOffsetMs,
    customArtPath: customArtPath.present
        ? customArtPath.value
        : this.customArtPath,
  );
  TrackUserMetaData copyWithCompanion(TrackUserMetaCompanion data) {
    return TrackUserMetaData(
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      rememberedPositionMs: data.rememberedPositionMs.present
          ? data.rememberedPositionMs.value
          : this.rememberedPositionMs,
      attachedLrcPath: data.attachedLrcPath.present
          ? data.attachedLrcPath.value
          : this.attachedLrcPath,
      lyricOffsetMs: data.lyricOffsetMs.present
          ? data.lyricOffsetMs.value
          : this.lyricOffsetMs,
      customArtPath: data.customArtPath.present
          ? data.customArtPath.value
          : this.customArtPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackUserMetaData(')
          ..write('stableKey: $stableKey, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rememberedPositionMs: $rememberedPositionMs, ')
          ..write('attachedLrcPath: $attachedLrcPath, ')
          ..write('lyricOffsetMs: $lyricOffsetMs, ')
          ..write('customArtPath: $customArtPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stableKey,
    isFavorite,
    playCount,
    lastPlayedAt,
    rememberedPositionMs,
    attachedLrcPath,
    lyricOffsetMs,
    customArtPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackUserMetaData &&
          other.stableKey == this.stableKey &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.rememberedPositionMs == this.rememberedPositionMs &&
          other.attachedLrcPath == this.attachedLrcPath &&
          other.lyricOffsetMs == this.lyricOffsetMs &&
          other.customArtPath == this.customArtPath);
}

class TrackUserMetaCompanion extends UpdateCompanion<TrackUserMetaData> {
  final Value<String> stableKey;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<int?> lastPlayedAt;
  final Value<int?> rememberedPositionMs;
  final Value<String?> attachedLrcPath;
  final Value<int> lyricOffsetMs;
  final Value<String?> customArtPath;
  final Value<int> rowid;
  const TrackUserMetaCompanion({
    this.stableKey = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rememberedPositionMs = const Value.absent(),
    this.attachedLrcPath = const Value.absent(),
    this.lyricOffsetMs = const Value.absent(),
    this.customArtPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackUserMetaCompanion.insert({
    required String stableKey,
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rememberedPositionMs = const Value.absent(),
    this.attachedLrcPath = const Value.absent(),
    this.lyricOffsetMs = const Value.absent(),
    this.customArtPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stableKey = Value(stableKey);
  static Insertable<TrackUserMetaData> custom({
    Expression<String>? stableKey,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<int>? lastPlayedAt,
    Expression<int>? rememberedPositionMs,
    Expression<String>? attachedLrcPath,
    Expression<int>? lyricOffsetMs,
    Expression<String>? customArtPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stableKey != null) 'stable_key': stableKey,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (rememberedPositionMs != null)
        'remembered_position_ms': rememberedPositionMs,
      if (attachedLrcPath != null) 'attached_lrc_path': attachedLrcPath,
      if (lyricOffsetMs != null) 'lyric_offset_ms': lyricOffsetMs,
      if (customArtPath != null) 'custom_art_path': customArtPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackUserMetaCompanion copyWith({
    Value<String>? stableKey,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<int?>? lastPlayedAt,
    Value<int?>? rememberedPositionMs,
    Value<String?>? attachedLrcPath,
    Value<int>? lyricOffsetMs,
    Value<String?>? customArtPath,
    Value<int>? rowid,
  }) {
    return TrackUserMetaCompanion(
      stableKey: stableKey ?? this.stableKey,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rememberedPositionMs: rememberedPositionMs ?? this.rememberedPositionMs,
      attachedLrcPath: attachedLrcPath ?? this.attachedLrcPath,
      lyricOffsetMs: lyricOffsetMs ?? this.lyricOffsetMs,
      customArtPath: customArtPath ?? this.customArtPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (rememberedPositionMs.present) {
      map['remembered_position_ms'] = Variable<int>(rememberedPositionMs.value);
    }
    if (attachedLrcPath.present) {
      map['attached_lrc_path'] = Variable<String>(attachedLrcPath.value);
    }
    if (lyricOffsetMs.present) {
      map['lyric_offset_ms'] = Variable<int>(lyricOffsetMs.value);
    }
    if (customArtPath.present) {
      map['custom_art_path'] = Variable<String>(customArtPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackUserMetaCompanion(')
          ..write('stableKey: $stableKey, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rememberedPositionMs: $rememberedPositionMs, ')
          ..write('attachedLrcPath: $attachedLrcPath, ')
          ..write('lyricOffsetMs: $lyricOffsetMs, ')
          ..write('customArtPath: $customArtPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smartKindMeta = const VerificationMeta(
    'smartKind',
  );
  @override
  late final GeneratedColumn<String> smartKind = GeneratedColumn<String>(
    'smart_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customCoverPathMeta = const VerificationMeta(
    'customCoverPath',
  );
  @override
  late final GeneratedColumn<String> customCoverPath = GeneratedColumn<String>(
    'custom_cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    smartKind,
    customCoverPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('smart_kind')) {
      context.handle(
        _smartKindMeta,
        smartKind.isAcceptableOrUnknown(data['smart_kind']!, _smartKindMeta),
      );
    }
    if (data.containsKey('custom_cover_path')) {
      context.handle(
        _customCoverPathMeta,
        customCoverPath.isAcceptableOrUnknown(
          data['custom_cover_path']!,
          _customCoverPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      smartKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smart_kind'],
      ),
      customCoverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_cover_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final String? smartKind;
  final String? customCoverPath;
  final int createdAt;
  final int updatedAt;
  const Playlist({
    required this.id,
    required this.name,
    this.smartKind,
    this.customCoverPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || smartKind != null) {
      map['smart_kind'] = Variable<String>(smartKind);
    }
    if (!nullToAbsent || customCoverPath != null) {
      map['custom_cover_path'] = Variable<String>(customCoverPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      smartKind: smartKind == null && nullToAbsent
          ? const Value.absent()
          : Value(smartKind),
      customCoverPath: customCoverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customCoverPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      smartKind: serializer.fromJson<String?>(json['smartKind']),
      customCoverPath: serializer.fromJson<String?>(json['customCoverPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'smartKind': serializer.toJson<String?>(smartKind),
      'customCoverPath': serializer.toJson<String?>(customCoverPath),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Playlist copyWith({
    int? id,
    String? name,
    Value<String?> smartKind = const Value.absent(),
    Value<String?> customCoverPath = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    smartKind: smartKind.present ? smartKind.value : this.smartKind,
    customCoverPath: customCoverPath.present
        ? customCoverPath.value
        : this.customCoverPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      smartKind: data.smartKind.present ? data.smartKind.value : this.smartKind,
      customCoverPath: data.customCoverPath.present
          ? data.customCoverPath.value
          : this.customCoverPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('smartKind: $smartKind, ')
          ..write('customCoverPath: $customCoverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, smartKind, customCoverPath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.smartKind == this.smartKind &&
          other.customCoverPath == this.customCoverPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> smartKind;
  final Value<String?> customCoverPath;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.smartKind = const Value.absent(),
    this.customCoverPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.smartKind = const Value.absent(),
    this.customCoverPath = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? smartKind,
    Expression<String>? customCoverPath,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (smartKind != null) 'smart_kind': smartKind,
      if (customCoverPath != null) 'custom_cover_path': customCoverPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? smartKind,
    Value<String?>? customCoverPath,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      smartKind: smartKind ?? this.smartKind,
      customCoverPath: customCoverPath ?? this.customCoverPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (smartKind.present) {
      map['smart_kind'] = Variable<String>(smartKind.value);
    }
    if (customCoverPath.present) {
      map['custom_cover_path'] = Variable<String>(customCoverPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('smartKind: $smartKind, ')
          ..write('customCoverPath: $customCoverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTable extends PlaylistEntries
    with TableInfo<$PlaylistEntriesTable, PlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackStableKeyMeta = const VerificationMeta(
    'trackStableKey',
  );
  @override
  late final GeneratedColumn<String> trackStableKey = GeneratedColumn<String>(
    'track_stable_key',
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
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    trackStableKey,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_stable_key')) {
      context.handle(
        _trackStableKeyMeta,
        trackStableKey.isAcceptableOrUnknown(
          data['track_stable_key']!,
          _trackStableKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackStableKeyMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackStableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_stable_key'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $PlaylistEntriesTable createAlias(String alias) {
    return $PlaylistEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistEntry extends DataClass implements Insertable<PlaylistEntry> {
  final int id;
  final int playlistId;
  final String trackStableKey;
  final int position;
  final int addedAt;
  const PlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.trackStableKey,
    required this.position,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['track_stable_key'] = Variable<String>(trackStableKey);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  PlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      trackStableKey: Value(trackStableKey),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntry(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      trackStableKey: serializer.fromJson<String>(json['trackStableKey']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'trackStableKey': serializer.toJson<String>(trackStableKey),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  PlaylistEntry copyWith({
    int? id,
    int? playlistId,
    String? trackStableKey,
    int? position,
    int? addedAt,
  }) => PlaylistEntry(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    trackStableKey: trackStableKey ?? this.trackStableKey,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistEntry copyWithCompanion(PlaylistEntriesCompanion data) {
    return PlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackStableKey: data.trackStableKey.present
          ? data.trackStableKey.value
          : this.trackStableKey,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntry(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackStableKey: $trackStableKey, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, playlistId, trackStableKey, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntry &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.trackStableKey == this.trackStableKey &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class PlaylistEntriesCompanion extends UpdateCompanion<PlaylistEntry> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<String> trackStableKey;
  final Value<int> position;
  final Value<int> addedAt;
  const PlaylistEntriesCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.trackStableKey = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  PlaylistEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    required String trackStableKey,
    required int position,
    required int addedAt,
  }) : playlistId = Value(playlistId),
       trackStableKey = Value(trackStableKey),
       position = Value(position),
       addedAt = Value(addedAt);
  static Insertable<PlaylistEntry> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<String>? trackStableKey,
    Expression<int>? position,
    Expression<int>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackStableKey != null) 'track_stable_key': trackStableKey,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  PlaylistEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<String>? trackStableKey,
    Value<int>? position,
    Value<int>? addedAt,
  }) {
    return PlaylistEntriesCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackStableKey: trackStableKey ?? this.trackStableKey,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (trackStableKey.present) {
      map['track_stable_key'] = Variable<String>(trackStableKey.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackStableKey: $trackStableKey, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryEventsTable extends PlayHistoryEvents
    with TableInfo<$PlayHistoryEventsTable, PlayHistoryEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _trackStableKeyMeta = const VerificationMeta(
    'trackStableKey',
  );
  @override
  late final GeneratedColumn<String> trackStableKey = GeneratedColumn<String>(
    'track_stable_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackTitleMeta = const VerificationMeta(
    'trackTitle',
  );
  @override
  late final GeneratedColumn<String> trackTitle = GeneratedColumn<String>(
    'track_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumNameMeta = const VerificationMeta(
    'albumName',
  );
  @override
  late final GeneratedColumn<String> albumName = GeneratedColumn<String>(
    'album_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<int> playedAt = GeneratedColumn<int>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackStableKey,
    trackTitle,
    artistName,
    albumName,
    playedAt,
    listenedMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayHistoryEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_stable_key')) {
      context.handle(
        _trackStableKeyMeta,
        trackStableKey.isAcceptableOrUnknown(
          data['track_stable_key']!,
          _trackStableKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackStableKeyMeta);
    }
    if (data.containsKey('track_title')) {
      context.handle(
        _trackTitleMeta,
        trackTitle.isAcceptableOrUnknown(data['track_title']!, _trackTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_trackTitleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('album_name')) {
      context.handle(
        _albumNameMeta,
        albumName.isAcceptableOrUnknown(data['album_name']!, _albumNameMeta),
      );
    } else if (isInserting) {
      context.missing(_albumNameMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_listenedMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayHistoryEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayHistoryEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackStableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_stable_key'],
      )!,
      trackTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_title'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      )!,
      albumName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_name'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}played_at'],
      )!,
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      )!,
    );
  }

  @override
  $PlayHistoryEventsTable createAlias(String alias) {
    return $PlayHistoryEventsTable(attachedDatabase, alias);
  }
}

class PlayHistoryEvent extends DataClass
    implements Insertable<PlayHistoryEvent> {
  final int id;
  final String trackStableKey;
  final String trackTitle;
  final String artistName;
  final String albumName;
  final int playedAt;
  final int listenedMs;
  const PlayHistoryEvent({
    required this.id,
    required this.trackStableKey,
    required this.trackTitle,
    required this.artistName,
    required this.albumName,
    required this.playedAt,
    required this.listenedMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_stable_key'] = Variable<String>(trackStableKey);
    map['track_title'] = Variable<String>(trackTitle);
    map['artist_name'] = Variable<String>(artistName);
    map['album_name'] = Variable<String>(albumName);
    map['played_at'] = Variable<int>(playedAt);
    map['listened_ms'] = Variable<int>(listenedMs);
    return map;
  }

  PlayHistoryEventsCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryEventsCompanion(
      id: Value(id),
      trackStableKey: Value(trackStableKey),
      trackTitle: Value(trackTitle),
      artistName: Value(artistName),
      albumName: Value(albumName),
      playedAt: Value(playedAt),
      listenedMs: Value(listenedMs),
    );
  }

  factory PlayHistoryEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayHistoryEvent(
      id: serializer.fromJson<int>(json['id']),
      trackStableKey: serializer.fromJson<String>(json['trackStableKey']),
      trackTitle: serializer.fromJson<String>(json['trackTitle']),
      artistName: serializer.fromJson<String>(json['artistName']),
      albumName: serializer.fromJson<String>(json['albumName']),
      playedAt: serializer.fromJson<int>(json['playedAt']),
      listenedMs: serializer.fromJson<int>(json['listenedMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackStableKey': serializer.toJson<String>(trackStableKey),
      'trackTitle': serializer.toJson<String>(trackTitle),
      'artistName': serializer.toJson<String>(artistName),
      'albumName': serializer.toJson<String>(albumName),
      'playedAt': serializer.toJson<int>(playedAt),
      'listenedMs': serializer.toJson<int>(listenedMs),
    };
  }

  PlayHistoryEvent copyWith({
    int? id,
    String? trackStableKey,
    String? trackTitle,
    String? artistName,
    String? albumName,
    int? playedAt,
    int? listenedMs,
  }) => PlayHistoryEvent(
    id: id ?? this.id,
    trackStableKey: trackStableKey ?? this.trackStableKey,
    trackTitle: trackTitle ?? this.trackTitle,
    artistName: artistName ?? this.artistName,
    albumName: albumName ?? this.albumName,
    playedAt: playedAt ?? this.playedAt,
    listenedMs: listenedMs ?? this.listenedMs,
  );
  PlayHistoryEvent copyWithCompanion(PlayHistoryEventsCompanion data) {
    return PlayHistoryEvent(
      id: data.id.present ? data.id.value : this.id,
      trackStableKey: data.trackStableKey.present
          ? data.trackStableKey.value
          : this.trackStableKey,
      trackTitle: data.trackTitle.present
          ? data.trackTitle.value
          : this.trackTitle,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      albumName: data.albumName.present ? data.albumName.value : this.albumName,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryEvent(')
          ..write('id: $id, ')
          ..write('trackStableKey: $trackStableKey, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('albumName: $albumName, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenedMs: $listenedMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackStableKey,
    trackTitle,
    artistName,
    albumName,
    playedAt,
    listenedMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayHistoryEvent &&
          other.id == this.id &&
          other.trackStableKey == this.trackStableKey &&
          other.trackTitle == this.trackTitle &&
          other.artistName == this.artistName &&
          other.albumName == this.albumName &&
          other.playedAt == this.playedAt &&
          other.listenedMs == this.listenedMs);
}

class PlayHistoryEventsCompanion extends UpdateCompanion<PlayHistoryEvent> {
  final Value<int> id;
  final Value<String> trackStableKey;
  final Value<String> trackTitle;
  final Value<String> artistName;
  final Value<String> albumName;
  final Value<int> playedAt;
  final Value<int> listenedMs;
  const PlayHistoryEventsCompanion({
    this.id = const Value.absent(),
    this.trackStableKey = const Value.absent(),
    this.trackTitle = const Value.absent(),
    this.artistName = const Value.absent(),
    this.albumName = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.listenedMs = const Value.absent(),
  });
  PlayHistoryEventsCompanion.insert({
    this.id = const Value.absent(),
    required String trackStableKey,
    required String trackTitle,
    required String artistName,
    required String albumName,
    required int playedAt,
    required int listenedMs,
  }) : trackStableKey = Value(trackStableKey),
       trackTitle = Value(trackTitle),
       artistName = Value(artistName),
       albumName = Value(albumName),
       playedAt = Value(playedAt),
       listenedMs = Value(listenedMs);
  static Insertable<PlayHistoryEvent> custom({
    Expression<int>? id,
    Expression<String>? trackStableKey,
    Expression<String>? trackTitle,
    Expression<String>? artistName,
    Expression<String>? albumName,
    Expression<int>? playedAt,
    Expression<int>? listenedMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackStableKey != null) 'track_stable_key': trackStableKey,
      if (trackTitle != null) 'track_title': trackTitle,
      if (artistName != null) 'artist_name': artistName,
      if (albumName != null) 'album_name': albumName,
      if (playedAt != null) 'played_at': playedAt,
      if (listenedMs != null) 'listened_ms': listenedMs,
    });
  }

  PlayHistoryEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? trackStableKey,
    Value<String>? trackTitle,
    Value<String>? artistName,
    Value<String>? albumName,
    Value<int>? playedAt,
    Value<int>? listenedMs,
  }) {
    return PlayHistoryEventsCompanion(
      id: id ?? this.id,
      trackStableKey: trackStableKey ?? this.trackStableKey,
      trackTitle: trackTitle ?? this.trackTitle,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      playedAt: playedAt ?? this.playedAt,
      listenedMs: listenedMs ?? this.listenedMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackStableKey.present) {
      map['track_stable_key'] = Variable<String>(trackStableKey.value);
    }
    if (trackTitle.present) {
      map['track_title'] = Variable<String>(trackTitle.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (albumName.present) {
      map['album_name'] = Variable<String>(albumName.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<int>(playedAt.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('trackStableKey: $trackStableKey, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('albumName: $albumName, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenedMs: $listenedMs')
          ..write(')'))
        .toString();
  }
}

class $QueueSnapshotsTable extends QueueSnapshots
    with TableInfo<$QueueSnapshotsTable, QueueSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemsJson,
    currentIndex,
    positionMs,
    shuffleEnabled,
    repeatMode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QueueSnapshotsTable createAlias(String alias) {
    return $QueueSnapshotsTable(attachedDatabase, alias);
  }
}

class QueueSnapshot extends DataClass implements Insertable<QueueSnapshot> {
  final int id;
  final String itemsJson;
  final int currentIndex;
  final int positionMs;
  final bool shuffleEnabled;
  final String repeatMode;
  final int updatedAt;
  const QueueSnapshot({
    required this.id,
    required this.itemsJson,
    required this.currentIndex,
    required this.positionMs,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['items_json'] = Variable<String>(itemsJson);
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  QueueSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return QueueSnapshotsCompanion(
      id: Value(id),
      itemsJson: Value(itemsJson),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      shuffleEnabled: Value(shuffleEnabled),
      repeatMode: Value(repeatMode),
      updatedAt: Value(updatedAt),
    );
  }

  factory QueueSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueSnapshot(
      id: serializer.fromJson<int>(json['id']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  QueueSnapshot copyWith({
    int? id,
    String? itemsJson,
    int? currentIndex,
    int? positionMs,
    bool? shuffleEnabled,
    String? repeatMode,
    int? updatedAt,
  }) => QueueSnapshot(
    id: id ?? this.id,
    itemsJson: itemsJson ?? this.itemsJson,
    currentIndex: currentIndex ?? this.currentIndex,
    positionMs: positionMs ?? this.positionMs,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    repeatMode: repeatMode ?? this.repeatMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QueueSnapshot copyWithCompanion(QueueSnapshotsCompanion data) {
    return QueueSnapshot(
      id: data.id.present ? data.id.value : this.id,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueSnapshot(')
          ..write('id: $id, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemsJson,
    currentIndex,
    positionMs,
    shuffleEnabled,
    repeatMode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueSnapshot &&
          other.id == this.id &&
          other.itemsJson == this.itemsJson &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.repeatMode == this.repeatMode &&
          other.updatedAt == this.updatedAt);
}

class QueueSnapshotsCompanion extends UpdateCompanion<QueueSnapshot> {
  final Value<int> id;
  final Value<String> itemsJson;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<bool> shuffleEnabled;
  final Value<String> repeatMode;
  final Value<int> updatedAt;
  const QueueSnapshotsCompanion({
    this.id = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QueueSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String itemsJson,
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    required int updatedAt,
  }) : itemsJson = Value(itemsJson),
       updatedAt = Value(updatedAt);
  static Insertable<QueueSnapshot> custom({
    Expression<int>? id,
    Expression<String>? itemsJson,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<bool>? shuffleEnabled,
    Expression<String>? repeatMode,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemsJson != null) 'items_json': itemsJson,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QueueSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? itemsJson,
    Value<int>? currentIndex,
    Value<int>? positionMs,
    Value<bool>? shuffleEnabled,
    Value<String>? repeatMode,
    Value<int>? updatedAt,
  }) {
    return QueueSnapshotsCompanion(
      id: id ?? this.id,
      itemsJson: itemsJson ?? this.itemsJson,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EqualizerPresetsTable extends EqualizerPresets
    with TableInfo<$EqualizerPresetsTable, EqualizerPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EqualizerPresetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _bandGainsJsonMeta = const VerificationMeta(
    'bandGainsJson',
  );
  @override
  late final GeneratedColumn<String> bandGainsJson = GeneratedColumn<String>(
    'band_gains_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bassBoostStrengthMeta = const VerificationMeta(
    'bassBoostStrength',
  );
  @override
  late final GeneratedColumn<int> bassBoostStrength = GeneratedColumn<int>(
    'bass_boost_strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _virtualizerStrengthMeta =
      const VerificationMeta('virtualizerStrength');
  @override
  late final GeneratedColumn<int> virtualizerStrength = GeneratedColumn<int>(
    'virtualizer_strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loudnessGainMbMeta = const VerificationMeta(
    'loudnessGainMb',
  );
  @override
  late final GeneratedColumn<int> loudnessGainMb = GeneratedColumn<int>(
    'loudness_gain_mb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isCustom,
    bandGainsJson,
    bassBoostStrength,
    virtualizerStrength,
    loudnessGainMb,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equalizer_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<EqualizerPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('band_gains_json')) {
      context.handle(
        _bandGainsJsonMeta,
        bandGainsJson.isAcceptableOrUnknown(
          data['band_gains_json']!,
          _bandGainsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bandGainsJsonMeta);
    }
    if (data.containsKey('bass_boost_strength')) {
      context.handle(
        _bassBoostStrengthMeta,
        bassBoostStrength.isAcceptableOrUnknown(
          data['bass_boost_strength']!,
          _bassBoostStrengthMeta,
        ),
      );
    }
    if (data.containsKey('virtualizer_strength')) {
      context.handle(
        _virtualizerStrengthMeta,
        virtualizerStrength.isAcceptableOrUnknown(
          data['virtualizer_strength']!,
          _virtualizerStrengthMeta,
        ),
      );
    }
    if (data.containsKey('loudness_gain_mb')) {
      context.handle(
        _loudnessGainMbMeta,
        loudnessGainMb.isAcceptableOrUnknown(
          data['loudness_gain_mb']!,
          _loudnessGainMbMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EqualizerPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EqualizerPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      bandGainsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band_gains_json'],
      )!,
      bassBoostStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bass_boost_strength'],
      )!,
      virtualizerStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}virtualizer_strength'],
      )!,
      loudnessGainMb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loudness_gain_mb'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EqualizerPresetsTable createAlias(String alias) {
    return $EqualizerPresetsTable(attachedDatabase, alias);
  }
}

class EqualizerPreset extends DataClass implements Insertable<EqualizerPreset> {
  final int id;
  final String name;
  final bool isCustom;
  final String bandGainsJson;
  final int bassBoostStrength;
  final int virtualizerStrength;
  final int loudnessGainMb;
  final int updatedAt;
  const EqualizerPreset({
    required this.id,
    required this.name,
    required this.isCustom,
    required this.bandGainsJson,
    required this.bassBoostStrength,
    required this.virtualizerStrength,
    required this.loudnessGainMb,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_custom'] = Variable<bool>(isCustom);
    map['band_gains_json'] = Variable<String>(bandGainsJson);
    map['bass_boost_strength'] = Variable<int>(bassBoostStrength);
    map['virtualizer_strength'] = Variable<int>(virtualizerStrength);
    map['loudness_gain_mb'] = Variable<int>(loudnessGainMb);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  EqualizerPresetsCompanion toCompanion(bool nullToAbsent) {
    return EqualizerPresetsCompanion(
      id: Value(id),
      name: Value(name),
      isCustom: Value(isCustom),
      bandGainsJson: Value(bandGainsJson),
      bassBoostStrength: Value(bassBoostStrength),
      virtualizerStrength: Value(virtualizerStrength),
      loudnessGainMb: Value(loudnessGainMb),
      updatedAt: Value(updatedAt),
    );
  }

  factory EqualizerPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EqualizerPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      bandGainsJson: serializer.fromJson<String>(json['bandGainsJson']),
      bassBoostStrength: serializer.fromJson<int>(json['bassBoostStrength']),
      virtualizerStrength: serializer.fromJson<int>(
        json['virtualizerStrength'],
      ),
      loudnessGainMb: serializer.fromJson<int>(json['loudnessGainMb']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isCustom': serializer.toJson<bool>(isCustom),
      'bandGainsJson': serializer.toJson<String>(bandGainsJson),
      'bassBoostStrength': serializer.toJson<int>(bassBoostStrength),
      'virtualizerStrength': serializer.toJson<int>(virtualizerStrength),
      'loudnessGainMb': serializer.toJson<int>(loudnessGainMb),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  EqualizerPreset copyWith({
    int? id,
    String? name,
    bool? isCustom,
    String? bandGainsJson,
    int? bassBoostStrength,
    int? virtualizerStrength,
    int? loudnessGainMb,
    int? updatedAt,
  }) => EqualizerPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    isCustom: isCustom ?? this.isCustom,
    bandGainsJson: bandGainsJson ?? this.bandGainsJson,
    bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
    virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
    loudnessGainMb: loudnessGainMb ?? this.loudnessGainMb,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EqualizerPreset copyWithCompanion(EqualizerPresetsCompanion data) {
    return EqualizerPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      bandGainsJson: data.bandGainsJson.present
          ? data.bandGainsJson.value
          : this.bandGainsJson,
      bassBoostStrength: data.bassBoostStrength.present
          ? data.bassBoostStrength.value
          : this.bassBoostStrength,
      virtualizerStrength: data.virtualizerStrength.present
          ? data.virtualizerStrength.value
          : this.virtualizerStrength,
      loudnessGainMb: data.loudnessGainMb.present
          ? data.loudnessGainMb.value
          : this.loudnessGainMb,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EqualizerPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('bandGainsJson: $bandGainsJson, ')
          ..write('bassBoostStrength: $bassBoostStrength, ')
          ..write('virtualizerStrength: $virtualizerStrength, ')
          ..write('loudnessGainMb: $loudnessGainMb, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isCustom,
    bandGainsJson,
    bassBoostStrength,
    virtualizerStrength,
    loudnessGainMb,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EqualizerPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCustom == this.isCustom &&
          other.bandGainsJson == this.bandGainsJson &&
          other.bassBoostStrength == this.bassBoostStrength &&
          other.virtualizerStrength == this.virtualizerStrength &&
          other.loudnessGainMb == this.loudnessGainMb &&
          other.updatedAt == this.updatedAt);
}

class EqualizerPresetsCompanion extends UpdateCompanion<EqualizerPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isCustom;
  final Value<String> bandGainsJson;
  final Value<int> bassBoostStrength;
  final Value<int> virtualizerStrength;
  final Value<int> loudnessGainMb;
  final Value<int> updatedAt;
  const EqualizerPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.bandGainsJson = const Value.absent(),
    this.bassBoostStrength = const Value.absent(),
    this.virtualizerStrength = const Value.absent(),
    this.loudnessGainMb = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EqualizerPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isCustom = const Value.absent(),
    required String bandGainsJson,
    this.bassBoostStrength = const Value.absent(),
    this.virtualizerStrength = const Value.absent(),
    this.loudnessGainMb = const Value.absent(),
    required int updatedAt,
  }) : name = Value(name),
       bandGainsJson = Value(bandGainsJson),
       updatedAt = Value(updatedAt);
  static Insertable<EqualizerPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isCustom,
    Expression<String>? bandGainsJson,
    Expression<int>? bassBoostStrength,
    Expression<int>? virtualizerStrength,
    Expression<int>? loudnessGainMb,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCustom != null) 'is_custom': isCustom,
      if (bandGainsJson != null) 'band_gains_json': bandGainsJson,
      if (bassBoostStrength != null) 'bass_boost_strength': bassBoostStrength,
      if (virtualizerStrength != null)
        'virtualizer_strength': virtualizerStrength,
      if (loudnessGainMb != null) 'loudness_gain_mb': loudnessGainMb,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EqualizerPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isCustom,
    Value<String>? bandGainsJson,
    Value<int>? bassBoostStrength,
    Value<int>? virtualizerStrength,
    Value<int>? loudnessGainMb,
    Value<int>? updatedAt,
  }) {
    return EqualizerPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      bandGainsJson: bandGainsJson ?? this.bandGainsJson,
      bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
      virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
      loudnessGainMb: loudnessGainMb ?? this.loudnessGainMb,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (bandGainsJson.present) {
      map['band_gains_json'] = Variable<String>(bandGainsJson.value);
    }
    if (bassBoostStrength.present) {
      map['bass_boost_strength'] = Variable<int>(bassBoostStrength.value);
    }
    if (virtualizerStrength.present) {
      map['virtualizer_strength'] = Variable<int>(virtualizerStrength.value);
    }
    if (loudnessGainMb.present) {
      map['loudness_gain_mb'] = Variable<int>(loudnessGainMb.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EqualizerPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('bandGainsJson: $bandGainsJson, ')
          ..write('bassBoostStrength: $bassBoostStrength, ')
          ..write('virtualizerStrength: $virtualizerStrength, ')
          ..write('loudnessGainMb: $loudnessGainMb, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedQueryMeta = const VerificationMeta(
    'normalizedQuery',
  );
  @override
  late final GeneratedColumn<String> normalizedQuery = GeneratedColumn<String>(
    'normalized_query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<int> searchedAt = GeneratedColumn<int>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [query, normalizedQuery, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('normalized_query')) {
      context.handle(
        _normalizedQueryMeta,
        normalizedQuery.isAcceptableOrUnknown(
          data['normalized_query']!,
          _normalizedQueryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedQueryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      normalizedQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final String query;
  final String normalizedQuery;
  final int searchedAt;
  const RecentSearche({
    required this.query,
    required this.normalizedQuery,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['normalized_query'] = Variable<String>(normalizedQuery);
    map['searched_at'] = Variable<int>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      query: Value(query),
      normalizedQuery: Value(normalizedQuery),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      query: serializer.fromJson<String>(json['query']),
      normalizedQuery: serializer.fromJson<String>(json['normalizedQuery']),
      searchedAt: serializer.fromJson<int>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'normalizedQuery': serializer.toJson<String>(normalizedQuery),
      'searchedAt': serializer.toJson<int>(searchedAt),
    };
  }

  RecentSearche copyWith({
    String? query,
    String? normalizedQuery,
    int? searchedAt,
  }) => RecentSearche(
    query: query ?? this.query,
    normalizedQuery: normalizedQuery ?? this.normalizedQuery,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      query: data.query.present ? data.query.value : this.query,
      normalizedQuery: data.normalizedQuery.present
          ? data.normalizedQuery.value
          : this.normalizedQuery,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('query: $query, ')
          ..write('normalizedQuery: $normalizedQuery, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, normalizedQuery, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.query == this.query &&
          other.normalizedQuery == this.normalizedQuery &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<String> query;
  final Value<String> normalizedQuery;
  final Value<int> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.query = const Value.absent(),
    this.normalizedQuery = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String query,
    required String normalizedQuery,
    required int searchedAt,
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       normalizedQuery = Value(normalizedQuery),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearche> custom({
    Expression<String>? query,
    Expression<String>? normalizedQuery,
    Expression<int>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (normalizedQuery != null) 'normalized_query': normalizedQuery,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<String>? query,
    Value<String>? normalizedQuery,
    Value<int>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      query: query ?? this.query,
      normalizedQuery: normalizedQuery ?? this.normalizedQuery,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (normalizedQuery.present) {
      map['normalized_query'] = Variable<String>(normalizedQuery.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<int>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('query: $query, ')
          ..write('normalizedQuery: $normalizedQuery, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$WetarDatabase extends GeneratedDatabase {
  _$WetarDatabase(QueryExecutor e) : super(e);
  $WetarDatabaseManager get managers => $WetarDatabaseManager(this);
  late final $SelectedFoldersTable selectedFolders = $SelectedFoldersTable(
    this,
  );
  late final $TracksTable tracks = $TracksTable(this);
  late final $AlbumPalettesTable albumPalettes = $AlbumPalettesTable(this);
  late final $TrackUserMetaTable trackUserMeta = $TrackUserMetaTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistEntriesTable playlistEntries = $PlaylistEntriesTable(
    this,
  );
  late final $PlayHistoryEventsTable playHistoryEvents =
      $PlayHistoryEventsTable(this);
  late final $QueueSnapshotsTable queueSnapshots = $QueueSnapshotsTable(this);
  late final $EqualizerPresetsTable equalizerPresets = $EqualizerPresetsTable(
    this,
  );
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    selectedFolders,
    tracks,
    albumPalettes,
    trackUserMeta,
    playlists,
    playlistEntries,
    playHistoryEvents,
    queueSnapshots,
    equalizerPresets,
    recentSearches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'selected_folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SelectedFoldersTableCreateCompanionBuilder =
    SelectedFoldersCompanion Function({
      Value<int> id,
      required String rootPath,
      Value<String> sourceKind,
      Value<String?> bookmarkData,
      required String displayName,
      Value<String> volumeLabel,
      Value<bool> includeSubfolders,
      Value<String> excludedSubfoldersJson,
      Value<bool> isAvailable,
      required int addedAt,
      Value<int> lastScannedAt,
    });
typedef $$SelectedFoldersTableUpdateCompanionBuilder =
    SelectedFoldersCompanion Function({
      Value<int> id,
      Value<String> rootPath,
      Value<String> sourceKind,
      Value<String?> bookmarkData,
      Value<String> displayName,
      Value<String> volumeLabel,
      Value<bool> includeSubfolders,
      Value<String> excludedSubfoldersJson,
      Value<bool> isAvailable,
      Value<int> addedAt,
      Value<int> lastScannedAt,
    });

final class $$SelectedFoldersTableReferences
    extends
        BaseReferences<_$WetarDatabase, $SelectedFoldersTable, SelectedFolder> {
  $$SelectedFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$WetarDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'selected_folders__id__tracks__folder_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SelectedFoldersTableFilterComposer
    extends Composer<_$WetarDatabase, $SelectedFoldersTable> {
  $$SelectedFoldersTableFilterComposer({
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

  ColumnFilters<String> get rootPath => $composableBuilder(
    column: $table.rootPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmarkData => $composableBuilder(
    column: $table.bookmarkData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeSubfolders => $composableBuilder(
    column: $table.includeSubfolders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excludedSubfoldersJson => $composableBuilder(
    column: $table.excludedSubfoldersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SelectedFoldersTableOrderingComposer
    extends Composer<_$WetarDatabase, $SelectedFoldersTable> {
  $$SelectedFoldersTableOrderingComposer({
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

  ColumnOrderings<String> get rootPath => $composableBuilder(
    column: $table.rootPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmarkData => $composableBuilder(
    column: $table.bookmarkData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeSubfolders => $composableBuilder(
    column: $table.includeSubfolders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excludedSubfoldersJson => $composableBuilder(
    column: $table.excludedSubfoldersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SelectedFoldersTableAnnotationComposer
    extends Composer<_$WetarDatabase, $SelectedFoldersTable> {
  $$SelectedFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rootPath =>
      $composableBuilder(column: $table.rootPath, builder: (column) => column);

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookmarkData => $composableBuilder(
    column: $table.bookmarkData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeSubfolders => $composableBuilder(
    column: $table.includeSubfolders,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excludedSubfoldersJson => $composableBuilder(
    column: $table.excludedSubfoldersJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => column,
  );

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SelectedFoldersTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $SelectedFoldersTable,
          SelectedFolder,
          $$SelectedFoldersTableFilterComposer,
          $$SelectedFoldersTableOrderingComposer,
          $$SelectedFoldersTableAnnotationComposer,
          $$SelectedFoldersTableCreateCompanionBuilder,
          $$SelectedFoldersTableUpdateCompanionBuilder,
          (SelectedFolder, $$SelectedFoldersTableReferences),
          SelectedFolder,
          PrefetchHooks Function({bool tracksRefs})
        > {
  $$SelectedFoldersTableTableManager(
    _$WetarDatabase db,
    $SelectedFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelectedFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SelectedFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SelectedFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rootPath = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String?> bookmarkData = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> volumeLabel = const Value.absent(),
                Value<bool> includeSubfolders = const Value.absent(),
                Value<String> excludedSubfoldersJson = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<int> lastScannedAt = const Value.absent(),
              }) => SelectedFoldersCompanion(
                id: id,
                rootPath: rootPath,
                sourceKind: sourceKind,
                bookmarkData: bookmarkData,
                displayName: displayName,
                volumeLabel: volumeLabel,
                includeSubfolders: includeSubfolders,
                excludedSubfoldersJson: excludedSubfoldersJson,
                isAvailable: isAvailable,
                addedAt: addedAt,
                lastScannedAt: lastScannedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rootPath,
                Value<String> sourceKind = const Value.absent(),
                Value<String?> bookmarkData = const Value.absent(),
                required String displayName,
                Value<String> volumeLabel = const Value.absent(),
                Value<bool> includeSubfolders = const Value.absent(),
                Value<String> excludedSubfoldersJson = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                required int addedAt,
                Value<int> lastScannedAt = const Value.absent(),
              }) => SelectedFoldersCompanion.insert(
                id: id,
                rootPath: rootPath,
                sourceKind: sourceKind,
                bookmarkData: bookmarkData,
                displayName: displayName,
                volumeLabel: volumeLabel,
                includeSubfolders: includeSubfolders,
                excludedSubfoldersJson: excludedSubfoldersJson,
                isAvailable: isAvailable,
                addedAt: addedAt,
                lastScannedAt: lastScannedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SelectedFoldersTable, SelectedFolder>(table),
                  $$SelectedFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksRefs) db.tracks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedDataByColumns<
                      SelectedFolder,
                      $SelectedFoldersTable,
                      Track,
                      $TracksTable
                    >(
                      currentTable: table,
                      referencedTable: $$SelectedFoldersTableReferences
                          ._tracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SelectedFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).tracksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'folder_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SelectedFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $SelectedFoldersTable,
      SelectedFolder,
      $$SelectedFoldersTableFilterComposer,
      $$SelectedFoldersTableOrderingComposer,
      $$SelectedFoldersTableAnnotationComposer,
      $$SelectedFoldersTableCreateCompanionBuilder,
      $$SelectedFoldersTableUpdateCompanionBuilder,
      (SelectedFolder, $$SelectedFoldersTableReferences),
      SelectedFolder,
      PrefetchHooks Function({bool tracksRefs})
    >;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  required String stableKey,
  required int folderId,
  required String uri,
  required String filePath,
  required String folderPath,
  required String title,
  required String titleNormalized,
  Value<String> artist,
  Value<String> artistNormalized,
  Value<String> album,
  Value<String> albumNormalized,
  Value<String> albumArtist,
  Value<String> genre,
  Value<int> year,
  Value<int> trackNumber,
  Value<int> discNumber,
  Value<int> durationMs,
  Value<int> bitrateKbps,
  Value<int> sampleRateHz,
  Value<int> channels,
  Value<int> sizeBytes,
  Value<String> mimeType,
  Value<int> dateModifiedSec,
  Value<int> dateAddedSec,
  Value<String?> artworkUri,
  Value<String?> embeddedLyrics,
  Value<double?> replayGainTrackDb,
  Value<double?> replayGainAlbumDb,
  Value<bool> isCloudPending,
  Value<bool> isCorruptOrMissing,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  Value<String> stableKey,
  Value<int> folderId,
  Value<String> uri,
  Value<String> filePath,
  Value<String> folderPath,
  Value<String> title,
  Value<String> titleNormalized,
  Value<String> artist,
  Value<String> artistNormalized,
  Value<String> album,
  Value<String> albumNormalized,
  Value<String> albumArtist,
  Value<String> genre,
  Value<int> year,
  Value<int> trackNumber,
  Value<int> discNumber,
  Value<int> durationMs,
  Value<int> bitrateKbps,
  Value<int> sampleRateHz,
  Value<int> channels,
  Value<int> sizeBytes,
  Value<String> mimeType,
  Value<int> dateModifiedSec,
  Value<int> dateAddedSec,
  Value<String?> artworkUri,
  Value<String?> embeddedLyrics,
  Value<double?> replayGainTrackDb,
  Value<double?> replayGainAlbumDb,
  Value<bool> isCloudPending,
  Value<bool> isCorruptOrMissing,
});

final class $$TracksTableReferences
    extends BaseReferences<_$WetarDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SelectedFoldersTable _folderIdTable(_$WetarDatabase db) =>
      db.selectedFolders.createAlias('tracks__folder_id__selected_folders__id');

  $$SelectedFoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$SelectedFoldersTableTableManager(
      $_db,
      $_db.selectedFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$WetarDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
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

  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNormalized => $composableBuilder(
    column: $table.titleNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistNormalized => $composableBuilder(
    column: $table.artistNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumNormalized => $composableBuilder(
    column: $table.albumNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channels => $composableBuilder(
    column: $table.channels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateModifiedSec => $composableBuilder(
    column: $table.dateModifiedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAddedSec => $composableBuilder(
    column: $table.dateAddedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddedLyrics => $composableBuilder(
    column: $table.embeddedLyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get replayGainTrackDb => $composableBuilder(
    column: $table.replayGainTrackDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get replayGainAlbumDb => $composableBuilder(
    column: $table.replayGainAlbumDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCloudPending => $composableBuilder(
    column: $table.isCloudPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorruptOrMissing => $composableBuilder(
    column: $table.isCorruptOrMissing,
    builder: (column) => ColumnFilters(column),
  );

  $$SelectedFoldersTableFilterComposer get folderId {
    final $$SelectedFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.selectedFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedFoldersTableFilterComposer(
            $db: $db,
            $table: $db.selectedFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$WetarDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
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

  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNormalized => $composableBuilder(
    column: $table.titleNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistNormalized => $composableBuilder(
    column: $table.artistNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumNormalized => $composableBuilder(
    column: $table.albumNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channels => $composableBuilder(
    column: $table.channels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateModifiedSec => $composableBuilder(
    column: $table.dateModifiedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAddedSec => $composableBuilder(
    column: $table.dateAddedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddedLyrics => $composableBuilder(
    column: $table.embeddedLyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get replayGainTrackDb => $composableBuilder(
    column: $table.replayGainTrackDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get replayGainAlbumDb => $composableBuilder(
    column: $table.replayGainAlbumDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCloudPending => $composableBuilder(
    column: $table.isCloudPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorruptOrMissing => $composableBuilder(
    column: $table.isCorruptOrMissing,
    builder: (column) => ColumnOrderings(column),
  );

  $$SelectedFoldersTableOrderingComposer get folderId {
    final $$SelectedFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.selectedFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.selectedFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$WetarDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleNormalized => $composableBuilder(
    column: $table.titleNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistNormalized => $composableBuilder(
    column: $table.artistNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumNormalized => $composableBuilder(
    column: $table.albumNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => column,
  );

  GeneratedColumn<int> get channels =>
      $composableBuilder(column: $table.channels, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get dateModifiedSec => $composableBuilder(
    column: $table.dateModifiedSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateAddedSec => $composableBuilder(
    column: $table.dateAddedSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embeddedLyrics => $composableBuilder(
    column: $table.embeddedLyrics,
    builder: (column) => column,
  );

  GeneratedColumn<double> get replayGainTrackDb => $composableBuilder(
    column: $table.replayGainTrackDb,
    builder: (column) => column,
  );

  GeneratedColumn<double> get replayGainAlbumDb => $composableBuilder(
    column: $table.replayGainAlbumDb,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCloudPending => $composableBuilder(
    column: $table.isCloudPending,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorruptOrMissing => $composableBuilder(
    column: $table.isCorruptOrMissing,
    builder: (column) => column,
  );

  $$SelectedFoldersTableAnnotationComposer get folderId {
    final $$SelectedFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.selectedFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.selectedFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({bool folderId})
        > {
  $$TracksTableTableManager(_$WetarDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stableKey = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> folderPath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleNormalized = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> artistNormalized = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumNormalized = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> bitrateKbps = const Value.absent(),
                Value<int> sampleRateHz = const Value.absent(),
                Value<int> channels = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> dateModifiedSec = const Value.absent(),
                Value<int> dateAddedSec = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<String?> embeddedLyrics = const Value.absent(),
                Value<double?> replayGainTrackDb = const Value.absent(),
                Value<double?> replayGainAlbumDb = const Value.absent(),
                Value<bool> isCloudPending = const Value.absent(),
                Value<bool> isCorruptOrMissing = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                stableKey: stableKey,
                folderId: folderId,
                uri: uri,
                filePath: filePath,
                folderPath: folderPath,
                title: title,
                titleNormalized: titleNormalized,
                artist: artist,
                artistNormalized: artistNormalized,
                album: album,
                albumNormalized: albumNormalized,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                discNumber: discNumber,
                durationMs: durationMs,
                bitrateKbps: bitrateKbps,
                sampleRateHz: sampleRateHz,
                channels: channels,
                sizeBytes: sizeBytes,
                mimeType: mimeType,
                dateModifiedSec: dateModifiedSec,
                dateAddedSec: dateAddedSec,
                artworkUri: artworkUri,
                embeddedLyrics: embeddedLyrics,
                replayGainTrackDb: replayGainTrackDb,
                replayGainAlbumDb: replayGainAlbumDb,
                isCloudPending: isCloudPending,
                isCorruptOrMissing: isCorruptOrMissing,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stableKey,
                required int folderId,
                required String uri,
                required String filePath,
                required String folderPath,
                required String title,
                required String titleNormalized,
                Value<String> artist = const Value.absent(),
                Value<String> artistNormalized = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumNormalized = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> bitrateKbps = const Value.absent(),
                Value<int> sampleRateHz = const Value.absent(),
                Value<int> channels = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> dateModifiedSec = const Value.absent(),
                Value<int> dateAddedSec = const Value.absent(),
                Value<String?> artworkUri = const Value.absent(),
                Value<String?> embeddedLyrics = const Value.absent(),
                Value<double?> replayGainTrackDb = const Value.absent(),
                Value<double?> replayGainAlbumDb = const Value.absent(),
                Value<bool> isCloudPending = const Value.absent(),
                Value<bool> isCorruptOrMissing = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                stableKey: stableKey,
                folderId: folderId,
                uri: uri,
                filePath: filePath,
                folderPath: folderPath,
                title: title,
                titleNormalized: titleNormalized,
                artist: artist,
                artistNormalized: artistNormalized,
                album: album,
                albumNormalized: albumNormalized,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                discNumber: discNumber,
                durationMs: durationMs,
                bitrateKbps: bitrateKbps,
                sampleRateHz: sampleRateHz,
                channels: channels,
                sizeBytes: sizeBytes,
                mimeType: mimeType,
                dateModifiedSec: dateModifiedSec,
                dateAddedSec: dateAddedSec,
                artworkUri: artworkUri,
                embeddedLyrics: embeddedLyrics,
                replayGainTrackDb: replayGainTrackDb,
                replayGainAlbumDb: replayGainAlbumDb,
                isCloudPending: isCloudPending,
                isCorruptOrMissing: isCorruptOrMissing,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, Track>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$TracksTableReferences._folderIdTable(
                          db,
                        ),
                        referencedColumn: $$TracksTableReferences
                            ._folderIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$AlbumPalettesTableCreateCompanionBuilder =
    AlbumPalettesCompanion Function({
      required String albumKey,
      required int primaryArgb,
      required int secondaryArgb,
      required int backgroundArgb,
      required bool isDark,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AlbumPalettesTableUpdateCompanionBuilder =
    AlbumPalettesCompanion Function({
      Value<String> albumKey,
      Value<int> primaryArgb,
      Value<int> secondaryArgb,
      Value<int> backgroundArgb,
      Value<bool> isDark,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AlbumPalettesTableFilterComposer
    extends Composer<_$WetarDatabase, $AlbumPalettesTable> {
  $$AlbumPalettesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get albumKey => $composableBuilder(
    column: $table.albumKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primaryArgb => $composableBuilder(
    column: $table.primaryArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondaryArgb => $composableBuilder(
    column: $table.secondaryArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backgroundArgb => $composableBuilder(
    column: $table.backgroundArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDark => $composableBuilder(
    column: $table.isDark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlbumPalettesTableOrderingComposer
    extends Composer<_$WetarDatabase, $AlbumPalettesTable> {
  $$AlbumPalettesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get albumKey => $composableBuilder(
    column: $table.albumKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primaryArgb => $composableBuilder(
    column: $table.primaryArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondaryArgb => $composableBuilder(
    column: $table.secondaryArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundArgb => $composableBuilder(
    column: $table.backgroundArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDark => $composableBuilder(
    column: $table.isDark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumPalettesTableAnnotationComposer
    extends Composer<_$WetarDatabase, $AlbumPalettesTable> {
  $$AlbumPalettesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get albumKey =>
      $composableBuilder(column: $table.albumKey, builder: (column) => column);

  GeneratedColumn<int> get primaryArgb => $composableBuilder(
    column: $table.primaryArgb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get secondaryArgb => $composableBuilder(
    column: $table.secondaryArgb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get backgroundArgb => $composableBuilder(
    column: $table.backgroundArgb,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDark =>
      $composableBuilder(column: $table.isDark, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AlbumPalettesTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $AlbumPalettesTable,
          AlbumPalette,
          $$AlbumPalettesTableFilterComposer,
          $$AlbumPalettesTableOrderingComposer,
          $$AlbumPalettesTableAnnotationComposer,
          $$AlbumPalettesTableCreateCompanionBuilder,
          $$AlbumPalettesTableUpdateCompanionBuilder,
          (
            AlbumPalette,
            BaseReferences<_$WetarDatabase, $AlbumPalettesTable, AlbumPalette>,
          ),
          AlbumPalette,
          PrefetchHooks Function()
        > {
  $$AlbumPalettesTableTableManager(
    _$WetarDatabase db,
    $AlbumPalettesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumPalettesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumPalettesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumPalettesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> albumKey = const Value.absent(),
                Value<int> primaryArgb = const Value.absent(),
                Value<int> secondaryArgb = const Value.absent(),
                Value<int> backgroundArgb = const Value.absent(),
                Value<bool> isDark = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumPalettesCompanion(
                albumKey: albumKey,
                primaryArgb: primaryArgb,
                secondaryArgb: secondaryArgb,
                backgroundArgb: backgroundArgb,
                isDark: isDark,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String albumKey,
                required int primaryArgb,
                required int secondaryArgb,
                required int backgroundArgb,
                required bool isDark,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AlbumPalettesCompanion.insert(
                albumKey: albumKey,
                primaryArgb: primaryArgb,
                secondaryArgb: secondaryArgb,
                backgroundArgb: backgroundArgb,
                isDark: isDark,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlbumPalettesTable, AlbumPalette>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $AlbumPalettesTable,
                    AlbumPalette
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlbumPalettesTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $AlbumPalettesTable,
      AlbumPalette,
      $$AlbumPalettesTableFilterComposer,
      $$AlbumPalettesTableOrderingComposer,
      $$AlbumPalettesTableAnnotationComposer,
      $$AlbumPalettesTableCreateCompanionBuilder,
      $$AlbumPalettesTableUpdateCompanionBuilder,
      (
        AlbumPalette,
        BaseReferences<_$WetarDatabase, $AlbumPalettesTable, AlbumPalette>,
      ),
      AlbumPalette,
      PrefetchHooks Function()
    >;
typedef $$TrackUserMetaTableCreateCompanionBuilder =
    TrackUserMetaCompanion Function({
      required String stableKey,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<int?> lastPlayedAt,
      Value<int?> rememberedPositionMs,
      Value<String?> attachedLrcPath,
      Value<int> lyricOffsetMs,
      Value<String?> customArtPath,
      Value<int> rowid,
    });
typedef $$TrackUserMetaTableUpdateCompanionBuilder =
    TrackUserMetaCompanion Function({
      Value<String> stableKey,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<int?> lastPlayedAt,
      Value<int?> rememberedPositionMs,
      Value<String?> attachedLrcPath,
      Value<int> lyricOffsetMs,
      Value<String?> customArtPath,
      Value<int> rowid,
    });

class $$TrackUserMetaTableFilterComposer
    extends Composer<_$WetarDatabase, $TrackUserMetaTable> {
  $$TrackUserMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rememberedPositionMs => $composableBuilder(
    column: $table.rememberedPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachedLrcPath => $composableBuilder(
    column: $table.attachedLrcPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lyricOffsetMs => $composableBuilder(
    column: $table.lyricOffsetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customArtPath => $composableBuilder(
    column: $table.customArtPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackUserMetaTableOrderingComposer
    extends Composer<_$WetarDatabase, $TrackUserMetaTable> {
  $$TrackUserMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rememberedPositionMs => $composableBuilder(
    column: $table.rememberedPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachedLrcPath => $composableBuilder(
    column: $table.attachedLrcPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lyricOffsetMs => $composableBuilder(
    column: $table.lyricOffsetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customArtPath => $composableBuilder(
    column: $table.customArtPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackUserMetaTableAnnotationComposer
    extends Composer<_$WetarDatabase, $TrackUserMetaTable> {
  $$TrackUserMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rememberedPositionMs => $composableBuilder(
    column: $table.rememberedPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachedLrcPath => $composableBuilder(
    column: $table.attachedLrcPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lyricOffsetMs => $composableBuilder(
    column: $table.lyricOffsetMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customArtPath => $composableBuilder(
    column: $table.customArtPath,
    builder: (column) => column,
  );
}

class $$TrackUserMetaTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $TrackUserMetaTable,
          TrackUserMetaData,
          $$TrackUserMetaTableFilterComposer,
          $$TrackUserMetaTableOrderingComposer,
          $$TrackUserMetaTableAnnotationComposer,
          $$TrackUserMetaTableCreateCompanionBuilder,
          $$TrackUserMetaTableUpdateCompanionBuilder,
          (
            TrackUserMetaData,
            BaseReferences<
              _$WetarDatabase,
              $TrackUserMetaTable,
              TrackUserMetaData
            >,
          ),
          TrackUserMetaData,
          PrefetchHooks Function()
        > {
  $$TrackUserMetaTableTableManager(
    _$WetarDatabase db,
    $TrackUserMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackUserMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackUserMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackUserMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stableKey = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int?> rememberedPositionMs = const Value.absent(),
                Value<String?> attachedLrcPath = const Value.absent(),
                Value<int> lyricOffsetMs = const Value.absent(),
                Value<String?> customArtPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackUserMetaCompanion(
                stableKey: stableKey,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                rememberedPositionMs: rememberedPositionMs,
                attachedLrcPath: attachedLrcPath,
                lyricOffsetMs: lyricOffsetMs,
                customArtPath: customArtPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stableKey,
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int?> rememberedPositionMs = const Value.absent(),
                Value<String?> attachedLrcPath = const Value.absent(),
                Value<int> lyricOffsetMs = const Value.absent(),
                Value<String?> customArtPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackUserMetaCompanion.insert(
                stableKey: stableKey,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                rememberedPositionMs: rememberedPositionMs,
                attachedLrcPath: attachedLrcPath,
                lyricOffsetMs: lyricOffsetMs,
                customArtPath: customArtPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackUserMetaTable, TrackUserMetaData>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $TrackUserMetaTable,
                    TrackUserMetaData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackUserMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $TrackUserMetaTable,
      TrackUserMetaData,
      $$TrackUserMetaTableFilterComposer,
      $$TrackUserMetaTableOrderingComposer,
      $$TrackUserMetaTableAnnotationComposer,
      $$TrackUserMetaTableCreateCompanionBuilder,
      $$TrackUserMetaTableUpdateCompanionBuilder,
      (
        TrackUserMetaData,
        BaseReferences<_$WetarDatabase, $TrackUserMetaTable, TrackUserMetaData>,
      ),
      TrackUserMetaData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> smartKind,
  Value<String?> customCoverPath,
  required int createdAt,
  required int updatedAt,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> smartKind,
  Value<String?> customCoverPath,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$WetarDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntriesTable, List<PlaylistEntry>>
  _playlistEntriesRefsTable(_$WetarDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistEntries,
        aliasName: 'playlists__id__playlist_entries__playlist_id',
      );

  $$PlaylistEntriesTableProcessedTableManager get playlistEntriesRefs {
    final manager = $$PlaylistEntriesTableTableManager(
      $_db,
      $_db.playlistEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$WetarDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smartKind => $composableBuilder(
    column: $table.smartKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customCoverPath => $composableBuilder(
    column: $table.customCoverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntriesRefs(
    Expression<bool> Function($$PlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$WetarDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smartKind => $composableBuilder(
    column: $table.smartKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customCoverPath => $composableBuilder(
    column: $table.customCoverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$WetarDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get smartKind =>
      $composableBuilder(column: $table.smartKind, builder: (column) => column);

  GeneratedColumn<String> get customCoverPath => $composableBuilder(
    column: $table.customCoverPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistEntriesRefs})
        > {
  $$PlaylistsTableTableManager(_$WetarDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> smartKind = const Value.absent(),
                Value<String?> customCoverPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                smartKind: smartKind,
                customCoverPath: customCoverPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> smartKind = const Value.absent(),
                Value<String?> customCoverPath = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                smartKind: smartKind,
                customCoverPath: customCoverPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, Playlist>(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntriesRefs) db.playlistEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistEntry,
                      $PlaylistEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'playlist_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistEntriesRefs})
    >;
typedef $$PlaylistEntriesTableCreateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      required int playlistId,
      required String trackStableKey,
      required int position,
      required int addedAt,
    });
typedef $$PlaylistEntriesTableUpdateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<String> trackStableKey,
      Value<int> position,
      Value<int> addedAt,
    });

final class $$PlaylistEntriesTableReferences
    extends
        BaseReferences<_$WetarDatabase, $PlaylistEntriesTable, PlaylistEntry> {
  $$PlaylistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$WetarDatabase db) =>
      db.playlists.createAlias('playlist_entries__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistEntriesTableFilterComposer
    extends Composer<_$WetarDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableFilterComposer({
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

  ColumnFilters<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableOrderingComposer
    extends Composer<_$WetarDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableAnnotationComposer
    extends Composer<_$WetarDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $PlaylistEntriesTable,
          PlaylistEntry,
          $$PlaylistEntriesTableFilterComposer,
          $$PlaylistEntriesTableOrderingComposer,
          $$PlaylistEntriesTableAnnotationComposer,
          $$PlaylistEntriesTableCreateCompanionBuilder,
          $$PlaylistEntriesTableUpdateCompanionBuilder,
          (PlaylistEntry, $$PlaylistEntriesTableReferences),
          PlaylistEntry,
          PrefetchHooks Function({bool playlistId})
        > {
  $$PlaylistEntriesTableTableManager(
    _$WetarDatabase db,
    $PlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<String> trackStableKey = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
              }) => PlaylistEntriesCompanion(
                id: id,
                playlistId: playlistId,
                trackStableKey: trackStableKey,
                position: position,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                required String trackStableKey,
                required int position,
                required int addedAt,
              }) => PlaylistEntriesCompanion.insert(
                id: id,
                playlistId: playlistId,
                trackStableKey: trackStableKey,
                position: position,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistEntriesTable, PlaylistEntry>(table),
                  $$PlaylistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistEntriesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistEntriesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $PlaylistEntriesTable,
      PlaylistEntry,
      $$PlaylistEntriesTableFilterComposer,
      $$PlaylistEntriesTableOrderingComposer,
      $$PlaylistEntriesTableAnnotationComposer,
      $$PlaylistEntriesTableCreateCompanionBuilder,
      $$PlaylistEntriesTableUpdateCompanionBuilder,
      (PlaylistEntry, $$PlaylistEntriesTableReferences),
      PlaylistEntry,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$PlayHistoryEventsTableCreateCompanionBuilder =
    PlayHistoryEventsCompanion Function({
      Value<int> id,
      required String trackStableKey,
      required String trackTitle,
      required String artistName,
      required String albumName,
      required int playedAt,
      required int listenedMs,
    });
typedef $$PlayHistoryEventsTableUpdateCompanionBuilder =
    PlayHistoryEventsCompanion Function({
      Value<int> id,
      Value<String> trackStableKey,
      Value<String> trackTitle,
      Value<String> artistName,
      Value<String> albumName,
      Value<int> playedAt,
      Value<int> listenedMs,
    });

class $$PlayHistoryEventsTableFilterComposer
    extends Composer<_$WetarDatabase, $PlayHistoryEventsTable> {
  $$PlayHistoryEventsTableFilterComposer({
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

  ColumnFilters<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumName => $composableBuilder(
    column: $table.albumName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayHistoryEventsTableOrderingComposer
    extends Composer<_$WetarDatabase, $PlayHistoryEventsTable> {
  $$PlayHistoryEventsTableOrderingComposer({
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

  ColumnOrderings<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumName => $composableBuilder(
    column: $table.albumName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayHistoryEventsTableAnnotationComposer
    extends Composer<_$WetarDatabase, $PlayHistoryEventsTable> {
  $$PlayHistoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackStableKey => $composableBuilder(
    column: $table.trackStableKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumName =>
      $composableBuilder(column: $table.albumName, builder: (column) => column);

  GeneratedColumn<int> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );
}

class $$PlayHistoryEventsTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $PlayHistoryEventsTable,
          PlayHistoryEvent,
          $$PlayHistoryEventsTableFilterComposer,
          $$PlayHistoryEventsTableOrderingComposer,
          $$PlayHistoryEventsTableAnnotationComposer,
          $$PlayHistoryEventsTableCreateCompanionBuilder,
          $$PlayHistoryEventsTableUpdateCompanionBuilder,
          (
            PlayHistoryEvent,
            BaseReferences<
              _$WetarDatabase,
              $PlayHistoryEventsTable,
              PlayHistoryEvent
            >,
          ),
          PlayHistoryEvent,
          PrefetchHooks Function()
        > {
  $$PlayHistoryEventsTableTableManager(
    _$WetarDatabase db,
    $PlayHistoryEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackStableKey = const Value.absent(),
                Value<String> trackTitle = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<String> albumName = const Value.absent(),
                Value<int> playedAt = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
              }) => PlayHistoryEventsCompanion(
                id: id,
                trackStableKey: trackStableKey,
                trackTitle: trackTitle,
                artistName: artistName,
                albumName: albumName,
                playedAt: playedAt,
                listenedMs: listenedMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackStableKey,
                required String trackTitle,
                required String artistName,
                required String albumName,
                required int playedAt,
                required int listenedMs,
              }) => PlayHistoryEventsCompanion.insert(
                id: id,
                trackStableKey: trackStableKey,
                trackTitle: trackTitle,
                artistName: artistName,
                albumName: albumName,
                playedAt: playedAt,
                listenedMs: listenedMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayHistoryEventsTable, PlayHistoryEvent>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $PlayHistoryEventsTable,
                    PlayHistoryEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayHistoryEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $PlayHistoryEventsTable,
      PlayHistoryEvent,
      $$PlayHistoryEventsTableFilterComposer,
      $$PlayHistoryEventsTableOrderingComposer,
      $$PlayHistoryEventsTableAnnotationComposer,
      $$PlayHistoryEventsTableCreateCompanionBuilder,
      $$PlayHistoryEventsTableUpdateCompanionBuilder,
      (
        PlayHistoryEvent,
        BaseReferences<
          _$WetarDatabase,
          $PlayHistoryEventsTable,
          PlayHistoryEvent
        >,
      ),
      PlayHistoryEvent,
      PrefetchHooks Function()
    >;
typedef $$QueueSnapshotsTableCreateCompanionBuilder =
    QueueSnapshotsCompanion Function({
      Value<int> id,
      required String itemsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
      required int updatedAt,
    });
typedef $$QueueSnapshotsTableUpdateCompanionBuilder =
    QueueSnapshotsCompanion Function({
      Value<int> id,
      Value<String> itemsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
      Value<int> updatedAt,
    });

class $$QueueSnapshotsTableFilterComposer
    extends Composer<_$WetarDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableFilterComposer({
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

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueSnapshotsTableOrderingComposer
    extends Composer<_$WetarDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableOrderingComposer({
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

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueSnapshotsTableAnnotationComposer
    extends Composer<_$WetarDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QueueSnapshotsTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $QueueSnapshotsTable,
          QueueSnapshot,
          $$QueueSnapshotsTableFilterComposer,
          $$QueueSnapshotsTableOrderingComposer,
          $$QueueSnapshotsTableAnnotationComposer,
          $$QueueSnapshotsTableCreateCompanionBuilder,
          $$QueueSnapshotsTableUpdateCompanionBuilder,
          (
            QueueSnapshot,
            BaseReferences<
              _$WetarDatabase,
              $QueueSnapshotsTable,
              QueueSnapshot
            >,
          ),
          QueueSnapshot,
          PrefetchHooks Function()
        > {
  $$QueueSnapshotsTableTableManager(
    _$WetarDatabase db,
    $QueueSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => QueueSnapshotsCompanion(
                id: id,
                itemsJson: itemsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemsJson,
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                required int updatedAt,
              }) => QueueSnapshotsCompanion.insert(
                id: id,
                itemsJson: itemsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueSnapshotsTable, QueueSnapshot>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $QueueSnapshotsTable,
                    QueueSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $QueueSnapshotsTable,
      QueueSnapshot,
      $$QueueSnapshotsTableFilterComposer,
      $$QueueSnapshotsTableOrderingComposer,
      $$QueueSnapshotsTableAnnotationComposer,
      $$QueueSnapshotsTableCreateCompanionBuilder,
      $$QueueSnapshotsTableUpdateCompanionBuilder,
      (
        QueueSnapshot,
        BaseReferences<_$WetarDatabase, $QueueSnapshotsTable, QueueSnapshot>,
      ),
      QueueSnapshot,
      PrefetchHooks Function()
    >;
typedef $$EqualizerPresetsTableCreateCompanionBuilder =
    EqualizerPresetsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isCustom,
      required String bandGainsJson,
      Value<int> bassBoostStrength,
      Value<int> virtualizerStrength,
      Value<int> loudnessGainMb,
      required int updatedAt,
    });
typedef $$EqualizerPresetsTableUpdateCompanionBuilder =
    EqualizerPresetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isCustom,
      Value<String> bandGainsJson,
      Value<int> bassBoostStrength,
      Value<int> virtualizerStrength,
      Value<int> loudnessGainMb,
      Value<int> updatedAt,
    });

class $$EqualizerPresetsTableFilterComposer
    extends Composer<_$WetarDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandGainsJson => $composableBuilder(
    column: $table.bandGainsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bassBoostStrength => $composableBuilder(
    column: $table.bassBoostStrength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get virtualizerStrength => $composableBuilder(
    column: $table.virtualizerStrength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loudnessGainMb => $composableBuilder(
    column: $table.loudnessGainMb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EqualizerPresetsTableOrderingComposer
    extends Composer<_$WetarDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandGainsJson => $composableBuilder(
    column: $table.bandGainsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bassBoostStrength => $composableBuilder(
    column: $table.bassBoostStrength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get virtualizerStrength => $composableBuilder(
    column: $table.virtualizerStrength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loudnessGainMb => $composableBuilder(
    column: $table.loudnessGainMb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EqualizerPresetsTableAnnotationComposer
    extends Composer<_$WetarDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get bandGainsJson => $composableBuilder(
    column: $table.bandGainsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bassBoostStrength => $composableBuilder(
    column: $table.bassBoostStrength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get virtualizerStrength => $composableBuilder(
    column: $table.virtualizerStrength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loudnessGainMb => $composableBuilder(
    column: $table.loudnessGainMb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EqualizerPresetsTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $EqualizerPresetsTable,
          EqualizerPreset,
          $$EqualizerPresetsTableFilterComposer,
          $$EqualizerPresetsTableOrderingComposer,
          $$EqualizerPresetsTableAnnotationComposer,
          $$EqualizerPresetsTableCreateCompanionBuilder,
          $$EqualizerPresetsTableUpdateCompanionBuilder,
          (
            EqualizerPreset,
            BaseReferences<
              _$WetarDatabase,
              $EqualizerPresetsTable,
              EqualizerPreset
            >,
          ),
          EqualizerPreset,
          PrefetchHooks Function()
        > {
  $$EqualizerPresetsTableTableManager(
    _$WetarDatabase db,
    $EqualizerPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EqualizerPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EqualizerPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EqualizerPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String> bandGainsJson = const Value.absent(),
                Value<int> bassBoostStrength = const Value.absent(),
                Value<int> virtualizerStrength = const Value.absent(),
                Value<int> loudnessGainMb = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => EqualizerPresetsCompanion(
                id: id,
                name: name,
                isCustom: isCustom,
                bandGainsJson: bandGainsJson,
                bassBoostStrength: bassBoostStrength,
                virtualizerStrength: virtualizerStrength,
                loudnessGainMb: loudnessGainMb,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isCustom = const Value.absent(),
                required String bandGainsJson,
                Value<int> bassBoostStrength = const Value.absent(),
                Value<int> virtualizerStrength = const Value.absent(),
                Value<int> loudnessGainMb = const Value.absent(),
                required int updatedAt,
              }) => EqualizerPresetsCompanion.insert(
                id: id,
                name: name,
                isCustom: isCustom,
                bandGainsJson: bandGainsJson,
                bassBoostStrength: bassBoostStrength,
                virtualizerStrength: virtualizerStrength,
                loudnessGainMb: loudnessGainMb,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EqualizerPresetsTable, EqualizerPreset>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $EqualizerPresetsTable,
                    EqualizerPreset
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EqualizerPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $EqualizerPresetsTable,
      EqualizerPreset,
      $$EqualizerPresetsTableFilterComposer,
      $$EqualizerPresetsTableOrderingComposer,
      $$EqualizerPresetsTableAnnotationComposer,
      $$EqualizerPresetsTableCreateCompanionBuilder,
      $$EqualizerPresetsTableUpdateCompanionBuilder,
      (
        EqualizerPreset,
        BaseReferences<
          _$WetarDatabase,
          $EqualizerPresetsTable,
          EqualizerPreset
        >,
      ),
      EqualizerPreset,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required String query,
      required String normalizedQuery,
      required int searchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<String> query,
      Value<String> normalizedQuery,
      Value<int> searchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$WetarDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$WetarDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$WetarDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => column,
  );

  GeneratedColumn<int> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$WetarDatabase,
          $RecentSearchesTable,
          RecentSearche,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearche,
            BaseReferences<
              _$WetarDatabase,
              $RecentSearchesTable,
              RecentSearche
            >,
          ),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$WetarDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> query = const Value.absent(),
                Value<String> normalizedQuery = const Value.absent(),
                Value<int> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                query: query,
                normalizedQuery: normalizedQuery,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String query,
                required String normalizedQuery,
                required int searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                query: query,
                normalizedQuery: normalizedQuery,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearche>(table),
                  BaseReferences<
                    _$WetarDatabase,
                    $RecentSearchesTable,
                    RecentSearche
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$WetarDatabase,
      $RecentSearchesTable,
      RecentSearche,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearche,
        BaseReferences<_$WetarDatabase, $RecentSearchesTable, RecentSearche>,
      ),
      RecentSearche,
      PrefetchHooks Function()
    >;

class $WetarDatabaseManager {
  final _$WetarDatabase _db;
  $WetarDatabaseManager(this._db);
  $$SelectedFoldersTableTableManager get selectedFolders =>
      $$SelectedFoldersTableTableManager(_db, _db.selectedFolders);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$AlbumPalettesTableTableManager get albumPalettes =>
      $$AlbumPalettesTableTableManager(_db, _db.albumPalettes);
  $$TrackUserMetaTableTableManager get trackUserMeta =>
      $$TrackUserMetaTableTableManager(_db, _db.trackUserMeta);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(_db, _db.playlistEntries);
  $$PlayHistoryEventsTableTableManager get playHistoryEvents =>
      $$PlayHistoryEventsTableTableManager(_db, _db.playHistoryEvents);
  $$QueueSnapshotsTableTableManager get queueSnapshots =>
      $$QueueSnapshotsTableTableManager(_db, _db.queueSnapshots);
  $$EqualizerPresetsTableTableManager get equalizerPresets =>
      $$EqualizerPresetsTableTableManager(_db, _db.equalizerPresets);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
}
