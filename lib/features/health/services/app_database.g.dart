// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HealthReadingsTableTable extends HealthReadingsTable
    with TableInfo<$HealthReadingsTableTable, HealthReadingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthReadingsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spo2Meta = const VerificationMeta('spo2');
  @override
  late final GeneratedColumn<int> spo2 = GeneratedColumn<int>(
    'spo2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientUuid,
    deviceId,
    heartRate,
    spo2,
    steps,
    recordedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_readings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthReadingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    } else if (isInserting) {
      context.missing(_heartRateMeta);
    }
    if (data.containsKey('spo2')) {
      context.handle(
        _spo2Meta,
        spo2.isAcceptableOrUnknown(data['spo2']!, _spo2Meta),
      );
    } else if (isInserting) {
      context.missing(_spo2Meta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthReadingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthReadingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      )!,
      spo2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spo2'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $HealthReadingsTableTable createAlias(String alias) {
    return $HealthReadingsTableTable(attachedDatabase, alias);
  }
}

class HealthReadingsTableData extends DataClass
    implements Insertable<HealthReadingsTableData> {
  final int id;
  final String clientUuid;
  final String deviceId;
  final int heartRate;
  final int spo2;
  final int steps;
  final DateTime recordedAt;
  final bool synced;
  const HealthReadingsTableData({
    required this.id,
    required this.clientUuid,
    required this.deviceId,
    required this.heartRate,
    required this.spo2,
    required this.steps,
    required this.recordedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['device_id'] = Variable<String>(deviceId);
    map['heart_rate'] = Variable<int>(heartRate);
    map['spo2'] = Variable<int>(spo2);
    map['steps'] = Variable<int>(steps);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HealthReadingsTableCompanion toCompanion(bool nullToAbsent) {
    return HealthReadingsTableCompanion(
      id: Value(id),
      clientUuid: Value(clientUuid),
      deviceId: Value(deviceId),
      heartRate: Value(heartRate),
      spo2: Value(spo2),
      steps: Value(steps),
      recordedAt: Value(recordedAt),
      synced: Value(synced),
    );
  }

  factory HealthReadingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthReadingsTableData(
      id: serializer.fromJson<int>(json['id']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      heartRate: serializer.fromJson<int>(json['heartRate']),
      spo2: serializer.fromJson<int>(json['spo2']),
      steps: serializer.fromJson<int>(json['steps']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'deviceId': serializer.toJson<String>(deviceId),
      'heartRate': serializer.toJson<int>(heartRate),
      'spo2': serializer.toJson<int>(spo2),
      'steps': serializer.toJson<int>(steps),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  HealthReadingsTableData copyWith({
    int? id,
    String? clientUuid,
    String? deviceId,
    int? heartRate,
    int? spo2,
    int? steps,
    DateTime? recordedAt,
    bool? synced,
  }) => HealthReadingsTableData(
    id: id ?? this.id,
    clientUuid: clientUuid ?? this.clientUuid,
    deviceId: deviceId ?? this.deviceId,
    heartRate: heartRate ?? this.heartRate,
    spo2: spo2 ?? this.spo2,
    steps: steps ?? this.steps,
    recordedAt: recordedAt ?? this.recordedAt,
    synced: synced ?? this.synced,
  );
  HealthReadingsTableData copyWithCompanion(HealthReadingsTableCompanion data) {
    return HealthReadingsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      spo2: data.spo2.present ? data.spo2.value : this.spo2,
      steps: data.steps.present ? data.steps.value : this.steps,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthReadingsTableData(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('deviceId: $deviceId, ')
          ..write('heartRate: $heartRate, ')
          ..write('spo2: $spo2, ')
          ..write('steps: $steps, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientUuid,
    deviceId,
    heartRate,
    spo2,
    steps,
    recordedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthReadingsTableData &&
          other.id == this.id &&
          other.clientUuid == this.clientUuid &&
          other.deviceId == this.deviceId &&
          other.heartRate == this.heartRate &&
          other.spo2 == this.spo2 &&
          other.steps == this.steps &&
          other.recordedAt == this.recordedAt &&
          other.synced == this.synced);
}

class HealthReadingsTableCompanion
    extends UpdateCompanion<HealthReadingsTableData> {
  final Value<int> id;
  final Value<String> clientUuid;
  final Value<String> deviceId;
  final Value<int> heartRate;
  final Value<int> spo2;
  final Value<int> steps;
  final Value<DateTime> recordedAt;
  final Value<bool> synced;
  const HealthReadingsTableCompanion({
    this.id = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.steps = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  HealthReadingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String clientUuid,
    required String deviceId,
    required int heartRate,
    required int spo2,
    required int steps,
    required DateTime recordedAt,
    this.synced = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       deviceId = Value(deviceId),
       heartRate = Value(heartRate),
       spo2 = Value(spo2),
       steps = Value(steps),
       recordedAt = Value(recordedAt);
  static Insertable<HealthReadingsTableData> custom({
    Expression<int>? id,
    Expression<String>? clientUuid,
    Expression<String>? deviceId,
    Expression<int>? heartRate,
    Expression<int>? spo2,
    Expression<int>? steps,
    Expression<DateTime>? recordedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (deviceId != null) 'device_id': deviceId,
      if (heartRate != null) 'heart_rate': heartRate,
      if (spo2 != null) 'spo2': spo2,
      if (steps != null) 'steps': steps,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (synced != null) 'synced': synced,
    });
  }

  HealthReadingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? clientUuid,
    Value<String>? deviceId,
    Value<int>? heartRate,
    Value<int>? spo2,
    Value<int>? steps,
    Value<DateTime>? recordedAt,
    Value<bool>? synced,
  }) {
    return HealthReadingsTableCompanion(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      deviceId: deviceId ?? this.deviceId,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      steps: steps ?? this.steps,
      recordedAt: recordedAt ?? this.recordedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (spo2.present) {
      map['spo2'] = Variable<int>(spo2.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthReadingsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('deviceId: $deviceId, ')
          ..write('heartRate: $heartRate, ')
          ..write('spo2: $spo2, ')
          ..write('steps: $steps, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HealthReadingsTableTable healthReadingsTable =
      $HealthReadingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [healthReadingsTable];
}

typedef $$HealthReadingsTableTableCreateCompanionBuilder =
    HealthReadingsTableCompanion Function({
      Value<int> id,
      required String clientUuid,
      required String deviceId,
      required int heartRate,
      required int spo2,
      required int steps,
      required DateTime recordedAt,
      Value<bool> synced,
    });
typedef $$HealthReadingsTableTableUpdateCompanionBuilder =
    HealthReadingsTableCompanion Function({
      Value<int> id,
      Value<String> clientUuid,
      Value<String> deviceId,
      Value<int> heartRate,
      Value<int> spo2,
      Value<int> steps,
      Value<DateTime> recordedAt,
      Value<bool> synced,
    });

class $$HealthReadingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HealthReadingsTableTable> {
  $$HealthReadingsTableTableFilterComposer({
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

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthReadingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthReadingsTableTable> {
  $$HealthReadingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthReadingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthReadingsTableTable> {
  $$HealthReadingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get spo2 =>
      $composableBuilder(column: $table.spo2, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HealthReadingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthReadingsTableTable,
          HealthReadingsTableData,
          $$HealthReadingsTableTableFilterComposer,
          $$HealthReadingsTableTableOrderingComposer,
          $$HealthReadingsTableTableAnnotationComposer,
          $$HealthReadingsTableTableCreateCompanionBuilder,
          $$HealthReadingsTableTableUpdateCompanionBuilder,
          (
            HealthReadingsTableData,
            BaseReferences<
              _$AppDatabase,
              $HealthReadingsTableTable,
              HealthReadingsTableData
            >,
          ),
          HealthReadingsTableData,
          PrefetchHooks Function()
        > {
  $$HealthReadingsTableTableTableManager(
    _$AppDatabase db,
    $HealthReadingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthReadingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthReadingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HealthReadingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> heartRate = const Value.absent(),
                Value<int> spo2 = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => HealthReadingsTableCompanion(
                id: id,
                clientUuid: clientUuid,
                deviceId: deviceId,
                heartRate: heartRate,
                spo2: spo2,
                steps: steps,
                recordedAt: recordedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientUuid,
                required String deviceId,
                required int heartRate,
                required int spo2,
                required int steps,
                required DateTime recordedAt,
                Value<bool> synced = const Value.absent(),
              }) => HealthReadingsTableCompanion.insert(
                id: id,
                clientUuid: clientUuid,
                deviceId: deviceId,
                heartRate: heartRate,
                spo2: spo2,
                steps: steps,
                recordedAt: recordedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthReadingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthReadingsTableTable,
      HealthReadingsTableData,
      $$HealthReadingsTableTableFilterComposer,
      $$HealthReadingsTableTableOrderingComposer,
      $$HealthReadingsTableTableAnnotationComposer,
      $$HealthReadingsTableTableCreateCompanionBuilder,
      $$HealthReadingsTableTableUpdateCompanionBuilder,
      (
        HealthReadingsTableData,
        BaseReferences<
          _$AppDatabase,
          $HealthReadingsTableTable,
          HealthReadingsTableData
        >,
      ),
      HealthReadingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HealthReadingsTableTableTableManager get healthReadingsTable =>
      $$HealthReadingsTableTableTableManager(_db, _db.healthReadingsTable);
}
