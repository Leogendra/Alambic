// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remanence_database.dart';

// ignore_for_file: type=lint
class $PresetsTable extends Presets with TableInfo<$PresetsTable, Preset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<BuiltInPresetKey?, String>
  builtInKey = GeneratedColumn<String>(
    'built_in_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<BuiltInPresetKey?>($PresetsTable.$converterbuiltInKeyn);
  @override
  late final GeneratedColumnWithTypeConverter<SchedulingEngineKind, String>
  engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SchedulingEngineKind>($PresetsTable.$converterengine);
  @override
  late final GeneratedColumnWithTypeConverter<List<PresetInterval>, String>
  intervals = GeneratedColumn<String>(
    'intervals',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<PresetInterval>>($PresetsTable.$converterintervals);
  @override
  late final GeneratedColumnWithTypeConverter<FailureBehavior, String>
  failureBehavior = GeneratedColumn<String>(
    'failure_behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<FailureBehavior>($PresetsTable.$converterfailureBehavior);
  @override
  late final GeneratedColumnWithTypeConverter<SequenceEndBehavior, String>
  endBehavior = GeneratedColumn<String>(
    'end_behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SequenceEndBehavior>($PresetsTable.$converterendBehavior);
  static const VerificationMeta _typedAnswerMeta = const VerificationMeta(
    'typedAnswer',
  );
  @override
  late final GeneratedColumn<bool> typedAnswer = GeneratedColumn<bool>(
    'typed_answer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("typed_answer" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleKind, String>
  scheduleKind = GeneratedColumn<String>(
    'schedule_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ScheduleKind>($PresetsTable.$converterscheduleKind);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> fixedTime =
      GeneratedColumn<int>(
        'fixed_time',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ClockTime>($PresetsTable.$converterfixedTime);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> rangeStart =
      GeneratedColumn<int>(
        'range_start',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ClockTime>($PresetsTable.$converterrangeStart);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> rangeEnd =
      GeneratedColumn<int>(
        'range_end',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ClockTime>($PresetsTable.$converterrangeEnd);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationMode, String>
  notificationMode = GeneratedColumn<String>(
    'notification_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<NotificationMode>($PresetsTable.$converternotificationMode);
  @override
  late final GeneratedColumnWithTypeConverter<GroupedReminderAction, String>
  groupedAction = GeneratedColumn<String>(
    'grouped_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<GroupedReminderAction>($PresetsTable.$convertergroupedAction);
  static const VerificationMeta _targetRetentionMeta = const VerificationMeta(
    'targetRetention',
  );
  @override
  late final GeneratedColumn<double> targetRetention = GeneratedColumn<double>(
    'target_retention',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    builtInKey,
    engine,
    intervals,
    failureBehavior,
    endBehavior,
    typedAnswer,
    scheduleKind,
    fixedTime,
    rangeStart,
    rangeEnd,
    notificationMode,
    groupedAction,
    targetRetention,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preset> instance, {
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
    if (data.containsKey('typed_answer')) {
      context.handle(
        _typedAnswerMeta,
        typedAnswer.isAcceptableOrUnknown(
          data['typed_answer']!,
          _typedAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_typedAnswerMeta);
    }
    if (data.containsKey('target_retention')) {
      context.handle(
        _targetRetentionMeta,
        targetRetention.isAcceptableOrUnknown(
          data['target_retention']!,
          _targetRetentionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetRetentionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Preset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      builtInKey: $PresetsTable.$converterbuiltInKeyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}built_in_key'],
        ),
      ),
      engine: $PresetsTable.$converterengine.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}engine'],
        )!,
      ),
      intervals: $PresetsTable.$converterintervals.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}intervals'],
        )!,
      ),
      failureBehavior: $PresetsTable.$converterfailureBehavior.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}failure_behavior'],
        )!,
      ),
      endBehavior: $PresetsTable.$converterendBehavior.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_behavior'],
        )!,
      ),
      typedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}typed_answer'],
      )!,
      scheduleKind: $PresetsTable.$converterscheduleKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_kind'],
        )!,
      ),
      fixedTime: $PresetsTable.$converterfixedTime.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}fixed_time'],
        )!,
      ),
      rangeStart: $PresetsTable.$converterrangeStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}range_start'],
        )!,
      ),
      rangeEnd: $PresetsTable.$converterrangeEnd.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}range_end'],
        )!,
      ),
      notificationMode: $PresetsTable.$converternotificationMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notification_mode'],
        )!,
      ),
      groupedAction: $PresetsTable.$convertergroupedAction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}grouped_action'],
        )!,
      ),
      targetRetention: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_retention'],
      )!,
    );
  }

  @override
  $PresetsTable createAlias(String alias) {
    return $PresetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BuiltInPresetKey, String, String>
  $converterbuiltInKey = const EnumNameConverter<BuiltInPresetKey>(
    BuiltInPresetKey.values,
  );
  static JsonTypeConverter2<BuiltInPresetKey?, String?, String?>
  $converterbuiltInKeyn = JsonTypeConverter2.asNullable($converterbuiltInKey);
  static JsonTypeConverter2<SchedulingEngineKind, String, String>
  $converterengine = const EnumNameConverter<SchedulingEngineKind>(
    SchedulingEngineKind.values,
  );
  static TypeConverter<List<PresetInterval>, String> $converterintervals =
      const PresetIntervalListConverter();
  static JsonTypeConverter2<FailureBehavior, String, String>
  $converterfailureBehavior = const EnumNameConverter<FailureBehavior>(
    FailureBehavior.values,
  );
  static JsonTypeConverter2<SequenceEndBehavior, String, String>
  $converterendBehavior = const EnumNameConverter<SequenceEndBehavior>(
    SequenceEndBehavior.values,
  );
  static JsonTypeConverter2<ScheduleKind, String, String>
  $converterscheduleKind = const EnumNameConverter<ScheduleKind>(
    ScheduleKind.values,
  );
  static TypeConverter<ClockTime, int> $converterfixedTime =
      const ClockTimeConverter();
  static TypeConverter<ClockTime, int> $converterrangeStart =
      const ClockTimeConverter();
  static TypeConverter<ClockTime, int> $converterrangeEnd =
      const ClockTimeConverter();
  static JsonTypeConverter2<NotificationMode, String, String>
  $converternotificationMode = const EnumNameConverter<NotificationMode>(
    NotificationMode.values,
  );
  static JsonTypeConverter2<GroupedReminderAction, String, String>
  $convertergroupedAction = const EnumNameConverter<GroupedReminderAction>(
    GroupedReminderAction.values,
  );
}

class PresetsCompanion extends UpdateCompanion<Preset> {
  final Value<int> id;
  final Value<String> name;
  final Value<BuiltInPresetKey?> builtInKey;
  final Value<SchedulingEngineKind> engine;
  final Value<List<PresetInterval>> intervals;
  final Value<FailureBehavior> failureBehavior;
  final Value<SequenceEndBehavior> endBehavior;
  final Value<bool> typedAnswer;
  final Value<ScheduleKind> scheduleKind;
  final Value<ClockTime> fixedTime;
  final Value<ClockTime> rangeStart;
  final Value<ClockTime> rangeEnd;
  final Value<NotificationMode> notificationMode;
  final Value<GroupedReminderAction> groupedAction;
  final Value<double> targetRetention;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.builtInKey = const Value.absent(),
    this.engine = const Value.absent(),
    this.intervals = const Value.absent(),
    this.failureBehavior = const Value.absent(),
    this.endBehavior = const Value.absent(),
    this.typedAnswer = const Value.absent(),
    this.scheduleKind = const Value.absent(),
    this.fixedTime = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.notificationMode = const Value.absent(),
    this.groupedAction = const Value.absent(),
    this.targetRetention = const Value.absent(),
  });
  PresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.builtInKey = const Value.absent(),
    required SchedulingEngineKind engine,
    required List<PresetInterval> intervals,
    required FailureBehavior failureBehavior,
    required SequenceEndBehavior endBehavior,
    required bool typedAnswer,
    required ScheduleKind scheduleKind,
    required ClockTime fixedTime,
    required ClockTime rangeStart,
    required ClockTime rangeEnd,
    required NotificationMode notificationMode,
    required GroupedReminderAction groupedAction,
    required double targetRetention,
  }) : name = Value(name),
       engine = Value(engine),
       intervals = Value(intervals),
       failureBehavior = Value(failureBehavior),
       endBehavior = Value(endBehavior),
       typedAnswer = Value(typedAnswer),
       scheduleKind = Value(scheduleKind),
       fixedTime = Value(fixedTime),
       rangeStart = Value(rangeStart),
       rangeEnd = Value(rangeEnd),
       notificationMode = Value(notificationMode),
       groupedAction = Value(groupedAction),
       targetRetention = Value(targetRetention);
  static Insertable<Preset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? builtInKey,
    Expression<String>? engine,
    Expression<String>? intervals,
    Expression<String>? failureBehavior,
    Expression<String>? endBehavior,
    Expression<bool>? typedAnswer,
    Expression<String>? scheduleKind,
    Expression<int>? fixedTime,
    Expression<int>? rangeStart,
    Expression<int>? rangeEnd,
    Expression<String>? notificationMode,
    Expression<String>? groupedAction,
    Expression<double>? targetRetention,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (builtInKey != null) 'built_in_key': builtInKey,
      if (engine != null) 'engine': engine,
      if (intervals != null) 'intervals': intervals,
      if (failureBehavior != null) 'failure_behavior': failureBehavior,
      if (endBehavior != null) 'end_behavior': endBehavior,
      if (typedAnswer != null) 'typed_answer': typedAnswer,
      if (scheduleKind != null) 'schedule_kind': scheduleKind,
      if (fixedTime != null) 'fixed_time': fixedTime,
      if (rangeStart != null) 'range_start': rangeStart,
      if (rangeEnd != null) 'range_end': rangeEnd,
      if (notificationMode != null) 'notification_mode': notificationMode,
      if (groupedAction != null) 'grouped_action': groupedAction,
      if (targetRetention != null) 'target_retention': targetRetention,
    });
  }

  PresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<BuiltInPresetKey?>? builtInKey,
    Value<SchedulingEngineKind>? engine,
    Value<List<PresetInterval>>? intervals,
    Value<FailureBehavior>? failureBehavior,
    Value<SequenceEndBehavior>? endBehavior,
    Value<bool>? typedAnswer,
    Value<ScheduleKind>? scheduleKind,
    Value<ClockTime>? fixedTime,
    Value<ClockTime>? rangeStart,
    Value<ClockTime>? rangeEnd,
    Value<NotificationMode>? notificationMode,
    Value<GroupedReminderAction>? groupedAction,
    Value<double>? targetRetention,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      builtInKey: builtInKey ?? this.builtInKey,
      engine: engine ?? this.engine,
      intervals: intervals ?? this.intervals,
      failureBehavior: failureBehavior ?? this.failureBehavior,
      endBehavior: endBehavior ?? this.endBehavior,
      typedAnswer: typedAnswer ?? this.typedAnswer,
      scheduleKind: scheduleKind ?? this.scheduleKind,
      fixedTime: fixedTime ?? this.fixedTime,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      notificationMode: notificationMode ?? this.notificationMode,
      groupedAction: groupedAction ?? this.groupedAction,
      targetRetention: targetRetention ?? this.targetRetention,
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
    if (builtInKey.present) {
      map['built_in_key'] = Variable<String>(
        $PresetsTable.$converterbuiltInKeyn.toSql(builtInKey.value),
      );
    }
    if (engine.present) {
      map['engine'] = Variable<String>(
        $PresetsTable.$converterengine.toSql(engine.value),
      );
    }
    if (intervals.present) {
      map['intervals'] = Variable<String>(
        $PresetsTable.$converterintervals.toSql(intervals.value),
      );
    }
    if (failureBehavior.present) {
      map['failure_behavior'] = Variable<String>(
        $PresetsTable.$converterfailureBehavior.toSql(failureBehavior.value),
      );
    }
    if (endBehavior.present) {
      map['end_behavior'] = Variable<String>(
        $PresetsTable.$converterendBehavior.toSql(endBehavior.value),
      );
    }
    if (typedAnswer.present) {
      map['typed_answer'] = Variable<bool>(typedAnswer.value);
    }
    if (scheduleKind.present) {
      map['schedule_kind'] = Variable<String>(
        $PresetsTable.$converterscheduleKind.toSql(scheduleKind.value),
      );
    }
    if (fixedTime.present) {
      map['fixed_time'] = Variable<int>(
        $PresetsTable.$converterfixedTime.toSql(fixedTime.value),
      );
    }
    if (rangeStart.present) {
      map['range_start'] = Variable<int>(
        $PresetsTable.$converterrangeStart.toSql(rangeStart.value),
      );
    }
    if (rangeEnd.present) {
      map['range_end'] = Variable<int>(
        $PresetsTable.$converterrangeEnd.toSql(rangeEnd.value),
      );
    }
    if (notificationMode.present) {
      map['notification_mode'] = Variable<String>(
        $PresetsTable.$converternotificationMode.toSql(notificationMode.value),
      );
    }
    if (groupedAction.present) {
      map['grouped_action'] = Variable<String>(
        $PresetsTable.$convertergroupedAction.toSql(groupedAction.value),
      );
    }
    if (targetRetention.present) {
      map['target_retention'] = Variable<double>(targetRetention.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('builtInKey: $builtInKey, ')
          ..write('engine: $engine, ')
          ..write('intervals: $intervals, ')
          ..write('failureBehavior: $failureBehavior, ')
          ..write('endBehavior: $endBehavior, ')
          ..write('typedAnswer: $typedAnswer, ')
          ..write('scheduleKind: $scheduleKind, ')
          ..write('fixedTime: $fixedTime, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('notificationMode: $notificationMode, ')
          ..write('groupedAction: $groupedAction, ')
          ..write('targetRetention: $targetRetention')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _globalPresetIdMeta = const VerificationMeta(
    'globalPresetId',
  );
  @override
  late final GeneratedColumn<int> globalPresetId = GeneratedColumn<int>(
    'global_preset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES presets (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, globalPresetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('global_preset_id')) {
      context.handle(
        _globalPresetIdMeta,
        globalPresetId.isAcceptableOrUnknown(
          data['global_preset_id']!,
          _globalPresetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_globalPresetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      globalPresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}global_preset_id'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  /// Always 1: the table holds a single row.
  final int id;
  final int globalPresetId;
  const AppSettingsRow({required this.id, required this.globalPresetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_preset_id'] = Variable<int>(globalPresetId);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      globalPresetId: Value(globalPresetId),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      globalPresetId: serializer.fromJson<int>(json['globalPresetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalPresetId': serializer.toJson<int>(globalPresetId),
    };
  }

  AppSettingsRow copyWith({int? id, int? globalPresetId}) => AppSettingsRow(
    id: id ?? this.id,
    globalPresetId: globalPresetId ?? this.globalPresetId,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      globalPresetId: data.globalPresetId.present
          ? data.globalPresetId.value
          : this.globalPresetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('globalPresetId: $globalPresetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, globalPresetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.globalPresetId == this.globalPresetId);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> globalPresetId;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.globalPresetId = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int globalPresetId,
  }) : globalPresetId = Value(globalPresetId);
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? globalPresetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalPresetId != null) 'global_preset_id': globalPresetId,
    });
  }

  AppSettingsCompanion copyWith({Value<int>? id, Value<int>? globalPresetId}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      globalPresetId: globalPresetId ?? this.globalPresetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (globalPresetId.present) {
      map['global_preset_id'] = Variable<int>(globalPresetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('globalPresetId: $globalPresetId')
          ..write(')'))
        .toString();
  }
}

class $CardGroupsTable extends CardGroups
    with TableInfo<$CardGroupsTable, CardGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<int> presetId = GeneratedColumn<int>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES presets (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, presetId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardGroup> instance, {
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
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardGroupsTable createAlias(String alias) {
    return $CardGroupsTable(attachedDatabase, alias);
  }
}

class CardGroupsCompanion extends UpdateCompanion<CardGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> presetId;
  final Value<DateTime> createdAt;
  const CardGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.presetId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.presetId = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CardGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? presetId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (presetId != null) 'preset_id': presetId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? presetId,
    Value<DateTime>? createdAt,
  }) {
    return CardGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      presetId: presetId ?? this.presetId,
      createdAt: createdAt ?? this.createdAt,
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
    if (presetId.present) {
      map['preset_id'] = Variable<int>(presetId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('presetId: $presetId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frontTextMeta = const VerificationMeta(
    'frontText',
  );
  @override
  late final GeneratedColumn<String> frontText = GeneratedColumn<String>(
    'front_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frontImagePathMeta = const VerificationMeta(
    'frontImagePath',
  );
  @override
  late final GeneratedColumn<String> frontImagePath = GeneratedColumn<String>(
    'front_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backTextMeta = const VerificationMeta(
    'backText',
  );
  @override
  late final GeneratedColumn<String> backText = GeneratedColumn<String>(
    'back_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backImagePathMeta = const VerificationMeta(
    'backImagePath',
  );
  @override
  late final GeneratedColumn<String> backImagePath = GeneratedColumn<String>(
    'back_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<int> presetId = GeneratedColumn<int>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES presets (id)',
    ),
  );
  static const VerificationMeta _suspendedMeta = const VerificationMeta(
    'suspended',
  );
  @override
  late final GeneratedColumn<bool> suspended = GeneratedColumn<bool>(
    'suspended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("suspended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    frontText,
    frontImagePath,
    backText,
    backImagePath,
    presetId,
    suspended,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('front_text')) {
      context.handle(
        _frontTextMeta,
        frontText.isAcceptableOrUnknown(data['front_text']!, _frontTextMeta),
      );
    }
    if (data.containsKey('front_image_path')) {
      context.handle(
        _frontImagePathMeta,
        frontImagePath.isAcceptableOrUnknown(
          data['front_image_path']!,
          _frontImagePathMeta,
        ),
      );
    }
    if (data.containsKey('back_text')) {
      context.handle(
        _backTextMeta,
        backText.isAcceptableOrUnknown(data['back_text']!, _backTextMeta),
      );
    }
    if (data.containsKey('back_image_path')) {
      context.handle(
        _backImagePathMeta,
        backImagePath.isAcceptableOrUnknown(
          data['back_image_path']!,
          _backImagePathMeta,
        ),
      );
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    if (data.containsKey('suspended')) {
      context.handle(
        _suspendedMeta,
        suspended.isAcceptableOrUnknown(data['suspended']!, _suspendedMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
      frontText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front_text'],
      ),
      frontImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front_image_path'],
      ),
      backText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back_text'],
      ),
      backImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back_image_path'],
      ),
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_id'],
      ),
      suspended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}suspended'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<int> id;
  final Value<int?> groupId;
  final Value<String?> frontText;
  final Value<String?> frontImagePath;
  final Value<String?> backText;
  final Value<String?> backImagePath;
  final Value<int?> presetId;
  final Value<bool> suspended;
  final Value<DateTime> createdAt;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.frontText = const Value.absent(),
    this.frontImagePath = const Value.absent(),
    this.backText = const Value.absent(),
    this.backImagePath = const Value.absent(),
    this.presetId = const Value.absent(),
    this.suspended = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.frontText = const Value.absent(),
    this.frontImagePath = const Value.absent(),
    this.backText = const Value.absent(),
    this.backImagePath = const Value.absent(),
    this.presetId = const Value.absent(),
    this.suspended = const Value.absent(),
    required DateTime createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<Flashcard> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? frontText,
    Expression<String>? frontImagePath,
    Expression<String>? backText,
    Expression<String>? backImagePath,
    Expression<int>? presetId,
    Expression<bool>? suspended,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (frontText != null) 'front_text': frontText,
      if (frontImagePath != null) 'front_image_path': frontImagePath,
      if (backText != null) 'back_text': backText,
      if (backImagePath != null) 'back_image_path': backImagePath,
      if (presetId != null) 'preset_id': presetId,
      if (suspended != null) 'suspended': suspended,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FlashcardsCompanion copyWith({
    Value<int>? id,
    Value<int?>? groupId,
    Value<String?>? frontText,
    Value<String?>? frontImagePath,
    Value<String?>? backText,
    Value<String?>? backImagePath,
    Value<int?>? presetId,
    Value<bool>? suspended,
    Value<DateTime>? createdAt,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      frontText: frontText ?? this.frontText,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backText: backText ?? this.backText,
      backImagePath: backImagePath ?? this.backImagePath,
      presetId: presetId ?? this.presetId,
      suspended: suspended ?? this.suspended,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (frontText.present) {
      map['front_text'] = Variable<String>(frontText.value);
    }
    if (frontImagePath.present) {
      map['front_image_path'] = Variable<String>(frontImagePath.value);
    }
    if (backText.present) {
      map['back_text'] = Variable<String>(backText.value);
    }
    if (backImagePath.present) {
      map['back_image_path'] = Variable<String>(backImagePath.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<int>(presetId.value);
    }
    if (suspended.present) {
      map['suspended'] = Variable<bool>(suspended.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('frontText: $frontText, ')
          ..write('frontImagePath: $frontImagePath, ')
          ..write('backText: $backText, ')
          ..write('backImagePath: $backImagePath, ')
          ..write('presetId: $presetId, ')
          ..write('suspended: $suspended, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CardDirectionsTable extends CardDirections
    with TableInfo<$CardDirectionsTable, CardDirection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardDirectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DirectionSense, String> sense =
      GeneratedColumn<String>(
        'sense',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DirectionSense>($CardDirectionsTable.$convertersense);
  @override
  late final GeneratedColumnWithTypeConverter<DirectionState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DirectionState>($CardDirectionsTable.$converterstate);
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notifiedAtMeta = const VerificationMeta(
    'notifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> notifiedAt = GeneratedColumn<DateTime>(
    'notified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    sense,
    state,
    step,
    dueAt,
    lastReviewedAt,
    notifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_directions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardDirection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('notified_at')) {
      context.handle(
        _notifiedAtMeta,
        notifiedAt.isAcceptableOrUnknown(data['notified_at']!, _notifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cardId, sense},
  ];
  @override
  CardDirection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardDirection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      sense: $CardDirectionsTable.$convertersense.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sense'],
        )!,
      ),
      state: $CardDirectionsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      notifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notified_at'],
      ),
    );
  }

  @override
  $CardDirectionsTable createAlias(String alias) {
    return $CardDirectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DirectionSense, String, String> $convertersense =
      const EnumNameConverter<DirectionSense>(DirectionSense.values);
  static JsonTypeConverter2<DirectionState, String, String> $converterstate =
      const EnumNameConverter<DirectionState>(DirectionState.values);
}

class CardDirectionsCompanion extends UpdateCompanion<CardDirection> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<DirectionSense> sense;
  final Value<DirectionState> state;
  final Value<int?> step;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> notifiedAt;
  const CardDirectionsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sense = const Value.absent(),
    this.state = const Value.absent(),
    this.step = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
  });
  CardDirectionsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required DirectionSense sense,
    required DirectionState state,
    this.step = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
  }) : cardId = Value(cardId),
       sense = Value(sense),
       state = Value(state);
  static Insertable<CardDirection> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? sense,
    Expression<String>? state,
    Expression<int>? step,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? notifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (sense != null) 'sense': sense,
      if (state != null) 'state': state,
      if (step != null) 'step': step,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (notifiedAt != null) 'notified_at': notifiedAt,
    });
  }

  CardDirectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<DirectionSense>? sense,
    Value<DirectionState>? state,
    Value<int?>? step,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? notifiedAt,
  }) {
    return CardDirectionsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      sense: sense ?? this.sense,
      state: state ?? this.state,
      step: step ?? this.step,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      notifiedAt: notifiedAt ?? this.notifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (sense.present) {
      map['sense'] = Variable<String>(
        $CardDirectionsTable.$convertersense.toSql(sense.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $CardDirectionsTable.$converterstate.toSql(state.value),
      );
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (notifiedAt.present) {
      map['notified_at'] = Variable<DateTime>(notifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardDirectionsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sense: $sense, ')
          ..write('state: $state, ')
          ..write('step: $step, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('notifiedAt: $notifiedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewRecordsTable extends ReviewRecords
    with TableInfo<$ReviewRecordsTable, ReviewRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directionIdMeta = const VerificationMeta(
    'directionId',
  );
  @override
  late final GeneratedColumn<int> directionId = GeneratedColumn<int>(
    'direction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_directions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewOutcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewOutcome>($ReviewRecordsTable.$converteroutcome);
  static const VerificationMeta _isBonusMeta = const VerificationMeta(
    'isBonus',
  );
  @override
  late final GeneratedColumn<bool> isBonus = GeneratedColumn<bool>(
    'is_bonus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bonus" IN (0, 1))',
    ),
  );
  static const VerificationMeta _stepBeforeMeta = const VerificationMeta(
    'stepBefore',
  );
  @override
  late final GeneratedColumn<int> stepBefore = GeneratedColumn<int>(
    'step_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepAfterMeta = const VerificationMeta(
    'stepAfter',
  );
  @override
  late final GeneratedColumn<int> stepAfter = GeneratedColumn<int>(
    'step_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewSource>($ReviewRecordsTable.$convertersource);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directionId,
    reviewedAt,
    outcome,
    isBonus,
    stepBefore,
    stepAfter,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('direction_id')) {
      context.handle(
        _directionIdMeta,
        directionId.isAcceptableOrUnknown(
          data['direction_id']!,
          _directionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directionIdMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('is_bonus')) {
      context.handle(
        _isBonusMeta,
        isBonus.isAcceptableOrUnknown(data['is_bonus']!, _isBonusMeta),
      );
    } else if (isInserting) {
      context.missing(_isBonusMeta);
    }
    if (data.containsKey('step_before')) {
      context.handle(
        _stepBeforeMeta,
        stepBefore.isAcceptableOrUnknown(data['step_before']!, _stepBeforeMeta),
      );
    }
    if (data.containsKey('step_after')) {
      context.handle(
        _stepAfterMeta,
        stepAfter.isAcceptableOrUnknown(data['step_after']!, _stepAfterMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction_id'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      outcome: $ReviewRecordsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      isBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bonus'],
      )!,
      stepBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_before'],
      ),
      stepAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_after'],
      ),
      source: $ReviewRecordsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
    );
  }

  @override
  $ReviewRecordsTable createAlias(String alias) {
    return $ReviewRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReviewOutcome, String, String> $converteroutcome =
      const EnumNameConverter<ReviewOutcome>(ReviewOutcome.values);
  static JsonTypeConverter2<ReviewSource, String, String> $convertersource =
      const EnumNameConverter<ReviewSource>(ReviewSource.values);
}

class ReviewRecordsCompanion extends UpdateCompanion<ReviewRecord> {
  final Value<int> id;
  final Value<int> directionId;
  final Value<DateTime> reviewedAt;
  final Value<ReviewOutcome> outcome;
  final Value<bool> isBonus;
  final Value<int?> stepBefore;
  final Value<int?> stepAfter;
  final Value<ReviewSource> source;
  const ReviewRecordsCompanion({
    this.id = const Value.absent(),
    this.directionId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.isBonus = const Value.absent(),
    this.stepBefore = const Value.absent(),
    this.stepAfter = const Value.absent(),
    this.source = const Value.absent(),
  });
  ReviewRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int directionId,
    required DateTime reviewedAt,
    required ReviewOutcome outcome,
    required bool isBonus,
    this.stepBefore = const Value.absent(),
    this.stepAfter = const Value.absent(),
    required ReviewSource source,
  }) : directionId = Value(directionId),
       reviewedAt = Value(reviewedAt),
       outcome = Value(outcome),
       isBonus = Value(isBonus),
       source = Value(source);
  static Insertable<ReviewRecord> custom({
    Expression<int>? id,
    Expression<int>? directionId,
    Expression<DateTime>? reviewedAt,
    Expression<String>? outcome,
    Expression<bool>? isBonus,
    Expression<int>? stepBefore,
    Expression<int>? stepAfter,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directionId != null) 'direction_id': directionId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (outcome != null) 'outcome': outcome,
      if (isBonus != null) 'is_bonus': isBonus,
      if (stepBefore != null) 'step_before': stepBefore,
      if (stepAfter != null) 'step_after': stepAfter,
      if (source != null) 'source': source,
    });
  }

  ReviewRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? directionId,
    Value<DateTime>? reviewedAt,
    Value<ReviewOutcome>? outcome,
    Value<bool>? isBonus,
    Value<int?>? stepBefore,
    Value<int?>? stepAfter,
    Value<ReviewSource>? source,
  }) {
    return ReviewRecordsCompanion(
      id: id ?? this.id,
      directionId: directionId ?? this.directionId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      outcome: outcome ?? this.outcome,
      isBonus: isBonus ?? this.isBonus,
      stepBefore: stepBefore ?? this.stepBefore,
      stepAfter: stepAfter ?? this.stepAfter,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directionId.present) {
      map['direction_id'] = Variable<int>(directionId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ReviewRecordsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (isBonus.present) {
      map['is_bonus'] = Variable<bool>(isBonus.value);
    }
    if (stepBefore.present) {
      map['step_before'] = Variable<int>(stepBefore.value);
    }
    if (stepAfter.present) {
      map['step_after'] = Variable<int>(stepAfter.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ReviewRecordsTable.$convertersource.toSql(source.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRecordsCompanion(')
          ..write('id: $id, ')
          ..write('directionId: $directionId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('outcome: $outcome, ')
          ..write('isBonus: $isBonus, ')
          ..write('stepBefore: $stepBefore, ')
          ..write('stepAfter: $stepAfter, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $ExtraRemindersTable extends ExtraReminders
    with TableInfo<$ExtraRemindersTable, ExtraReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtraRemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directionIdMeta = const VerificationMeta(
    'directionId',
  );
  @override
  late final GeneratedColumn<int> directionId = GeneratedColumn<int>(
    'direction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_directions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notifiedAtMeta = const VerificationMeta(
    'notifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> notifiedAt = GeneratedColumn<DateTime>(
    'notified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, directionId, remindAt, notifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extra_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtraReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('direction_id')) {
      context.handle(
        _directionIdMeta,
        directionId.isAcceptableOrUnknown(
          data['direction_id']!,
          _directionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directionIdMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    } else if (isInserting) {
      context.missing(_remindAtMeta);
    }
    if (data.containsKey('notified_at')) {
      context.handle(
        _notifiedAtMeta,
        notifiedAt.isAcceptableOrUnknown(data['notified_at']!, _notifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtraReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtraReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction_id'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      )!,
      notifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notified_at'],
      ),
    );
  }

  @override
  $ExtraRemindersTable createAlias(String alias) {
    return $ExtraRemindersTable(attachedDatabase, alias);
  }
}

class ExtraRemindersCompanion extends UpdateCompanion<ExtraReminder> {
  final Value<int> id;
  final Value<int> directionId;
  final Value<DateTime> remindAt;
  final Value<DateTime?> notifiedAt;
  const ExtraRemindersCompanion({
    this.id = const Value.absent(),
    this.directionId = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
  });
  ExtraRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int directionId,
    required DateTime remindAt,
    this.notifiedAt = const Value.absent(),
  }) : directionId = Value(directionId),
       remindAt = Value(remindAt);
  static Insertable<ExtraReminder> custom({
    Expression<int>? id,
    Expression<int>? directionId,
    Expression<DateTime>? remindAt,
    Expression<DateTime>? notifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directionId != null) 'direction_id': directionId,
      if (remindAt != null) 'remind_at': remindAt,
      if (notifiedAt != null) 'notified_at': notifiedAt,
    });
  }

  ExtraRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? directionId,
    Value<DateTime>? remindAt,
    Value<DateTime?>? notifiedAt,
  }) {
    return ExtraRemindersCompanion(
      id: id ?? this.id,
      directionId: directionId ?? this.directionId,
      remindAt: remindAt ?? this.remindAt,
      notifiedAt: notifiedAt ?? this.notifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directionId.present) {
      map['direction_id'] = Variable<int>(directionId.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (notifiedAt.present) {
      map['notified_at'] = Variable<DateTime>(notifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtraRemindersCompanion(')
          ..write('id: $id, ')
          ..write('directionId: $directionId, ')
          ..write('remindAt: $remindAt, ')
          ..write('notifiedAt: $notifiedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$RemanenceDatabase extends GeneratedDatabase {
  _$RemanenceDatabase(QueryExecutor e) : super(e);
  $RemanenceDatabaseManager get managers => $RemanenceDatabaseManager(this);
  late final $PresetsTable presets = $PresetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CardGroupsTable cardGroups = $CardGroupsTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $CardDirectionsTable cardDirections = $CardDirectionsTable(this);
  late final $ReviewRecordsTable reviewRecords = $ReviewRecordsTable(this);
  late final $ExtraRemindersTable extraReminders = $ExtraRemindersTable(this);
  late final Index cardDirectionsDueAt = Index(
    'card_directions_due_at',
    'CREATE INDEX card_directions_due_at ON card_directions (due_at)',
  );
  late final Index reviewRecordsReviewedAt = Index(
    'review_records_reviewed_at',
    'CREATE INDEX review_records_reviewed_at ON review_records (reviewed_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    presets,
    appSettings,
    cardGroups,
    flashcards,
    cardDirections,
    reviewRecords,
    extraReminders,
    cardDirectionsDueAt,
    reviewRecordsReviewedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_directions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card_directions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card_directions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('extra_reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PresetsTableCreateCompanionBuilder = PresetsCompanion Function({
  Value<int> id,
  required String name,
  Value<BuiltInPresetKey?> builtInKey,
  required SchedulingEngineKind engine,
  required List<PresetInterval> intervals,
  required FailureBehavior failureBehavior,
  required SequenceEndBehavior endBehavior,
  required bool typedAnswer,
  required ScheduleKind scheduleKind,
  required ClockTime fixedTime,
  required ClockTime rangeStart,
  required ClockTime rangeEnd,
  required NotificationMode notificationMode,
  required GroupedReminderAction groupedAction,
  required double targetRetention,
});
typedef $$PresetsTableUpdateCompanionBuilder = PresetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<BuiltInPresetKey?> builtInKey,
  Value<SchedulingEngineKind> engine,
  Value<List<PresetInterval>> intervals,
  Value<FailureBehavior> failureBehavior,
  Value<SequenceEndBehavior> endBehavior,
  Value<bool> typedAnswer,
  Value<ScheduleKind> scheduleKind,
  Value<ClockTime> fixedTime,
  Value<ClockTime> rangeStart,
  Value<ClockTime> rangeEnd,
  Value<NotificationMode> notificationMode,
  Value<GroupedReminderAction> groupedAction,
  Value<double> targetRetention,
});

final class $$PresetsTableReferences
    extends BaseReferences<_$RemanenceDatabase, $PresetsTable, Preset> {
  $$PresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AppSettingsTable, List<AppSettingsRow>>
  _appSettingsRefsTable(_$RemanenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.appSettings,
        aliasName: 'presets__id__app_settings__global_preset_id',
      );

  $$AppSettingsTableProcessedTableManager get appSettingsRefs {
    final manager = $$AppSettingsTableTableManager(
      $_db,
      $_db.appSettings,
    ).filter((f) => f.globalPresetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardGroupsTable, List<CardGroup>>
  _cardGroupsRefsTable(_$RemanenceDatabase db) => MultiTypedResultKey.fromTable(
    db.cardGroups,
    aliasName: 'presets__id__card_groups__preset_id',
  );

  $$CardGroupsTableProcessedTableManager get cardGroupsRefs {
    final manager = $$CardGroupsTableTableManager(
      $_db,
      $_db.cardGroups,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$RemanenceDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: 'presets__id__flashcards__preset_id',
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PresetsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $PresetsTable> {
  $$PresetsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<BuiltInPresetKey?, BuiltInPresetKey, String>
  get builtInKey => $composableBuilder(
    column: $table.builtInKey,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SchedulingEngineKind,
    SchedulingEngineKind,
    String
  >
  get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<PresetInterval>,
    List<PresetInterval>,
    String
  >
  get intervals => $composableBuilder(
    column: $table.intervals,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<FailureBehavior, FailureBehavior, String>
  get failureBehavior => $composableBuilder(
    column: $table.failureBehavior,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SequenceEndBehavior,
    SequenceEndBehavior,
    String
  >
  get endBehavior => $composableBuilder(
    column: $table.endBehavior,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleKind, ScheduleKind, String>
  get scheduleKind => $composableBuilder(
    column: $table.scheduleKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ClockTime, ClockTime, int> get fixedTime =>
      $composableBuilder(
        column: $table.fixedTime,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ClockTime, ClockTime, int> get rangeStart =>
      $composableBuilder(
        column: $table.rangeStart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ClockTime, ClockTime, int> get rangeEnd =>
      $composableBuilder(
        column: $table.rangeEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<NotificationMode, NotificationMode, String>
  get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    GroupedReminderAction,
    GroupedReminderAction,
    String
  >
  get groupedAction => $composableBuilder(
    column: $table.groupedAction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> appSettingsRefs(
    Expression<bool> Function($$AppSettingsTableFilterComposer f) f,
  ) {
    final $$AppSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appSettings,
      getReferencedColumn: (t) => t.globalPresetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSettingsTableFilterComposer(
            $db: $db,
            $table: $db.appSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardGroupsRefs(
    Expression<bool> Function($$CardGroupsTableFilterComposer f) f,
  ) {
    final $$CardGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardGroups,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardGroupsTableFilterComposer(
            $db: $db,
            $table: $db.cardGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PresetsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $PresetsTable> {
  $$PresetsTableOrderingComposer({
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

  ColumnOrderings<String> get builtInKey => $composableBuilder(
    column: $table.builtInKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervals => $composableBuilder(
    column: $table.intervals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureBehavior => $composableBuilder(
    column: $table.failureBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endBehavior => $composableBuilder(
    column: $table.endBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleKind => $composableBuilder(
    column: $table.scheduleKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fixedTime => $composableBuilder(
    column: $table.fixedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupedAction => $composableBuilder(
    column: $table.groupedAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $PresetsTable> {
  $$PresetsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<BuiltInPresetKey?, String> get builtInKey =>
      $composableBuilder(
        column: $table.builtInKey,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SchedulingEngineKind, String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<PresetInterval>, String>
  get intervals =>
      $composableBuilder(column: $table.intervals, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FailureBehavior, String>
  get failureBehavior => $composableBuilder(
    column: $table.failureBehavior,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SequenceEndBehavior, String>
  get endBehavior => $composableBuilder(
    column: $table.endBehavior,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScheduleKind, String> get scheduleKind =>
      $composableBuilder(
        column: $table.scheduleKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ClockTime, int> get fixedTime =>
      $composableBuilder(column: $table.fixedTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ClockTime, int> get rangeStart =>
      $composableBuilder(
        column: $table.rangeStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ClockTime, int> get rangeEnd =>
      $composableBuilder(column: $table.rangeEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationMode, String>
  get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GroupedReminderAction, String>
  get groupedAction => $composableBuilder(
    column: $table.groupedAction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => column,
  );

  Expression<T> appSettingsRefs<T extends Object>(
    Expression<T> Function($$AppSettingsTableAnnotationComposer a) f,
  ) {
    final $$AppSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appSettings,
      getReferencedColumn: (t) => t.globalPresetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.appSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardGroupsRefs<T extends Object>(
    Expression<T> Function($$CardGroupsTableAnnotationComposer a) f,
  ) {
    final $$CardGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardGroups,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $PresetsTable,
          Preset,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (Preset, $$PresetsTableReferences),
          Preset,
          PrefetchHooks Function({
            bool appSettingsRefs,
            bool cardGroupsRefs,
            bool flashcardsRefs,
          })
        > {
  $$PresetsTableTableManager(_$RemanenceDatabase db, $PresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<BuiltInPresetKey?> builtInKey = const Value.absent(),
                Value<SchedulingEngineKind> engine = const Value.absent(),
                Value<List<PresetInterval>> intervals = const Value.absent(),
                Value<FailureBehavior> failureBehavior = const Value.absent(),
                Value<SequenceEndBehavior> endBehavior = const Value.absent(),
                Value<bool> typedAnswer = const Value.absent(),
                Value<ScheduleKind> scheduleKind = const Value.absent(),
                Value<ClockTime> fixedTime = const Value.absent(),
                Value<ClockTime> rangeStart = const Value.absent(),
                Value<ClockTime> rangeEnd = const Value.absent(),
                Value<NotificationMode> notificationMode = const Value.absent(),
                Value<GroupedReminderAction> groupedAction =
                    const Value.absent(),
                Value<double> targetRetention = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                name: name,
                builtInKey: builtInKey,
                engine: engine,
                intervals: intervals,
                failureBehavior: failureBehavior,
                endBehavior: endBehavior,
                typedAnswer: typedAnswer,
                scheduleKind: scheduleKind,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                notificationMode: notificationMode,
                groupedAction: groupedAction,
                targetRetention: targetRetention,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<BuiltInPresetKey?> builtInKey = const Value.absent(),
                required SchedulingEngineKind engine,
                required List<PresetInterval> intervals,
                required FailureBehavior failureBehavior,
                required SequenceEndBehavior endBehavior,
                required bool typedAnswer,
                required ScheduleKind scheduleKind,
                required ClockTime fixedTime,
                required ClockTime rangeStart,
                required ClockTime rangeEnd,
                required NotificationMode notificationMode,
                required GroupedReminderAction groupedAction,
                required double targetRetention,
              }) => PresetsCompanion.insert(
                id: id,
                name: name,
                builtInKey: builtInKey,
                engine: engine,
                intervals: intervals,
                failureBehavior: failureBehavior,
                endBehavior: endBehavior,
                typedAnswer: typedAnswer,
                scheduleKind: scheduleKind,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                notificationMode: notificationMode,
                groupedAction: groupedAction,
                targetRetention: targetRetention,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PresetsTable, Preset>(table),
                  $$PresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                appSettingsRefs = false,
                cardGroupsRefs = false,
                flashcardsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (appSettingsRefs) db.appSettings,
                    if (cardGroupsRefs) db.cardGroups,
                    if (flashcardsRefs) db.flashcards,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (appSettingsRefs)
                        await $_getPrefetchedDataByColumns<
                          Preset,
                          $PresetsTable,
                          AppSettingsRow,
                          $AppSettingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PresetsTableReferences
                              ._appSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).appSettingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'global_preset_id',
                          typedResults: items,
                        ),
                      if (cardGroupsRefs)
                        await $_getPrefetchedDataByColumns<
                          Preset,
                          $PresetsTable,
                          CardGroup,
                          $CardGroupsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PresetsTableReferences
                              ._cardGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardGroupsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'preset_id',
                          typedResults: items,
                        ),
                      if (flashcardsRefs)
                        await $_getPrefetchedDataByColumns<
                          Preset,
                          $PresetsTable,
                          Flashcard,
                          $FlashcardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PresetsTableReferences
                              ._flashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).flashcardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'preset_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $PresetsTable,
      Preset,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (Preset, $$PresetsTableReferences),
      Preset,
      PrefetchHooks Function({
        bool appSettingsRefs,
        bool cardGroupsRefs,
        bool flashcardsRefs,
      })
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({Value<int> id, required int globalPresetId});
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({Value<int> id, Value<int> globalPresetId});

final class $$AppSettingsTableReferences
    extends
        BaseReferences<_$RemanenceDatabase, $AppSettingsTable, AppSettingsRow> {
  $$AppSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _globalPresetIdTable(_$RemanenceDatabase db) =>
      db.presets.createAlias('app_settings__global_preset_id__presets__id');

  $$PresetsTableProcessedTableManager get globalPresetId {
    final $_column = $_itemColumn<int>('global_preset_id')!;

    final manager = $$PresetsTableTableManager(
      $_db,
      $_db.presets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_globalPresetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppSettingsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  $$PresetsTableFilterComposer get globalPresetId {
    final $$PresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.globalPresetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableFilterComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  $$PresetsTableOrderingComposer get globalPresetId {
    final $$PresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.globalPresetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableOrderingComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$PresetsTableAnnotationComposer get globalPresetId {
    final $$PresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.globalPresetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (AppSettingsRow, $$AppSettingsTableReferences),
          AppSettingsRow,
          PrefetchHooks Function({bool globalPresetId})
        > {
  $$AppSettingsTableTableManager(
    _$RemanenceDatabase db,
    $AppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> globalPresetId = const Value.absent(),
          }) => AppSettingsCompanion(id: id, globalPresetId: globalPresetId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int globalPresetId,
              }) => AppSettingsCompanion.insert(
                id: id,
                globalPresetId: globalPresetId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                  $$AppSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({globalPresetId = false}) {
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
                    if (globalPresetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.globalPresetId,
                        referencedTable: $$AppSettingsTableReferences
                            ._globalPresetIdTable(db),
                        referencedColumn: $$AppSettingsTableReferences
                            ._globalPresetIdTable(db)
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (AppSettingsRow, $$AppSettingsTableReferences),
      AppSettingsRow,
      PrefetchHooks Function({bool globalPresetId})
    >;
typedef $$CardGroupsTableCreateCompanionBuilder = CardGroupsCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> presetId,
  required DateTime createdAt,
});
typedef $$CardGroupsTableUpdateCompanionBuilder = CardGroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> presetId,
  Value<DateTime> createdAt,
});

final class $$CardGroupsTableReferences
    extends BaseReferences<_$RemanenceDatabase, $CardGroupsTable, CardGroup> {
  $$CardGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _presetIdTable(_$RemanenceDatabase db) =>
      db.presets.createAlias('card_groups__preset_id__presets__id');

  $$PresetsTableProcessedTableManager? get presetId {
    final $_column = $_itemColumn<int>('preset_id');
    if ($_column == null) return null;
    final manager = $$PresetsTableTableManager(
      $_db,
      $_db.presets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$RemanenceDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: 'card_groups__id__flashcards__group_id',
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardGroupsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $CardGroupsTable> {
  $$CardGroupsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PresetsTableFilterComposer get presetId {
    final $$PresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableFilterComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardGroupsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $CardGroupsTable> {
  $$CardGroupsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PresetsTableOrderingComposer get presetId {
    final $$PresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableOrderingComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardGroupsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $CardGroupsTable> {
  $$CardGroupsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PresetsTableAnnotationComposer get presetId {
    final $$PresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardGroupsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $CardGroupsTable,
          CardGroup,
          $$CardGroupsTableFilterComposer,
          $$CardGroupsTableOrderingComposer,
          $$CardGroupsTableAnnotationComposer,
          $$CardGroupsTableCreateCompanionBuilder,
          $$CardGroupsTableUpdateCompanionBuilder,
          (CardGroup, $$CardGroupsTableReferences),
          CardGroup,
          PrefetchHooks Function({bool presetId, bool flashcardsRefs})
        > {
  $$CardGroupsTableTableManager(_$RemanenceDatabase db, $CardGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> presetId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CardGroupsCompanion(
                id: id,
                name: name,
                presetId: presetId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> presetId = const Value.absent(),
                required DateTime createdAt,
              }) => CardGroupsCompanion.insert(
                id: id,
                name: name,
                presetId: presetId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardGroupsTable, CardGroup>(table),
                  $$CardGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({presetId = false, flashcardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (flashcardsRefs) db.flashcards],
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
                    if (presetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.presetId,
                        referencedTable: $$CardGroupsTableReferences
                            ._presetIdTable(db),
                        referencedColumn: $$CardGroupsTableReferences
                            ._presetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedDataByColumns<
                      CardGroup,
                      $CardGroupsTable,
                      Flashcard,
                      $FlashcardsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CardGroupsTableReferences
                          ._flashcardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).flashcardsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'group_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $CardGroupsTable,
      CardGroup,
      $$CardGroupsTableFilterComposer,
      $$CardGroupsTableOrderingComposer,
      $$CardGroupsTableAnnotationComposer,
      $$CardGroupsTableCreateCompanionBuilder,
      $$CardGroupsTableUpdateCompanionBuilder,
      (CardGroup, $$CardGroupsTableReferences),
      CardGroup,
      PrefetchHooks Function({bool presetId, bool flashcardsRefs})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<int?> groupId,
  Value<String?> frontText,
  Value<String?> frontImagePath,
  Value<String?> backText,
  Value<String?> backImagePath,
  Value<int?> presetId,
  Value<bool> suspended,
  required DateTime createdAt,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<int?> groupId,
  Value<String?> frontText,
  Value<String?> frontImagePath,
  Value<String?> backText,
  Value<String?> backImagePath,
  Value<int?> presetId,
  Value<bool> suspended,
  Value<DateTime> createdAt,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$RemanenceDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardGroupsTable _groupIdTable(_$RemanenceDatabase db) =>
      db.cardGroups.createAlias('flashcards__group_id__card_groups__id');

  $$CardGroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$CardGroupsTableTableManager(
      $_db,
      $_db.cardGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PresetsTable _presetIdTable(_$RemanenceDatabase db) =>
      db.presets.createAlias('flashcards__preset_id__presets__id');

  $$PresetsTableProcessedTableManager? get presetId {
    final $_column = $_itemColumn<int>('preset_id');
    if ($_column == null) return null;
    final manager = $$PresetsTableTableManager(
      $_db,
      $_db.presets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardDirectionsTable, List<CardDirection>>
  _cardDirectionsRefsTable(_$RemanenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cardDirections,
        aliasName: 'flashcards__id__card_directions__card_id',
      );

  $$CardDirectionsTableProcessedTableManager get cardDirectionsRefs {
    final manager = $$CardDirectionsTableTableManager(
      $_db,
      $_db.cardDirections,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardDirectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
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

  ColumnFilters<String> get frontText => $composableBuilder(
    column: $table.frontText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frontImagePath => $composableBuilder(
    column: $table.frontImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backText => $composableBuilder(
    column: $table.backText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backImagePath => $composableBuilder(
    column: $table.backImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get suspended => $composableBuilder(
    column: $table.suspended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardGroupsTableFilterComposer get groupId {
    final $$CardGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.cardGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardGroupsTableFilterComposer(
            $db: $db,
            $table: $db.cardGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PresetsTableFilterComposer get presetId {
    final $$PresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableFilterComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardDirectionsRefs(
    Expression<bool> Function($$CardDirectionsTableFilterComposer f) f,
  ) {
    final $$CardDirectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
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

  ColumnOrderings<String> get frontText => $composableBuilder(
    column: $table.frontText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frontImagePath => $composableBuilder(
    column: $table.frontImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backText => $composableBuilder(
    column: $table.backText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backImagePath => $composableBuilder(
    column: $table.backImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get suspended => $composableBuilder(
    column: $table.suspended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardGroupsTableOrderingComposer get groupId {
    final $$CardGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.cardGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.cardGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PresetsTableOrderingComposer get presetId {
    final $$PresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableOrderingComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frontText =>
      $composableBuilder(column: $table.frontText, builder: (column) => column);

  GeneratedColumn<String> get frontImagePath => $composableBuilder(
    column: $table.frontImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backText =>
      $composableBuilder(column: $table.backText, builder: (column) => column);

  GeneratedColumn<String> get backImagePath => $composableBuilder(
    column: $table.backImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get suspended =>
      $composableBuilder(column: $table.suspended, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CardGroupsTableAnnotationComposer get groupId {
    final $$CardGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.cardGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PresetsTableAnnotationComposer get presetId {
    final $$PresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardDirectionsRefs<T extends Object>(
    Expression<T> Function($$CardDirectionsTableAnnotationComposer a) f,
  ) {
    final $$CardDirectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $FlashcardsTable,
          Flashcard,
          $$FlashcardsTableFilterComposer,
          $$FlashcardsTableOrderingComposer,
          $$FlashcardsTableAnnotationComposer,
          $$FlashcardsTableCreateCompanionBuilder,
          $$FlashcardsTableUpdateCompanionBuilder,
          (Flashcard, $$FlashcardsTableReferences),
          Flashcard,
          PrefetchHooks Function({
            bool groupId,
            bool presetId,
            bool cardDirectionsRefs,
          })
        > {
  $$FlashcardsTableTableManager(_$RemanenceDatabase db, $FlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
                Value<String?> frontText = const Value.absent(),
                Value<String?> frontImagePath = const Value.absent(),
                Value<String?> backText = const Value.absent(),
                Value<String?> backImagePath = const Value.absent(),
                Value<int?> presetId = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                groupId: groupId,
                frontText: frontText,
                frontImagePath: frontImagePath,
                backText: backText,
                backImagePath: backImagePath,
                presetId: presetId,
                suspended: suspended,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
                Value<String?> frontText = const Value.absent(),
                Value<String?> frontImagePath = const Value.absent(),
                Value<String?> backText = const Value.absent(),
                Value<String?> backImagePath = const Value.absent(),
                Value<int?> presetId = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                required DateTime createdAt,
              }) => FlashcardsCompanion.insert(
                id: id,
                groupId: groupId,
                frontText: frontText,
                frontImagePath: frontImagePath,
                backText: backText,
                backImagePath: backImagePath,
                presetId: presetId,
                suspended: suspended,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlashcardsTable, Flashcard>(table),
                  $$FlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                presetId = false,
                cardDirectionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardDirectionsRefs) db.cardDirections,
                  ],
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
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$FlashcardsTableReferences
                                ._groupIdTable(db),
                            referencedColumn: $$FlashcardsTableReferences
                                ._groupIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (presetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.presetId,
                            referencedTable: $$FlashcardsTableReferences
                                ._presetIdTable(db),
                            referencedColumn: $$FlashcardsTableReferences
                                ._presetIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardDirectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Flashcard,
                          $FlashcardsTable,
                          CardDirection,
                          $CardDirectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._cardDirectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardDirectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'card_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $FlashcardsTable,
      Flashcard,
      $$FlashcardsTableFilterComposer,
      $$FlashcardsTableOrderingComposer,
      $$FlashcardsTableAnnotationComposer,
      $$FlashcardsTableCreateCompanionBuilder,
      $$FlashcardsTableUpdateCompanionBuilder,
      (Flashcard, $$FlashcardsTableReferences),
      Flashcard,
      PrefetchHooks Function({
        bool groupId,
        bool presetId,
        bool cardDirectionsRefs,
      })
    >;
typedef $$CardDirectionsTableCreateCompanionBuilder =
    CardDirectionsCompanion Function({
      Value<int> id,
      required int cardId,
      required DirectionSense sense,
      required DirectionState state,
      Value<int?> step,
      Value<DateTime?> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> notifiedAt,
    });
typedef $$CardDirectionsTableUpdateCompanionBuilder =
    CardDirectionsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<DirectionSense> sense,
      Value<DirectionState> state,
      Value<int?> step,
      Value<DateTime?> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> notifiedAt,
    });

final class $$CardDirectionsTableReferences
    extends
        BaseReferences<
          _$RemanenceDatabase,
          $CardDirectionsTable,
          CardDirection
        > {
  $$CardDirectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlashcardsTable _cardIdTable(_$RemanenceDatabase db) =>
      db.flashcards.createAlias('card_directions__card_id__flashcards__id');

  $$FlashcardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewRecordsTable, List<ReviewRecord>>
  _reviewRecordsRefsTable(_$RemanenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reviewRecords,
        aliasName: 'card_directions__id__review_records__direction_id',
      );

  $$ReviewRecordsTableProcessedTableManager get reviewRecordsRefs {
    final manager = $$ReviewRecordsTableTableManager(
      $_db,
      $_db.reviewRecords,
    ).filter((f) => f.directionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExtraRemindersTable, List<ExtraReminder>>
  _extraRemindersRefsTable(_$RemanenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.extraReminders,
        aliasName: 'card_directions__id__extra_reminders__direction_id',
      );

  $$ExtraRemindersTableProcessedTableManager get extraRemindersRefs {
    final manager = $$ExtraRemindersTableTableManager(
      $_db,
      $_db.extraReminders,
    ).filter((f) => f.directionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_extraRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardDirectionsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $CardDirectionsTable> {
  $$CardDirectionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DirectionSense, DirectionSense, String>
  get sense => $composableBuilder(
    column: $table.sense,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DirectionState, DirectionState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FlashcardsTableFilterComposer get cardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewRecordsRefs(
    Expression<bool> Function($$ReviewRecordsTableFilterComposer f) f,
  ) {
    final $$ReviewRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.directionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableFilterComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> extraRemindersRefs(
    Expression<bool> Function($$ExtraRemindersTableFilterComposer f) f,
  ) {
    final $$ExtraRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.extraReminders,
      getReferencedColumn: (t) => t.directionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtraRemindersTableFilterComposer(
            $db: $db,
            $table: $db.extraReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardDirectionsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $CardDirectionsTable> {
  $$CardDirectionsTableOrderingComposer({
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

  ColumnOrderings<String> get sense => $composableBuilder(
    column: $table.sense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlashcardsTableOrderingComposer get cardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardDirectionsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $CardDirectionsTable> {
  $$CardDirectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DirectionSense, String> get sense =>
      $composableBuilder(column: $table.sense, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DirectionState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => column,
  );

  $$FlashcardsTableAnnotationComposer get cardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewRecordsRefs<T extends Object>(
    Expression<T> Function($$ReviewRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.directionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> extraRemindersRefs<T extends Object>(
    Expression<T> Function($$ExtraRemindersTableAnnotationComposer a) f,
  ) {
    final $$ExtraRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.extraReminders,
      getReferencedColumn: (t) => t.directionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtraRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.extraReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardDirectionsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $CardDirectionsTable,
          CardDirection,
          $$CardDirectionsTableFilterComposer,
          $$CardDirectionsTableOrderingComposer,
          $$CardDirectionsTableAnnotationComposer,
          $$CardDirectionsTableCreateCompanionBuilder,
          $$CardDirectionsTableUpdateCompanionBuilder,
          (CardDirection, $$CardDirectionsTableReferences),
          CardDirection,
          PrefetchHooks Function({
            bool cardId,
            bool reviewRecordsRefs,
            bool extraRemindersRefs,
          })
        > {
  $$CardDirectionsTableTableManager(
    _$RemanenceDatabase db,
    $CardDirectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardDirectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardDirectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardDirectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<DirectionSense> sense = const Value.absent(),
                Value<DirectionState> state = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => CardDirectionsCompanion(
                id: id,
                cardId: cardId,
                sense: sense,
                state: state,
                step: step,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                notifiedAt: notifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required DirectionSense sense,
                required DirectionState state,
                Value<int?> step = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => CardDirectionsCompanion.insert(
                id: id,
                cardId: cardId,
                sense: sense,
                state: state,
                step: step,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                notifiedAt: notifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardDirectionsTable, CardDirection>(table),
                  $$CardDirectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cardId = false,
                reviewRecordsRefs = false,
                extraRemindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewRecordsRefs) db.reviewRecords,
                    if (extraRemindersRefs) db.extraReminders,
                  ],
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
                        if (cardId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cardId,
                            referencedTable: $$CardDirectionsTableReferences
                                ._cardIdTable(db),
                            referencedColumn: $$CardDirectionsTableReferences
                                ._cardIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          CardDirection,
                          $CardDirectionsTable,
                          ReviewRecord,
                          $ReviewRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CardDirectionsTableReferences
                              ._reviewRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDirectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'direction_id',
                          typedResults: items,
                        ),
                      if (extraRemindersRefs)
                        await $_getPrefetchedDataByColumns<
                          CardDirection,
                          $CardDirectionsTable,
                          ExtraReminder,
                          $ExtraRemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$CardDirectionsTableReferences
                              ._extraRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDirectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).extraRemindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'direction_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardDirectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $CardDirectionsTable,
      CardDirection,
      $$CardDirectionsTableFilterComposer,
      $$CardDirectionsTableOrderingComposer,
      $$CardDirectionsTableAnnotationComposer,
      $$CardDirectionsTableCreateCompanionBuilder,
      $$CardDirectionsTableUpdateCompanionBuilder,
      (CardDirection, $$CardDirectionsTableReferences),
      CardDirection,
      PrefetchHooks Function({
        bool cardId,
        bool reviewRecordsRefs,
        bool extraRemindersRefs,
      })
    >;
typedef $$ReviewRecordsTableCreateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      required int directionId,
      required DateTime reviewedAt,
      required ReviewOutcome outcome,
      required bool isBonus,
      Value<int?> stepBefore,
      Value<int?> stepAfter,
      required ReviewSource source,
    });
typedef $$ReviewRecordsTableUpdateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      Value<int> directionId,
      Value<DateTime> reviewedAt,
      Value<ReviewOutcome> outcome,
      Value<bool> isBonus,
      Value<int?> stepBefore,
      Value<int?> stepAfter,
      Value<ReviewSource> source,
    });

final class $$ReviewRecordsTableReferences
    extends
        BaseReferences<_$RemanenceDatabase, $ReviewRecordsTable, ReviewRecord> {
  $$ReviewRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardDirectionsTable _directionIdTable(_$RemanenceDatabase db) => db
      .cardDirections
      .createAlias('review_records__direction_id__card_directions__id');

  $$CardDirectionsTableProcessedTableManager get directionId {
    final $_column = $_itemColumn<int>('direction_id')!;

    final manager = $$CardDirectionsTableTableManager(
      $_db,
      $_db.cardDirections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewRecordsTableFilterComposer
    extends Composer<_$RemanenceDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewOutcome, ReviewOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isBonus => $composableBuilder(
    column: $table.isBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepBefore => $composableBuilder(
    column: $table.stepBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepAfter => $composableBuilder(
    column: $table.stepAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewSource, ReviewSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$CardDirectionsTableFilterComposer get directionId {
    final $$CardDirectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBonus => $composableBuilder(
    column: $table.isBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepBefore => $composableBuilder(
    column: $table.stepBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepAfter => $composableBuilder(
    column: $table.stepAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardDirectionsTableOrderingComposer get directionId {
    final $$CardDirectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReviewOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get isBonus =>
      $composableBuilder(column: $table.isBonus, builder: (column) => column);

  GeneratedColumn<int> get stepBefore => $composableBuilder(
    column: $table.stepBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stepAfter =>
      $composableBuilder(column: $table.stepAfter, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReviewSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$CardDirectionsTableAnnotationComposer get directionId {
    final $$CardDirectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $ReviewRecordsTable,
          ReviewRecord,
          $$ReviewRecordsTableFilterComposer,
          $$ReviewRecordsTableOrderingComposer,
          $$ReviewRecordsTableAnnotationComposer,
          $$ReviewRecordsTableCreateCompanionBuilder,
          $$ReviewRecordsTableUpdateCompanionBuilder,
          (ReviewRecord, $$ReviewRecordsTableReferences),
          ReviewRecord,
          PrefetchHooks Function({bool directionId})
        > {
  $$ReviewRecordsTableTableManager(
    _$RemanenceDatabase db,
    $ReviewRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directionId = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<ReviewOutcome> outcome = const Value.absent(),
                Value<bool> isBonus = const Value.absent(),
                Value<int?> stepBefore = const Value.absent(),
                Value<int?> stepAfter = const Value.absent(),
                Value<ReviewSource> source = const Value.absent(),
              }) => ReviewRecordsCompanion(
                id: id,
                directionId: directionId,
                reviewedAt: reviewedAt,
                outcome: outcome,
                isBonus: isBonus,
                stepBefore: stepBefore,
                stepAfter: stepAfter,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directionId,
                required DateTime reviewedAt,
                required ReviewOutcome outcome,
                required bool isBonus,
                Value<int?> stepBefore = const Value.absent(),
                Value<int?> stepAfter = const Value.absent(),
                required ReviewSource source,
              }) => ReviewRecordsCompanion.insert(
                id: id,
                directionId: directionId,
                reviewedAt: reviewedAt,
                outcome: outcome,
                isBonus: isBonus,
                stepBefore: stepBefore,
                stepAfter: stepAfter,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewRecordsTable, ReviewRecord>(table),
                  $$ReviewRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directionId = false}) {
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
                    if (directionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.directionId,
                        referencedTable: $$ReviewRecordsTableReferences
                            ._directionIdTable(db),
                        referencedColumn: $$ReviewRecordsTableReferences
                            ._directionIdTable(db)
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

typedef $$ReviewRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $ReviewRecordsTable,
      ReviewRecord,
      $$ReviewRecordsTableFilterComposer,
      $$ReviewRecordsTableOrderingComposer,
      $$ReviewRecordsTableAnnotationComposer,
      $$ReviewRecordsTableCreateCompanionBuilder,
      $$ReviewRecordsTableUpdateCompanionBuilder,
      (ReviewRecord, $$ReviewRecordsTableReferences),
      ReviewRecord,
      PrefetchHooks Function({bool directionId})
    >;
typedef $$ExtraRemindersTableCreateCompanionBuilder =
    ExtraRemindersCompanion Function({
      Value<int> id,
      required int directionId,
      required DateTime remindAt,
      Value<DateTime?> notifiedAt,
    });
typedef $$ExtraRemindersTableUpdateCompanionBuilder =
    ExtraRemindersCompanion Function({
      Value<int> id,
      Value<int> directionId,
      Value<DateTime> remindAt,
      Value<DateTime?> notifiedAt,
    });

final class $$ExtraRemindersTableReferences
    extends
        BaseReferences<
          _$RemanenceDatabase,
          $ExtraRemindersTable,
          ExtraReminder
        > {
  $$ExtraRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardDirectionsTable _directionIdTable(_$RemanenceDatabase db) => db
      .cardDirections
      .createAlias('extra_reminders__direction_id__card_directions__id');

  $$CardDirectionsTableProcessedTableManager get directionId {
    final $_column = $_itemColumn<int>('direction_id')!;

    final manager = $$CardDirectionsTableTableManager(
      $_db,
      $_db.cardDirections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExtraRemindersTableFilterComposer
    extends Composer<_$RemanenceDatabase, $ExtraRemindersTable> {
  $$ExtraRemindersTableFilterComposer({
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

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardDirectionsTableFilterComposer get directionId {
    final $$CardDirectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtraRemindersTableOrderingComposer
    extends Composer<_$RemanenceDatabase, $ExtraRemindersTable> {
  $$ExtraRemindersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardDirectionsTableOrderingComposer get directionId {
    final $$CardDirectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtraRemindersTableAnnotationComposer
    extends Composer<_$RemanenceDatabase, $ExtraRemindersTable> {
  $$ExtraRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<DateTime> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => column,
  );

  $$CardDirectionsTableAnnotationComposer get directionId {
    final $$CardDirectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directionId,
      referencedTable: $db.cardDirections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDirectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtraRemindersTableTableManager
    extends
        RootTableManager<
          _$RemanenceDatabase,
          $ExtraRemindersTable,
          ExtraReminder,
          $$ExtraRemindersTableFilterComposer,
          $$ExtraRemindersTableOrderingComposer,
          $$ExtraRemindersTableAnnotationComposer,
          $$ExtraRemindersTableCreateCompanionBuilder,
          $$ExtraRemindersTableUpdateCompanionBuilder,
          (ExtraReminder, $$ExtraRemindersTableReferences),
          ExtraReminder,
          PrefetchHooks Function({bool directionId})
        > {
  $$ExtraRemindersTableTableManager(
    _$RemanenceDatabase db,
    $ExtraRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtraRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtraRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtraRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directionId = const Value.absent(),
                Value<DateTime> remindAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => ExtraRemindersCompanion(
                id: id,
                directionId: directionId,
                remindAt: remindAt,
                notifiedAt: notifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directionId,
                required DateTime remindAt,
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => ExtraRemindersCompanion.insert(
                id: id,
                directionId: directionId,
                remindAt: remindAt,
                notifiedAt: notifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtraRemindersTable, ExtraReminder>(table),
                  $$ExtraRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directionId = false}) {
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
                    if (directionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.directionId,
                        referencedTable: $$ExtraRemindersTableReferences
                            ._directionIdTable(db),
                        referencedColumn: $$ExtraRemindersTableReferences
                            ._directionIdTable(db)
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

typedef $$ExtraRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$RemanenceDatabase,
      $ExtraRemindersTable,
      ExtraReminder,
      $$ExtraRemindersTableFilterComposer,
      $$ExtraRemindersTableOrderingComposer,
      $$ExtraRemindersTableAnnotationComposer,
      $$ExtraRemindersTableCreateCompanionBuilder,
      $$ExtraRemindersTableUpdateCompanionBuilder,
      (ExtraReminder, $$ExtraRemindersTableReferences),
      ExtraReminder,
      PrefetchHooks Function({bool directionId})
    >;

class $RemanenceDatabaseManager {
  final _$RemanenceDatabase _db;
  $RemanenceDatabaseManager(this._db);
  $$PresetsTableTableManager get presets =>
      $$PresetsTableTableManager(_db, _db.presets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CardGroupsTableTableManager get cardGroups =>
      $$CardGroupsTableTableManager(_db, _db.cardGroups);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$CardDirectionsTableTableManager get cardDirections =>
      $$CardDirectionsTableTableManager(_db, _db.cardDirections);
  $$ReviewRecordsTableTableManager get reviewRecords =>
      $$ReviewRecordsTableTableManager(_db, _db.reviewRecords);
  $$ExtraRemindersTableTableManager get extraReminders =>
      $$ExtraRemindersTableTableManager(_db, _db.extraReminders);
}
