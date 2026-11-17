// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alambic_database.dart';

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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    builtInKey,
    intervals,
    failureBehavior,
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
  static TypeConverter<List<PresetInterval>, String> $converterintervals =
      const PresetIntervalListConverter();
  static JsonTypeConverter2<FailureBehavior, String, String>
  $converterfailureBehavior = const EnumNameConverter<FailureBehavior>(
    FailureBehavior.values,
  );
}

class PresetsCompanion extends UpdateCompanion<Preset> {
  final Value<int> id;
  final Value<String> name;
  final Value<BuiltInPresetKey?> builtInKey;
  final Value<List<PresetInterval>> intervals;
  final Value<FailureBehavior> failureBehavior;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.builtInKey = const Value.absent(),
    this.intervals = const Value.absent(),
    this.failureBehavior = const Value.absent(),
  });
  PresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.builtInKey = const Value.absent(),
    required List<PresetInterval> intervals,
    required FailureBehavior failureBehavior,
  }) : name = Value(name),
       intervals = Value(intervals),
       failureBehavior = Value(failureBehavior);
  static Insertable<Preset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? builtInKey,
    Expression<String>? intervals,
    Expression<String>? failureBehavior,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (builtInKey != null) 'built_in_key': builtInKey,
      if (intervals != null) 'intervals': intervals,
      if (failureBehavior != null) 'failure_behavior': failureBehavior,
    });
  }

  PresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<BuiltInPresetKey?>? builtInKey,
    Value<List<PresetInterval>>? intervals,
    Value<FailureBehavior>? failureBehavior,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      builtInKey: builtInKey ?? this.builtInKey,
      intervals: intervals ?? this.intervals,
      failureBehavior: failureBehavior ?? this.failureBehavior,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('builtInKey: $builtInKey, ')
          ..write('intervals: $intervals, ')
          ..write('failureBehavior: $failureBehavior')
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
  late final GeneratedColumnWithTypeConverter<ScheduleKind, String>
  scheduleKind = GeneratedColumn<String>(
    'schedule_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ScheduleKind.fixedTime.name),
  ).withConverter<ScheduleKind>($AppSettingsTable.$converterscheduleKind);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> fixedTime =
      GeneratedColumn<int>(
        'fixed_time',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(12 * 60),
      ).withConverter<ClockTime>($AppSettingsTable.$converterfixedTime);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> rangeStart =
      GeneratedColumn<int>(
        'range_start',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(9 * 60),
      ).withConverter<ClockTime>($AppSettingsTable.$converterrangeStart);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> rangeEnd =
      GeneratedColumn<int>(
        'range_end',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(18 * 60),
      ).withConverter<ClockTime>($AppSettingsTable.$converterrangeEnd);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationMode, String>
  notificationMode =
      GeneratedColumn<String>(
        'notification_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(NotificationMode.perCard.name),
      ).withConverter<NotificationMode>(
        $AppSettingsTable.$converternotificationMode,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GroupedReminderAction, String>
  groupedAction =
      GeneratedColumn<String>(
        'grouped_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(GroupedReminderAction.openApp.name),
      ).withConverter<GroupedReminderAction>(
        $AppSettingsTable.$convertergroupedAction,
      );
  static const VerificationMeta _dailyNotificationCapMeta =
      const VerificationMeta('dailyNotificationCap');
  @override
  late final GeneratedColumn<int> dailyNotificationCap = GeneratedColumn<int>(
    'daily_notification_cap',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _quietHoursEnabledMeta = const VerificationMeta(
    'quietHoursEnabled',
  );
  @override
  late final GeneratedColumn<bool> quietHoursEnabled = GeneratedColumn<bool>(
    'quiet_hours_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_hours_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> quietStart =
      GeneratedColumn<int>(
        'quiet_start',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(22 * 60),
      ).withConverter<ClockTime>($AppSettingsTable.$converterquietStart);
  @override
  late final GeneratedColumnWithTypeConverter<ClockTime, int> quietEnd =
      GeneratedColumn<int>(
        'quiet_end',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(8 * 60),
      ).withConverter<ClockTime>($AppSettingsTable.$converterquietEnd);
  static const VerificationMeta _autoGroupEnabledMeta = const VerificationMeta(
    'autoGroupEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoGroupEnabled = GeneratedColumn<bool>(
    'auto_group_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_group_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoGroupThresholdMeta =
      const VerificationMeta('autoGroupThreshold');
  @override
  late final GeneratedColumn<int> autoGroupThreshold = GeneratedColumn<int>(
    'auto_group_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _notifiedDayMeta = const VerificationMeta(
    'notifiedDay',
  );
  @override
  late final GeneratedColumn<DateTime> notifiedDay = GeneratedColumn<DateTime>(
    'notified_day',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notifiedCountMeta = const VerificationMeta(
    'notifiedCount',
  );
  @override
  late final GeneratedColumn<int> notifiedCount = GeneratedColumn<int>(
    'notified_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    globalPresetId,
    scheduleKind,
    fixedTime,
    rangeStart,
    rangeEnd,
    notificationMode,
    groupedAction,
    dailyNotificationCap,
    quietHoursEnabled,
    quietStart,
    quietEnd,
    autoGroupEnabled,
    autoGroupThreshold,
    notifiedDay,
    notifiedCount,
    pausedAt,
  ];
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
    if (data.containsKey('daily_notification_cap')) {
      context.handle(
        _dailyNotificationCapMeta,
        dailyNotificationCap.isAcceptableOrUnknown(
          data['daily_notification_cap']!,
          _dailyNotificationCapMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_enabled')) {
      context.handle(
        _quietHoursEnabledMeta,
        quietHoursEnabled.isAcceptableOrUnknown(
          data['quiet_hours_enabled']!,
          _quietHoursEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_group_enabled')) {
      context.handle(
        _autoGroupEnabledMeta,
        autoGroupEnabled.isAcceptableOrUnknown(
          data['auto_group_enabled']!,
          _autoGroupEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_group_threshold')) {
      context.handle(
        _autoGroupThresholdMeta,
        autoGroupThreshold.isAcceptableOrUnknown(
          data['auto_group_threshold']!,
          _autoGroupThresholdMeta,
        ),
      );
    }
    if (data.containsKey('notified_day')) {
      context.handle(
        _notifiedDayMeta,
        notifiedDay.isAcceptableOrUnknown(
          data['notified_day']!,
          _notifiedDayMeta,
        ),
      );
    }
    if (data.containsKey('notified_count')) {
      context.handle(
        _notifiedCountMeta,
        notifiedCount.isAcceptableOrUnknown(
          data['notified_count']!,
          _notifiedCountMeta,
        ),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
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
      scheduleKind: $AppSettingsTable.$converterscheduleKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_kind'],
        )!,
      ),
      fixedTime: $AppSettingsTable.$converterfixedTime.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}fixed_time'],
        )!,
      ),
      rangeStart: $AppSettingsTable.$converterrangeStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}range_start'],
        )!,
      ),
      rangeEnd: $AppSettingsTable.$converterrangeEnd.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}range_end'],
        )!,
      ),
      notificationMode: $AppSettingsTable.$converternotificationMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notification_mode'],
        )!,
      ),
      groupedAction: $AppSettingsTable.$convertergroupedAction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}grouped_action'],
        )!,
      ),
      dailyNotificationCap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_notification_cap'],
      )!,
      quietHoursEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_hours_enabled'],
      )!,
      quietStart: $AppSettingsTable.$converterquietStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}quiet_start'],
        )!,
      ),
      quietEnd: $AppSettingsTable.$converterquietEnd.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}quiet_end'],
        )!,
      ),
      autoGroupEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_group_enabled'],
      )!,
      autoGroupThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_group_threshold'],
      )!,
      notifiedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notified_day'],
      ),
      notifiedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notified_count'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

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
  static TypeConverter<ClockTime, int> $converterquietStart =
      const ClockTimeConverter();
  static TypeConverter<ClockTime, int> $converterquietEnd =
      const ClockTimeConverter();
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  /// Always 1: the table holds a single row.
  final int id;
  final int globalPresetId;

  /// Schedule and notification mode of the whole app, see `ReminderSettings`.
  final ScheduleKind scheduleKind;
  final ClockTime fixedTime;
  final ClockTime rangeStart;
  final ClockTime rangeEnd;
  final NotificationMode notificationMode;
  final GroupedReminderAction groupedAction;

  /// Notification safeguards, see `NotificationGuards`.
  final int dailyNotificationCap;
  final bool quietHoursEnabled;
  final ClockTime quietStart;
  final ClockTime quietEnd;
  final bool autoGroupEnabled;
  final int autoGroupThreshold;

  /// Cards notified on [notifiedDay], counted against the daily cap.
  final DateTime? notifiedDay;
  final int notifiedCount;

  /// Start of the global pause, `null` when it is off.
  final DateTime? pausedAt;
  const AppSettingsRow({
    required this.id,
    required this.globalPresetId,
    required this.scheduleKind,
    required this.fixedTime,
    required this.rangeStart,
    required this.rangeEnd,
    required this.notificationMode,
    required this.groupedAction,
    required this.dailyNotificationCap,
    required this.quietHoursEnabled,
    required this.quietStart,
    required this.quietEnd,
    required this.autoGroupEnabled,
    required this.autoGroupThreshold,
    this.notifiedDay,
    required this.notifiedCount,
    this.pausedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_preset_id'] = Variable<int>(globalPresetId);
    {
      map['schedule_kind'] = Variable<String>(
        $AppSettingsTable.$converterscheduleKind.toSql(scheduleKind),
      );
    }
    {
      map['fixed_time'] = Variable<int>(
        $AppSettingsTable.$converterfixedTime.toSql(fixedTime),
      );
    }
    {
      map['range_start'] = Variable<int>(
        $AppSettingsTable.$converterrangeStart.toSql(rangeStart),
      );
    }
    {
      map['range_end'] = Variable<int>(
        $AppSettingsTable.$converterrangeEnd.toSql(rangeEnd),
      );
    }
    {
      map['notification_mode'] = Variable<String>(
        $AppSettingsTable.$converternotificationMode.toSql(notificationMode),
      );
    }
    {
      map['grouped_action'] = Variable<String>(
        $AppSettingsTable.$convertergroupedAction.toSql(groupedAction),
      );
    }
    map['daily_notification_cap'] = Variable<int>(dailyNotificationCap);
    map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled);
    {
      map['quiet_start'] = Variable<int>(
        $AppSettingsTable.$converterquietStart.toSql(quietStart),
      );
    }
    {
      map['quiet_end'] = Variable<int>(
        $AppSettingsTable.$converterquietEnd.toSql(quietEnd),
      );
    }
    map['auto_group_enabled'] = Variable<bool>(autoGroupEnabled);
    map['auto_group_threshold'] = Variable<int>(autoGroupThreshold);
    if (!nullToAbsent || notifiedDay != null) {
      map['notified_day'] = Variable<DateTime>(notifiedDay);
    }
    map['notified_count'] = Variable<int>(notifiedCount);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      globalPresetId: Value(globalPresetId),
      scheduleKind: Value(scheduleKind),
      fixedTime: Value(fixedTime),
      rangeStart: Value(rangeStart),
      rangeEnd: Value(rangeEnd),
      notificationMode: Value(notificationMode),
      groupedAction: Value(groupedAction),
      dailyNotificationCap: Value(dailyNotificationCap),
      quietHoursEnabled: Value(quietHoursEnabled),
      quietStart: Value(quietStart),
      quietEnd: Value(quietEnd),
      autoGroupEnabled: Value(autoGroupEnabled),
      autoGroupThreshold: Value(autoGroupThreshold),
      notifiedDay: notifiedDay == null && nullToAbsent
          ? const Value.absent()
          : Value(notifiedDay),
      notifiedCount: Value(notifiedCount),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
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
      scheduleKind: $AppSettingsTable.$converterscheduleKind.fromJson(
        serializer.fromJson<String>(json['scheduleKind']),
      ),
      fixedTime: serializer.fromJson<ClockTime>(json['fixedTime']),
      rangeStart: serializer.fromJson<ClockTime>(json['rangeStart']),
      rangeEnd: serializer.fromJson<ClockTime>(json['rangeEnd']),
      notificationMode: $AppSettingsTable.$converternotificationMode.fromJson(
        serializer.fromJson<String>(json['notificationMode']),
      ),
      groupedAction: $AppSettingsTable.$convertergroupedAction.fromJson(
        serializer.fromJson<String>(json['groupedAction']),
      ),
      dailyNotificationCap: serializer.fromJson<int>(
        json['dailyNotificationCap'],
      ),
      quietHoursEnabled: serializer.fromJson<bool>(json['quietHoursEnabled']),
      quietStart: serializer.fromJson<ClockTime>(json['quietStart']),
      quietEnd: serializer.fromJson<ClockTime>(json['quietEnd']),
      autoGroupEnabled: serializer.fromJson<bool>(json['autoGroupEnabled']),
      autoGroupThreshold: serializer.fromJson<int>(json['autoGroupThreshold']),
      notifiedDay: serializer.fromJson<DateTime?>(json['notifiedDay']),
      notifiedCount: serializer.fromJson<int>(json['notifiedCount']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalPresetId': serializer.toJson<int>(globalPresetId),
      'scheduleKind': serializer.toJson<String>(
        $AppSettingsTable.$converterscheduleKind.toJson(scheduleKind),
      ),
      'fixedTime': serializer.toJson<ClockTime>(fixedTime),
      'rangeStart': serializer.toJson<ClockTime>(rangeStart),
      'rangeEnd': serializer.toJson<ClockTime>(rangeEnd),
      'notificationMode': serializer.toJson<String>(
        $AppSettingsTable.$converternotificationMode.toJson(notificationMode),
      ),
      'groupedAction': serializer.toJson<String>(
        $AppSettingsTable.$convertergroupedAction.toJson(groupedAction),
      ),
      'dailyNotificationCap': serializer.toJson<int>(dailyNotificationCap),
      'quietHoursEnabled': serializer.toJson<bool>(quietHoursEnabled),
      'quietStart': serializer.toJson<ClockTime>(quietStart),
      'quietEnd': serializer.toJson<ClockTime>(quietEnd),
      'autoGroupEnabled': serializer.toJson<bool>(autoGroupEnabled),
      'autoGroupThreshold': serializer.toJson<int>(autoGroupThreshold),
      'notifiedDay': serializer.toJson<DateTime?>(notifiedDay),
      'notifiedCount': serializer.toJson<int>(notifiedCount),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    int? globalPresetId,
    ScheduleKind? scheduleKind,
    ClockTime? fixedTime,
    ClockTime? rangeStart,
    ClockTime? rangeEnd,
    NotificationMode? notificationMode,
    GroupedReminderAction? groupedAction,
    int? dailyNotificationCap,
    bool? quietHoursEnabled,
    ClockTime? quietStart,
    ClockTime? quietEnd,
    bool? autoGroupEnabled,
    int? autoGroupThreshold,
    Value<DateTime?> notifiedDay = const Value.absent(),
    int? notifiedCount,
    Value<DateTime?> pausedAt = const Value.absent(),
  }) => AppSettingsRow(
    id: id ?? this.id,
    globalPresetId: globalPresetId ?? this.globalPresetId,
    scheduleKind: scheduleKind ?? this.scheduleKind,
    fixedTime: fixedTime ?? this.fixedTime,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
    notificationMode: notificationMode ?? this.notificationMode,
    groupedAction: groupedAction ?? this.groupedAction,
    dailyNotificationCap: dailyNotificationCap ?? this.dailyNotificationCap,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    autoGroupEnabled: autoGroupEnabled ?? this.autoGroupEnabled,
    autoGroupThreshold: autoGroupThreshold ?? this.autoGroupThreshold,
    notifiedDay: notifiedDay.present ? notifiedDay.value : this.notifiedDay,
    notifiedCount: notifiedCount ?? this.notifiedCount,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      globalPresetId: data.globalPresetId.present
          ? data.globalPresetId.value
          : this.globalPresetId,
      scheduleKind: data.scheduleKind.present
          ? data.scheduleKind.value
          : this.scheduleKind,
      fixedTime: data.fixedTime.present ? data.fixedTime.value : this.fixedTime,
      rangeStart: data.rangeStart.present
          ? data.rangeStart.value
          : this.rangeStart,
      rangeEnd: data.rangeEnd.present ? data.rangeEnd.value : this.rangeEnd,
      notificationMode: data.notificationMode.present
          ? data.notificationMode.value
          : this.notificationMode,
      groupedAction: data.groupedAction.present
          ? data.groupedAction.value
          : this.groupedAction,
      dailyNotificationCap: data.dailyNotificationCap.present
          ? data.dailyNotificationCap.value
          : this.dailyNotificationCap,
      quietHoursEnabled: data.quietHoursEnabled.present
          ? data.quietHoursEnabled.value
          : this.quietHoursEnabled,
      quietStart: data.quietStart.present
          ? data.quietStart.value
          : this.quietStart,
      quietEnd: data.quietEnd.present ? data.quietEnd.value : this.quietEnd,
      autoGroupEnabled: data.autoGroupEnabled.present
          ? data.autoGroupEnabled.value
          : this.autoGroupEnabled,
      autoGroupThreshold: data.autoGroupThreshold.present
          ? data.autoGroupThreshold.value
          : this.autoGroupThreshold,
      notifiedDay: data.notifiedDay.present
          ? data.notifiedDay.value
          : this.notifiedDay,
      notifiedCount: data.notifiedCount.present
          ? data.notifiedCount.value
          : this.notifiedCount,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('globalPresetId: $globalPresetId, ')
          ..write('scheduleKind: $scheduleKind, ')
          ..write('fixedTime: $fixedTime, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('notificationMode: $notificationMode, ')
          ..write('groupedAction: $groupedAction, ')
          ..write('dailyNotificationCap: $dailyNotificationCap, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('autoGroupEnabled: $autoGroupEnabled, ')
          ..write('autoGroupThreshold: $autoGroupThreshold, ')
          ..write('notifiedDay: $notifiedDay, ')
          ..write('notifiedCount: $notifiedCount, ')
          ..write('pausedAt: $pausedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    globalPresetId,
    scheduleKind,
    fixedTime,
    rangeStart,
    rangeEnd,
    notificationMode,
    groupedAction,
    dailyNotificationCap,
    quietHoursEnabled,
    quietStart,
    quietEnd,
    autoGroupEnabled,
    autoGroupThreshold,
    notifiedDay,
    notifiedCount,
    pausedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.globalPresetId == this.globalPresetId &&
          other.scheduleKind == this.scheduleKind &&
          other.fixedTime == this.fixedTime &&
          other.rangeStart == this.rangeStart &&
          other.rangeEnd == this.rangeEnd &&
          other.notificationMode == this.notificationMode &&
          other.groupedAction == this.groupedAction &&
          other.dailyNotificationCap == this.dailyNotificationCap &&
          other.quietHoursEnabled == this.quietHoursEnabled &&
          other.quietStart == this.quietStart &&
          other.quietEnd == this.quietEnd &&
          other.autoGroupEnabled == this.autoGroupEnabled &&
          other.autoGroupThreshold == this.autoGroupThreshold &&
          other.notifiedDay == this.notifiedDay &&
          other.notifiedCount == this.notifiedCount &&
          other.pausedAt == this.pausedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> globalPresetId;
  final Value<ScheduleKind> scheduleKind;
  final Value<ClockTime> fixedTime;
  final Value<ClockTime> rangeStart;
  final Value<ClockTime> rangeEnd;
  final Value<NotificationMode> notificationMode;
  final Value<GroupedReminderAction> groupedAction;
  final Value<int> dailyNotificationCap;
  final Value<bool> quietHoursEnabled;
  final Value<ClockTime> quietStart;
  final Value<ClockTime> quietEnd;
  final Value<bool> autoGroupEnabled;
  final Value<int> autoGroupThreshold;
  final Value<DateTime?> notifiedDay;
  final Value<int> notifiedCount;
  final Value<DateTime?> pausedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.globalPresetId = const Value.absent(),
    this.scheduleKind = const Value.absent(),
    this.fixedTime = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.notificationMode = const Value.absent(),
    this.groupedAction = const Value.absent(),
    this.dailyNotificationCap = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.autoGroupEnabled = const Value.absent(),
    this.autoGroupThreshold = const Value.absent(),
    this.notifiedDay = const Value.absent(),
    this.notifiedCount = const Value.absent(),
    this.pausedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int globalPresetId,
    this.scheduleKind = const Value.absent(),
    this.fixedTime = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.notificationMode = const Value.absent(),
    this.groupedAction = const Value.absent(),
    this.dailyNotificationCap = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.autoGroupEnabled = const Value.absent(),
    this.autoGroupThreshold = const Value.absent(),
    this.notifiedDay = const Value.absent(),
    this.notifiedCount = const Value.absent(),
    this.pausedAt = const Value.absent(),
  }) : globalPresetId = Value(globalPresetId);
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? globalPresetId,
    Expression<String>? scheduleKind,
    Expression<int>? fixedTime,
    Expression<int>? rangeStart,
    Expression<int>? rangeEnd,
    Expression<String>? notificationMode,
    Expression<String>? groupedAction,
    Expression<int>? dailyNotificationCap,
    Expression<bool>? quietHoursEnabled,
    Expression<int>? quietStart,
    Expression<int>? quietEnd,
    Expression<bool>? autoGroupEnabled,
    Expression<int>? autoGroupThreshold,
    Expression<DateTime>? notifiedDay,
    Expression<int>? notifiedCount,
    Expression<DateTime>? pausedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalPresetId != null) 'global_preset_id': globalPresetId,
      if (scheduleKind != null) 'schedule_kind': scheduleKind,
      if (fixedTime != null) 'fixed_time': fixedTime,
      if (rangeStart != null) 'range_start': rangeStart,
      if (rangeEnd != null) 'range_end': rangeEnd,
      if (notificationMode != null) 'notification_mode': notificationMode,
      if (groupedAction != null) 'grouped_action': groupedAction,
      if (dailyNotificationCap != null)
        'daily_notification_cap': dailyNotificationCap,
      if (quietHoursEnabled != null) 'quiet_hours_enabled': quietHoursEnabled,
      if (quietStart != null) 'quiet_start': quietStart,
      if (quietEnd != null) 'quiet_end': quietEnd,
      if (autoGroupEnabled != null) 'auto_group_enabled': autoGroupEnabled,
      if (autoGroupThreshold != null)
        'auto_group_threshold': autoGroupThreshold,
      if (notifiedDay != null) 'notified_day': notifiedDay,
      if (notifiedCount != null) 'notified_count': notifiedCount,
      if (pausedAt != null) 'paused_at': pausedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? globalPresetId,
    Value<ScheduleKind>? scheduleKind,
    Value<ClockTime>? fixedTime,
    Value<ClockTime>? rangeStart,
    Value<ClockTime>? rangeEnd,
    Value<NotificationMode>? notificationMode,
    Value<GroupedReminderAction>? groupedAction,
    Value<int>? dailyNotificationCap,
    Value<bool>? quietHoursEnabled,
    Value<ClockTime>? quietStart,
    Value<ClockTime>? quietEnd,
    Value<bool>? autoGroupEnabled,
    Value<int>? autoGroupThreshold,
    Value<DateTime?>? notifiedDay,
    Value<int>? notifiedCount,
    Value<DateTime?>? pausedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      globalPresetId: globalPresetId ?? this.globalPresetId,
      scheduleKind: scheduleKind ?? this.scheduleKind,
      fixedTime: fixedTime ?? this.fixedTime,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      notificationMode: notificationMode ?? this.notificationMode,
      groupedAction: groupedAction ?? this.groupedAction,
      dailyNotificationCap: dailyNotificationCap ?? this.dailyNotificationCap,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      autoGroupEnabled: autoGroupEnabled ?? this.autoGroupEnabled,
      autoGroupThreshold: autoGroupThreshold ?? this.autoGroupThreshold,
      notifiedDay: notifiedDay ?? this.notifiedDay,
      notifiedCount: notifiedCount ?? this.notifiedCount,
      pausedAt: pausedAt ?? this.pausedAt,
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
    if (scheduleKind.present) {
      map['schedule_kind'] = Variable<String>(
        $AppSettingsTable.$converterscheduleKind.toSql(scheduleKind.value),
      );
    }
    if (fixedTime.present) {
      map['fixed_time'] = Variable<int>(
        $AppSettingsTable.$converterfixedTime.toSql(fixedTime.value),
      );
    }
    if (rangeStart.present) {
      map['range_start'] = Variable<int>(
        $AppSettingsTable.$converterrangeStart.toSql(rangeStart.value),
      );
    }
    if (rangeEnd.present) {
      map['range_end'] = Variable<int>(
        $AppSettingsTable.$converterrangeEnd.toSql(rangeEnd.value),
      );
    }
    if (notificationMode.present) {
      map['notification_mode'] = Variable<String>(
        $AppSettingsTable.$converternotificationMode.toSql(
          notificationMode.value,
        ),
      );
    }
    if (groupedAction.present) {
      map['grouped_action'] = Variable<String>(
        $AppSettingsTable.$convertergroupedAction.toSql(groupedAction.value),
      );
    }
    if (dailyNotificationCap.present) {
      map['daily_notification_cap'] = Variable<int>(dailyNotificationCap.value);
    }
    if (quietHoursEnabled.present) {
      map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled.value);
    }
    if (quietStart.present) {
      map['quiet_start'] = Variable<int>(
        $AppSettingsTable.$converterquietStart.toSql(quietStart.value),
      );
    }
    if (quietEnd.present) {
      map['quiet_end'] = Variable<int>(
        $AppSettingsTable.$converterquietEnd.toSql(quietEnd.value),
      );
    }
    if (autoGroupEnabled.present) {
      map['auto_group_enabled'] = Variable<bool>(autoGroupEnabled.value);
    }
    if (autoGroupThreshold.present) {
      map['auto_group_threshold'] = Variable<int>(autoGroupThreshold.value);
    }
    if (notifiedDay.present) {
      map['notified_day'] = Variable<DateTime>(notifiedDay.value);
    }
    if (notifiedCount.present) {
      map['notified_count'] = Variable<int>(notifiedCount.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('globalPresetId: $globalPresetId, ')
          ..write('scheduleKind: $scheduleKind, ')
          ..write('fixedTime: $fixedTime, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('notificationMode: $notificationMode, ')
          ..write('groupedAction: $groupedAction, ')
          ..write('dailyNotificationCap: $dailyNotificationCap, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('autoGroupEnabled: $autoGroupEnabled, ')
          ..write('autoGroupThreshold: $autoGroupThreshold, ')
          ..write('notifiedDay: $notifiedDay, ')
          ..write('notifiedCount: $notifiedCount, ')
          ..write('pausedAt: $pausedAt')
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
  static const VerificationMeta _reverseEnabledMeta = const VerificationMeta(
    'reverseEnabled',
  );
  @override
  late final GeneratedColumn<bool> reverseEnabled = GeneratedColumn<bool>(
    'reverse_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reverse_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AfterLastStep, String>
  afterLastStep = GeneratedColumn<String>(
    'after_last_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(AfterLastStep.remanence.name),
  ).withConverter<AfterLastStep>($CardGroupsTable.$converterafterLastStep);
  @override
  late final GeneratedColumnWithTypeConverter<RemanenceInterval, String>
  remanenceInterval =
      GeneratedColumn<String>(
        'remanence_interval',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RemanenceInterval.sixMonths.name),
      ).withConverter<RemanenceInterval>(
        $CardGroupsTable.$converterremanenceInterval,
      );
  static const VerificationMeta _typedAnswerMeta = const VerificationMeta(
    'typedAnswer',
  );
  @override
  late final GeneratedColumn<bool> typedAnswer = GeneratedColumn<bool>(
    'typed_answer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("typed_answer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    presetId,
    createdAt,
    reverseEnabled,
    afterLastStep,
    remanenceInterval,
    typedAnswer,
    pausedAt,
  ];
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
    if (data.containsKey('reverse_enabled')) {
      context.handle(
        _reverseEnabledMeta,
        reverseEnabled.isAcceptableOrUnknown(
          data['reverse_enabled']!,
          _reverseEnabledMeta,
        ),
      );
    }
    if (data.containsKey('typed_answer')) {
      context.handle(
        _typedAnswerMeta,
        typedAnswer.isAcceptableOrUnknown(
          data['typed_answer']!,
          _typedAnswerMeta,
        ),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
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
      reverseEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reverse_enabled'],
      )!,
      afterLastStep: $CardGroupsTable.$converterafterLastStep.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}after_last_step'],
        )!,
      ),
      remanenceInterval: $CardGroupsTable.$converterremanenceInterval.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}remanence_interval'],
        )!,
      ),
      typedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}typed_answer'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
    );
  }

  @override
  $CardGroupsTable createAlias(String alias) {
    return $CardGroupsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AfterLastStep, String, String>
  $converterafterLastStep = const EnumNameConverter<AfterLastStep>(
    AfterLastStep.values,
  );
  static JsonTypeConverter2<RemanenceInterval, String, String>
  $converterremanenceInterval = const EnumNameConverter<RemanenceInterval>(
    RemanenceInterval.values,
  );
}

class CardGroupsCompanion extends UpdateCompanion<CardGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> presetId;
  final Value<DateTime> createdAt;
  final Value<bool> reverseEnabled;
  final Value<AfterLastStep> afterLastStep;
  final Value<RemanenceInterval> remanenceInterval;
  final Value<bool> typedAnswer;
  final Value<DateTime?> pausedAt;
  const CardGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.presetId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reverseEnabled = const Value.absent(),
    this.afterLastStep = const Value.absent(),
    this.remanenceInterval = const Value.absent(),
    this.typedAnswer = const Value.absent(),
    this.pausedAt = const Value.absent(),
  });
  CardGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.presetId = const Value.absent(),
    required DateTime createdAt,
    this.reverseEnabled = const Value.absent(),
    this.afterLastStep = const Value.absent(),
    this.remanenceInterval = const Value.absent(),
    this.typedAnswer = const Value.absent(),
    this.pausedAt = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CardGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? presetId,
    Expression<DateTime>? createdAt,
    Expression<bool>? reverseEnabled,
    Expression<String>? afterLastStep,
    Expression<String>? remanenceInterval,
    Expression<bool>? typedAnswer,
    Expression<DateTime>? pausedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (presetId != null) 'preset_id': presetId,
      if (createdAt != null) 'created_at': createdAt,
      if (reverseEnabled != null) 'reverse_enabled': reverseEnabled,
      if (afterLastStep != null) 'after_last_step': afterLastStep,
      if (remanenceInterval != null) 'remanence_interval': remanenceInterval,
      if (typedAnswer != null) 'typed_answer': typedAnswer,
      if (pausedAt != null) 'paused_at': pausedAt,
    });
  }

  CardGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? presetId,
    Value<DateTime>? createdAt,
    Value<bool>? reverseEnabled,
    Value<AfterLastStep>? afterLastStep,
    Value<RemanenceInterval>? remanenceInterval,
    Value<bool>? typedAnswer,
    Value<DateTime?>? pausedAt,
  }) {
    return CardGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      presetId: presetId ?? this.presetId,
      createdAt: createdAt ?? this.createdAt,
      reverseEnabled: reverseEnabled ?? this.reverseEnabled,
      afterLastStep: afterLastStep ?? this.afterLastStep,
      remanenceInterval: remanenceInterval ?? this.remanenceInterval,
      typedAnswer: typedAnswer ?? this.typedAnswer,
      pausedAt: pausedAt ?? this.pausedAt,
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
    if (reverseEnabled.present) {
      map['reverse_enabled'] = Variable<bool>(reverseEnabled.value);
    }
    if (afterLastStep.present) {
      map['after_last_step'] = Variable<String>(
        $CardGroupsTable.$converterafterLastStep.toSql(afterLastStep.value),
      );
    }
    if (remanenceInterval.present) {
      map['remanence_interval'] = Variable<String>(
        $CardGroupsTable.$converterremanenceInterval.toSql(
          remanenceInterval.value,
        ),
      );
    }
    if (typedAnswer.present) {
      map['typed_answer'] = Variable<bool>(typedAnswer.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('presetId: $presetId, ')
          ..write('createdAt: $createdAt, ')
          ..write('reverseEnabled: $reverseEnabled, ')
          ..write('afterLastStep: $afterLastStep, ')
          ..write('remanenceInterval: $remanenceInterval, ')
          ..write('typedAnswer: $typedAnswer, ')
          ..write('pausedAt: $pausedAt')
          ..write(')'))
        .toString();
  }
}

class $DistillationsTable extends Distillations
    with TableInfo<$DistillationsTable, Distillation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistillationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cardsPerBatchMeta = const VerificationMeta(
    'cardsPerBatch',
  );
  @override
  late final GeneratedColumn<int> cardsPerBatch = GeneratedColumn<int>(
    'cards_per_batch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _everyDaysMeta = const VerificationMeta(
    'everyDays',
  );
  @override
  late final GeneratedColumn<int> everyDays = GeneratedColumn<int>(
    'every_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioritizeReviewsMeta = const VerificationMeta(
    'prioritizeReviews',
  );
  @override
  late final GeneratedColumn<bool> prioritizeReviews = GeneratedColumn<bool>(
    'prioritize_reviews',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("prioritize_reviews" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DistillationStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DistillationStatus>($DistillationsTable.$converterstatus);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastBatchDayMeta = const VerificationMeta(
    'lastBatchDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastBatchDay = GeneratedColumn<DateTime>(
    'last_batch_day',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAdvancedDayMeta = const VerificationMeta(
    'lastAdvancedDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastAdvancedDay =
      GeneratedColumn<DateTime>(
        'last_advanced_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    cardsPerBatch,
    everyDays,
    prioritizeReviews,
    status,
    startedAt,
    lastBatchDay,
    lastAdvancedDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'distillations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Distillation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('cards_per_batch')) {
      context.handle(
        _cardsPerBatchMeta,
        cardsPerBatch.isAcceptableOrUnknown(
          data['cards_per_batch']!,
          _cardsPerBatchMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardsPerBatchMeta);
    }
    if (data.containsKey('every_days')) {
      context.handle(
        _everyDaysMeta,
        everyDays.isAcceptableOrUnknown(data['every_days']!, _everyDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_everyDaysMeta);
    }
    if (data.containsKey('prioritize_reviews')) {
      context.handle(
        _prioritizeReviewsMeta,
        prioritizeReviews.isAcceptableOrUnknown(
          data['prioritize_reviews']!,
          _prioritizeReviewsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prioritizeReviewsMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_batch_day')) {
      context.handle(
        _lastBatchDayMeta,
        lastBatchDay.isAcceptableOrUnknown(
          data['last_batch_day']!,
          _lastBatchDayMeta,
        ),
      );
    }
    if (data.containsKey('last_advanced_day')) {
      context.handle(
        _lastAdvancedDayMeta,
        lastAdvancedDay.isAcceptableOrUnknown(
          data['last_advanced_day']!,
          _lastAdvancedDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  Distillation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Distillation(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      cardsPerBatch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cards_per_batch'],
      )!,
      everyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_days'],
      )!,
      prioritizeReviews: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prioritize_reviews'],
      )!,
      status: $DistillationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastBatchDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_batch_day'],
      ),
      lastAdvancedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_advanced_day'],
      ),
    );
  }

  @override
  $DistillationsTable createAlias(String alias) {
    return $DistillationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DistillationStatus, String, String>
  $converterstatus = const EnumNameConverter<DistillationStatus>(
    DistillationStatus.values,
  );
}

class DistillationsCompanion extends UpdateCompanion<Distillation> {
  final Value<int> groupId;
  final Value<int> cardsPerBatch;
  final Value<int> everyDays;
  final Value<bool> prioritizeReviews;
  final Value<DistillationStatus> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> lastBatchDay;
  final Value<DateTime?> lastAdvancedDay;
  const DistillationsCompanion({
    this.groupId = const Value.absent(),
    this.cardsPerBatch = const Value.absent(),
    this.everyDays = const Value.absent(),
    this.prioritizeReviews = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastBatchDay = const Value.absent(),
    this.lastAdvancedDay = const Value.absent(),
  });
  DistillationsCompanion.insert({
    this.groupId = const Value.absent(),
    required int cardsPerBatch,
    required int everyDays,
    required bool prioritizeReviews,
    required DistillationStatus status,
    required DateTime startedAt,
    this.lastBatchDay = const Value.absent(),
    this.lastAdvancedDay = const Value.absent(),
  }) : cardsPerBatch = Value(cardsPerBatch),
       everyDays = Value(everyDays),
       prioritizeReviews = Value(prioritizeReviews),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<Distillation> custom({
    Expression<int>? groupId,
    Expression<int>? cardsPerBatch,
    Expression<int>? everyDays,
    Expression<bool>? prioritizeReviews,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastBatchDay,
    Expression<DateTime>? lastAdvancedDay,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (cardsPerBatch != null) 'cards_per_batch': cardsPerBatch,
      if (everyDays != null) 'every_days': everyDays,
      if (prioritizeReviews != null) 'prioritize_reviews': prioritizeReviews,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (lastBatchDay != null) 'last_batch_day': lastBatchDay,
      if (lastAdvancedDay != null) 'last_advanced_day': lastAdvancedDay,
    });
  }

  DistillationsCompanion copyWith({
    Value<int>? groupId,
    Value<int>? cardsPerBatch,
    Value<int>? everyDays,
    Value<bool>? prioritizeReviews,
    Value<DistillationStatus>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? lastBatchDay,
    Value<DateTime?>? lastAdvancedDay,
  }) {
    return DistillationsCompanion(
      groupId: groupId ?? this.groupId,
      cardsPerBatch: cardsPerBatch ?? this.cardsPerBatch,
      everyDays: everyDays ?? this.everyDays,
      prioritizeReviews: prioritizeReviews ?? this.prioritizeReviews,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      lastBatchDay: lastBatchDay ?? this.lastBatchDay,
      lastAdvancedDay: lastAdvancedDay ?? this.lastAdvancedDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (cardsPerBatch.present) {
      map['cards_per_batch'] = Variable<int>(cardsPerBatch.value);
    }
    if (everyDays.present) {
      map['every_days'] = Variable<int>(everyDays.value);
    }
    if (prioritizeReviews.present) {
      map['prioritize_reviews'] = Variable<bool>(prioritizeReviews.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DistillationsTable.$converterstatus.toSql(status.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastBatchDay.present) {
      map['last_batch_day'] = Variable<DateTime>(lastBatchDay.value);
    }
    if (lastAdvancedDay.present) {
      map['last_advanced_day'] = Variable<DateTime>(lastAdvancedDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistillationsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('cardsPerBatch: $cardsPerBatch, ')
          ..write('everyDays: $everyDays, ')
          ..write('prioritizeReviews: $prioritizeReviews, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastBatchDay: $lastBatchDay, ')
          ..write('lastAdvancedDay: $lastAdvancedDay')
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  late final GeneratedColumnWithTypeConverter<CardState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CardState>($FlashcardsTable.$converterstate);
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
  static const VerificationMeta _queuePositionMeta = const VerificationMeta(
    'queuePosition',
  );
  @override
  late final GeneratedColumn<int> queuePosition = GeneratedColumn<int>(
    'queue_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    frontText,
    frontImagePath,
    backText,
    backImagePath,
    suspended,
    createdAt,
    state,
    step,
    dueAt,
    lastReviewedAt,
    notifiedAt,
    queuePosition,
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
    } else if (isInserting) {
      context.missing(_groupIdMeta);
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
    if (data.containsKey('queue_position')) {
      context.handle(
        _queuePositionMeta,
        queuePosition.isAcceptableOrUnknown(
          data['queue_position']!,
          _queuePositionMeta,
        ),
      );
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
      )!,
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
      suspended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}suspended'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      state: $FlashcardsTable.$converterstate.fromSql(
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
      queuePosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_position'],
      ),
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CardState, String, String> $converterstate =
      const EnumNameConverter<CardState>(CardState.values);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String?> frontText;
  final Value<String?> frontImagePath;
  final Value<String?> backText;
  final Value<String?> backImagePath;
  final Value<bool> suspended;
  final Value<DateTime> createdAt;
  final Value<CardState> state;
  final Value<int?> step;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> notifiedAt;
  final Value<int?> queuePosition;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.frontText = const Value.absent(),
    this.frontImagePath = const Value.absent(),
    this.backText = const Value.absent(),
    this.backImagePath = const Value.absent(),
    this.suspended = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.state = const Value.absent(),
    this.step = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.queuePosition = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    this.frontText = const Value.absent(),
    this.frontImagePath = const Value.absent(),
    this.backText = const Value.absent(),
    this.backImagePath = const Value.absent(),
    this.suspended = const Value.absent(),
    required DateTime createdAt,
    required CardState state,
    this.step = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.queuePosition = const Value.absent(),
  }) : groupId = Value(groupId),
       createdAt = Value(createdAt),
       state = Value(state);
  static Insertable<Flashcard> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? frontText,
    Expression<String>? frontImagePath,
    Expression<String>? backText,
    Expression<String>? backImagePath,
    Expression<bool>? suspended,
    Expression<DateTime>? createdAt,
    Expression<String>? state,
    Expression<int>? step,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? notifiedAt,
    Expression<int>? queuePosition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (frontText != null) 'front_text': frontText,
      if (frontImagePath != null) 'front_image_path': frontImagePath,
      if (backText != null) 'back_text': backText,
      if (backImagePath != null) 'back_image_path': backImagePath,
      if (suspended != null) 'suspended': suspended,
      if (createdAt != null) 'created_at': createdAt,
      if (state != null) 'state': state,
      if (step != null) 'step': step,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (notifiedAt != null) 'notified_at': notifiedAt,
      if (queuePosition != null) 'queue_position': queuePosition,
    });
  }

  FlashcardsCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String?>? frontText,
    Value<String?>? frontImagePath,
    Value<String?>? backText,
    Value<String?>? backImagePath,
    Value<bool>? suspended,
    Value<DateTime>? createdAt,
    Value<CardState>? state,
    Value<int?>? step,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? notifiedAt,
    Value<int?>? queuePosition,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      frontText: frontText ?? this.frontText,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backText: backText ?? this.backText,
      backImagePath: backImagePath ?? this.backImagePath,
      suspended: suspended ?? this.suspended,
      createdAt: createdAt ?? this.createdAt,
      state: state ?? this.state,
      step: step ?? this.step,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      queuePosition: queuePosition ?? this.queuePosition,
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
    if (suspended.present) {
      map['suspended'] = Variable<bool>(suspended.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $FlashcardsTable.$converterstate.toSql(state.value),
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
    if (queuePosition.present) {
      map['queue_position'] = Variable<int>(queuePosition.value);
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
          ..write('suspended: $suspended, ')
          ..write('createdAt: $createdAt, ')
          ..write('state: $state, ')
          ..write('step: $step, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('notifiedAt: $notifiedAt, ')
          ..write('queuePosition: $queuePosition')
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
  late final GeneratedColumnWithTypeConverter<CardState?, String> stateAfter =
      GeneratedColumn<String>(
        'state_after',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CardState?>($ReviewRecordsTable.$converterstateAftern);
  static const VerificationMeta _dueAtAfterMeta = const VerificationMeta(
    'dueAtAfter',
  );
  @override
  late final GeneratedColumn<DateTime> dueAtAfter = GeneratedColumn<DateTime>(
    'due_at_after',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    cardId,
    reviewedAt,
    outcome,
    isBonus,
    stepBefore,
    stepAfter,
    stateAfter,
    dueAtAfter,
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
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
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
    if (data.containsKey('due_at_after')) {
      context.handle(
        _dueAtAfterMeta,
        dueAtAfter.isAcceptableOrUnknown(
          data['due_at_after']!,
          _dueAtAfterMeta,
        ),
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
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
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
      stateAfter: $ReviewRecordsTable.$converterstateAftern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state_after'],
        ),
      ),
      dueAtAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at_after'],
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
  static JsonTypeConverter2<CardState, String, String> $converterstateAfter =
      const EnumNameConverter<CardState>(CardState.values);
  static JsonTypeConverter2<CardState?, String?, String?>
  $converterstateAftern = JsonTypeConverter2.asNullable($converterstateAfter);
  static JsonTypeConverter2<ReviewSource, String, String> $convertersource =
      const EnumNameConverter<ReviewSource>(ReviewSource.values);
}

class ReviewRecordsCompanion extends UpdateCompanion<ReviewRecord> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<DateTime> reviewedAt;
  final Value<ReviewOutcome> outcome;
  final Value<bool> isBonus;
  final Value<int?> stepBefore;
  final Value<int?> stepAfter;
  final Value<CardState?> stateAfter;
  final Value<DateTime?> dueAtAfter;
  final Value<ReviewSource> source;
  const ReviewRecordsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.isBonus = const Value.absent(),
    this.stepBefore = const Value.absent(),
    this.stepAfter = const Value.absent(),
    this.stateAfter = const Value.absent(),
    this.dueAtAfter = const Value.absent(),
    this.source = const Value.absent(),
  });
  ReviewRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required DateTime reviewedAt,
    required ReviewOutcome outcome,
    required bool isBonus,
    this.stepBefore = const Value.absent(),
    this.stepAfter = const Value.absent(),
    this.stateAfter = const Value.absent(),
    this.dueAtAfter = const Value.absent(),
    required ReviewSource source,
  }) : cardId = Value(cardId),
       reviewedAt = Value(reviewedAt),
       outcome = Value(outcome),
       isBonus = Value(isBonus),
       source = Value(source);
  static Insertable<ReviewRecord> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<DateTime>? reviewedAt,
    Expression<String>? outcome,
    Expression<bool>? isBonus,
    Expression<int>? stepBefore,
    Expression<int>? stepAfter,
    Expression<String>? stateAfter,
    Expression<DateTime>? dueAtAfter,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (outcome != null) 'outcome': outcome,
      if (isBonus != null) 'is_bonus': isBonus,
      if (stepBefore != null) 'step_before': stepBefore,
      if (stepAfter != null) 'step_after': stepAfter,
      if (stateAfter != null) 'state_after': stateAfter,
      if (dueAtAfter != null) 'due_at_after': dueAtAfter,
      if (source != null) 'source': source,
    });
  }

  ReviewRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<DateTime>? reviewedAt,
    Value<ReviewOutcome>? outcome,
    Value<bool>? isBonus,
    Value<int?>? stepBefore,
    Value<int?>? stepAfter,
    Value<CardState?>? stateAfter,
    Value<DateTime?>? dueAtAfter,
    Value<ReviewSource>? source,
  }) {
    return ReviewRecordsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      outcome: outcome ?? this.outcome,
      isBonus: isBonus ?? this.isBonus,
      stepBefore: stepBefore ?? this.stepBefore,
      stepAfter: stepAfter ?? this.stepAfter,
      stateAfter: stateAfter ?? this.stateAfter,
      dueAtAfter: dueAtAfter ?? this.dueAtAfter,
      source: source ?? this.source,
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
    if (stateAfter.present) {
      map['state_after'] = Variable<String>(
        $ReviewRecordsTable.$converterstateAftern.toSql(stateAfter.value),
      );
    }
    if (dueAtAfter.present) {
      map['due_at_after'] = Variable<DateTime>(dueAtAfter.value);
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
          ..write('cardId: $cardId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('outcome: $outcome, ')
          ..write('isBonus: $isBonus, ')
          ..write('stepBefore: $stepBefore, ')
          ..write('stepAfter: $stepAfter, ')
          ..write('stateAfter: $stateAfter, ')
          ..write('dueAtAfter: $dueAtAfter, ')
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
  List<GeneratedColumn> get $columns => [id, cardId, remindAt, notifiedAt];
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
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
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
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
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
  final Value<int> cardId;
  final Value<DateTime> remindAt;
  final Value<DateTime?> notifiedAt;
  const ExtraRemindersCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.notifiedAt = const Value.absent(),
  });
  ExtraRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required DateTime remindAt,
    this.notifiedAt = const Value.absent(),
  }) : cardId = Value(cardId),
       remindAt = Value(remindAt);
  static Insertable<ExtraReminder> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<DateTime>? remindAt,
    Expression<DateTime>? notifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (remindAt != null) 'remind_at': remindAt,
      if (notifiedAt != null) 'notified_at': notifiedAt,
    });
  }

  ExtraRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<DateTime>? remindAt,
    Value<DateTime?>? notifiedAt,
  }) {
    return ExtraRemindersCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
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
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
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
          ..write('cardId: $cardId, ')
          ..write('remindAt: $remindAt, ')
          ..write('notifiedAt: $notifiedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AlambicDatabase extends GeneratedDatabase {
  _$AlambicDatabase(QueryExecutor e) : super(e);
  $AlambicDatabaseManager get managers => $AlambicDatabaseManager(this);
  late final $PresetsTable presets = $PresetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CardGroupsTable cardGroups = $CardGroupsTable(this);
  late final $DistillationsTable distillations = $DistillationsTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $ReviewRecordsTable reviewRecords = $ReviewRecordsTable(this);
  late final $ExtraRemindersTable extraReminders = $ExtraRemindersTable(this);
  late final Index flashcardsDueAt = Index(
    'flashcards_due_at',
    'CREATE INDEX flashcards_due_at ON flashcards (due_at)',
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
    distillations,
    flashcards,
    reviewRecords,
    extraReminders,
    flashcardsDueAt,
    reviewRecordsReviewedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('distillations', kind: UpdateKind.delete)],
    ),
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
      result: [TableUpdate('review_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
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
  required List<PresetInterval> intervals,
  required FailureBehavior failureBehavior,
});
typedef $$PresetsTableUpdateCompanionBuilder = PresetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<BuiltInPresetKey?> builtInKey,
  Value<List<PresetInterval>> intervals,
  Value<FailureBehavior> failureBehavior,
});

final class $$PresetsTableReferences
    extends BaseReferences<_$AlambicDatabase, $PresetsTable, Preset> {
  $$PresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AppSettingsTable, List<AppSettingsRow>>
  _appSettingsRefsTable(_$AlambicDatabase db) => MultiTypedResultKey.fromTable(
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
  _cardGroupsRefsTable(_$AlambicDatabase db) => MultiTypedResultKey.fromTable(
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
}

class $$PresetsTableFilterComposer
    extends Composer<_$AlambicDatabase, $PresetsTable> {
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
}

class $$PresetsTableOrderingComposer
    extends Composer<_$AlambicDatabase, $PresetsTable> {
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

  ColumnOrderings<String> get intervals => $composableBuilder(
    column: $table.intervals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureBehavior => $composableBuilder(
    column: $table.failureBehavior,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableAnnotationComposer
    extends Composer<_$AlambicDatabase, $PresetsTable> {
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

  GeneratedColumnWithTypeConverter<List<PresetInterval>, String>
  get intervals =>
      $composableBuilder(column: $table.intervals, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FailureBehavior, String>
  get failureBehavior => $composableBuilder(
    column: $table.failureBehavior,
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
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$AlambicDatabase,
          $PresetsTable,
          Preset,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (Preset, $$PresetsTableReferences),
          Preset,
          PrefetchHooks Function({bool appSettingsRefs, bool cardGroupsRefs})
        > {
  $$PresetsTableTableManager(_$AlambicDatabase db, $PresetsTable table)
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
                Value<List<PresetInterval>> intervals = const Value.absent(),
                Value<FailureBehavior> failureBehavior = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                name: name,
                builtInKey: builtInKey,
                intervals: intervals,
                failureBehavior: failureBehavior,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<BuiltInPresetKey?> builtInKey = const Value.absent(),
                required List<PresetInterval> intervals,
                required FailureBehavior failureBehavior,
              }) => PresetsCompanion.insert(
                id: id,
                name: name,
                builtInKey: builtInKey,
                intervals: intervals,
                failureBehavior: failureBehavior,
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
              ({appSettingsRefs = false, cardGroupsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (appSettingsRefs) db.appSettings,
                    if (cardGroupsRefs) db.cardGroups,
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
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AlambicDatabase,
      $PresetsTable,
      Preset,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (Preset, $$PresetsTableReferences),
      Preset,
      PrefetchHooks Function({bool appSettingsRefs, bool cardGroupsRefs})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required int globalPresetId,
      Value<ScheduleKind> scheduleKind,
      Value<ClockTime> fixedTime,
      Value<ClockTime> rangeStart,
      Value<ClockTime> rangeEnd,
      Value<NotificationMode> notificationMode,
      Value<GroupedReminderAction> groupedAction,
      Value<int> dailyNotificationCap,
      Value<bool> quietHoursEnabled,
      Value<ClockTime> quietStart,
      Value<ClockTime> quietEnd,
      Value<bool> autoGroupEnabled,
      Value<int> autoGroupThreshold,
      Value<DateTime?> notifiedDay,
      Value<int> notifiedCount,
      Value<DateTime?> pausedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> globalPresetId,
      Value<ScheduleKind> scheduleKind,
      Value<ClockTime> fixedTime,
      Value<ClockTime> rangeStart,
      Value<ClockTime> rangeEnd,
      Value<NotificationMode> notificationMode,
      Value<GroupedReminderAction> groupedAction,
      Value<int> dailyNotificationCap,
      Value<bool> quietHoursEnabled,
      Value<ClockTime> quietStart,
      Value<ClockTime> quietEnd,
      Value<bool> autoGroupEnabled,
      Value<int> autoGroupThreshold,
      Value<DateTime?> notifiedDay,
      Value<int> notifiedCount,
      Value<DateTime?> pausedAt,
    });

final class $$AppSettingsTableReferences
    extends
        BaseReferences<_$AlambicDatabase, $AppSettingsTable, AppSettingsRow> {
  $$AppSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _globalPresetIdTable(_$AlambicDatabase db) =>
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
    extends Composer<_$AlambicDatabase, $AppSettingsTable> {
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

  ColumnFilters<int> get dailyNotificationCap => $composableBuilder(
    column: $table.dailyNotificationCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ClockTime, ClockTime, int> get quietStart =>
      $composableBuilder(
        column: $table.quietStart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ClockTime, ClockTime, int> get quietEnd =>
      $composableBuilder(
        column: $table.quietEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get autoGroupEnabled => $composableBuilder(
    column: $table.autoGroupEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoGroupThreshold => $composableBuilder(
    column: $table.autoGroupThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notifiedDay => $composableBuilder(
    column: $table.notifiedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifiedCount => $composableBuilder(
    column: $table.notifiedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
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
    extends Composer<_$AlambicDatabase, $AppSettingsTable> {
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

  ColumnOrderings<int> get dailyNotificationCap => $composableBuilder(
    column: $table.dailyNotificationCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietEnd => $composableBuilder(
    column: $table.quietEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoGroupEnabled => $composableBuilder(
    column: $table.autoGroupEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoGroupThreshold => $composableBuilder(
    column: $table.autoGroupThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notifiedDay => $composableBuilder(
    column: $table.notifiedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifiedCount => $composableBuilder(
    column: $table.notifiedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
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
    extends Composer<_$AlambicDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

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

  GeneratedColumn<int> get dailyNotificationCap => $composableBuilder(
    column: $table.dailyNotificationCap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ClockTime, int> get quietStart =>
      $composableBuilder(
        column: $table.quietStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ClockTime, int> get quietEnd =>
      $composableBuilder(column: $table.quietEnd, builder: (column) => column);

  GeneratedColumn<bool> get autoGroupEnabled => $composableBuilder(
    column: $table.autoGroupEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoGroupThreshold => $composableBuilder(
    column: $table.autoGroupThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get notifiedDay => $composableBuilder(
    column: $table.notifiedDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifiedCount => $composableBuilder(
    column: $table.notifiedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

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
          _$AlambicDatabase,
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
  $$AppSettingsTableTableManager(_$AlambicDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> globalPresetId = const Value.absent(),
                Value<ScheduleKind> scheduleKind = const Value.absent(),
                Value<ClockTime> fixedTime = const Value.absent(),
                Value<ClockTime> rangeStart = const Value.absent(),
                Value<ClockTime> rangeEnd = const Value.absent(),
                Value<NotificationMode> notificationMode = const Value.absent(),
                Value<GroupedReminderAction> groupedAction =
                    const Value.absent(),
                Value<int> dailyNotificationCap = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<ClockTime> quietStart = const Value.absent(),
                Value<ClockTime> quietEnd = const Value.absent(),
                Value<bool> autoGroupEnabled = const Value.absent(),
                Value<int> autoGroupThreshold = const Value.absent(),
                Value<DateTime?> notifiedDay = const Value.absent(),
                Value<int> notifiedCount = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                globalPresetId: globalPresetId,
                scheduleKind: scheduleKind,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                notificationMode: notificationMode,
                groupedAction: groupedAction,
                dailyNotificationCap: dailyNotificationCap,
                quietHoursEnabled: quietHoursEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                autoGroupEnabled: autoGroupEnabled,
                autoGroupThreshold: autoGroupThreshold,
                notifiedDay: notifiedDay,
                notifiedCount: notifiedCount,
                pausedAt: pausedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int globalPresetId,
                Value<ScheduleKind> scheduleKind = const Value.absent(),
                Value<ClockTime> fixedTime = const Value.absent(),
                Value<ClockTime> rangeStart = const Value.absent(),
                Value<ClockTime> rangeEnd = const Value.absent(),
                Value<NotificationMode> notificationMode = const Value.absent(),
                Value<GroupedReminderAction> groupedAction =
                    const Value.absent(),
                Value<int> dailyNotificationCap = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<ClockTime> quietStart = const Value.absent(),
                Value<ClockTime> quietEnd = const Value.absent(),
                Value<bool> autoGroupEnabled = const Value.absent(),
                Value<int> autoGroupThreshold = const Value.absent(),
                Value<DateTime?> notifiedDay = const Value.absent(),
                Value<int> notifiedCount = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                globalPresetId: globalPresetId,
                scheduleKind: scheduleKind,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                notificationMode: notificationMode,
                groupedAction: groupedAction,
                dailyNotificationCap: dailyNotificationCap,
                quietHoursEnabled: quietHoursEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                autoGroupEnabled: autoGroupEnabled,
                autoGroupThreshold: autoGroupThreshold,
                notifiedDay: notifiedDay,
                notifiedCount: notifiedCount,
                pausedAt: pausedAt,
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
      _$AlambicDatabase,
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
  Value<bool> reverseEnabled,
  Value<AfterLastStep> afterLastStep,
  Value<RemanenceInterval> remanenceInterval,
  Value<bool> typedAnswer,
  Value<DateTime?> pausedAt,
});
typedef $$CardGroupsTableUpdateCompanionBuilder = CardGroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> presetId,
  Value<DateTime> createdAt,
  Value<bool> reverseEnabled,
  Value<AfterLastStep> afterLastStep,
  Value<RemanenceInterval> remanenceInterval,
  Value<bool> typedAnswer,
  Value<DateTime?> pausedAt,
});

final class $$CardGroupsTableReferences
    extends BaseReferences<_$AlambicDatabase, $CardGroupsTable, CardGroup> {
  $$CardGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _presetIdTable(_$AlambicDatabase db) =>
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

  static MultiTypedResultKey<$DistillationsTable, List<Distillation>>
  _distillationsRefsTable(_$AlambicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.distillations,
        aliasName: 'card_groups__id__distillations__group_id',
      );

  $$DistillationsTableProcessedTableManager get distillationsRefs {
    final manager = $$DistillationsTableTableManager(
      $_db,
      $_db.distillations,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_distillationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AlambicDatabase db) => MultiTypedResultKey.fromTable(
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
    extends Composer<_$AlambicDatabase, $CardGroupsTable> {
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

  ColumnFilters<bool> get reverseEnabled => $composableBuilder(
    column: $table.reverseEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AfterLastStep, AfterLastStep, String>
  get afterLastStep => $composableBuilder(
    column: $table.afterLastStep,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<RemanenceInterval, RemanenceInterval, String>
  get remanenceInterval => $composableBuilder(
    column: $table.remanenceInterval,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
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

  Expression<bool> distillationsRefs(
    Expression<bool> Function($$DistillationsTableFilterComposer f) f,
  ) {
    final $$DistillationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distillations,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistillationsTableFilterComposer(
            $db: $db,
            $table: $db.distillations,
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
    extends Composer<_$AlambicDatabase, $CardGroupsTable> {
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

  ColumnOrderings<bool> get reverseEnabled => $composableBuilder(
    column: $table.reverseEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterLastStep => $composableBuilder(
    column: $table.afterLastStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remanenceInterval => $composableBuilder(
    column: $table.remanenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
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
    extends Composer<_$AlambicDatabase, $CardGroupsTable> {
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

  GeneratedColumn<bool> get reverseEnabled => $composableBuilder(
    column: $table.reverseEnabled,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AfterLastStep, String> get afterLastStep =>
      $composableBuilder(
        column: $table.afterLastStep,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<RemanenceInterval, String>
  get remanenceInterval => $composableBuilder(
    column: $table.remanenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get typedAnswer => $composableBuilder(
    column: $table.typedAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

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

  Expression<T> distillationsRefs<T extends Object>(
    Expression<T> Function($$DistillationsTableAnnotationComposer a) f,
  ) {
    final $$DistillationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distillations,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistillationsTableAnnotationComposer(
            $db: $db,
            $table: $db.distillations,
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
          _$AlambicDatabase,
          $CardGroupsTable,
          CardGroup,
          $$CardGroupsTableFilterComposer,
          $$CardGroupsTableOrderingComposer,
          $$CardGroupsTableAnnotationComposer,
          $$CardGroupsTableCreateCompanionBuilder,
          $$CardGroupsTableUpdateCompanionBuilder,
          (CardGroup, $$CardGroupsTableReferences),
          CardGroup,
          PrefetchHooks Function({
            bool presetId,
            bool distillationsRefs,
            bool flashcardsRefs,
          })
        > {
  $$CardGroupsTableTableManager(_$AlambicDatabase db, $CardGroupsTable table)
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
                Value<bool> reverseEnabled = const Value.absent(),
                Value<AfterLastStep> afterLastStep = const Value.absent(),
                Value<RemanenceInterval> remanenceInterval =
                    const Value.absent(),
                Value<bool> typedAnswer = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
              }) => CardGroupsCompanion(
                id: id,
                name: name,
                presetId: presetId,
                createdAt: createdAt,
                reverseEnabled: reverseEnabled,
                afterLastStep: afterLastStep,
                remanenceInterval: remanenceInterval,
                typedAnswer: typedAnswer,
                pausedAt: pausedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> presetId = const Value.absent(),
                required DateTime createdAt,
                Value<bool> reverseEnabled = const Value.absent(),
                Value<AfterLastStep> afterLastStep = const Value.absent(),
                Value<RemanenceInterval> remanenceInterval =
                    const Value.absent(),
                Value<bool> typedAnswer = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
              }) => CardGroupsCompanion.insert(
                id: id,
                name: name,
                presetId: presetId,
                createdAt: createdAt,
                reverseEnabled: reverseEnabled,
                afterLastStep: afterLastStep,
                remanenceInterval: remanenceInterval,
                typedAnswer: typedAnswer,
                pausedAt: pausedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardGroupsTable, CardGroup>(table),
                  $$CardGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                presetId = false,
                distillationsRefs = false,
                flashcardsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (distillationsRefs) db.distillations,
                    if (flashcardsRefs) db.flashcards,
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
                      if (distillationsRefs)
                        await $_getPrefetchedDataByColumns<
                          CardGroup,
                          $CardGroupsTable,
                          Distillation,
                          $DistillationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CardGroupsTableReferences
                              ._distillationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).distillationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
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
      _$AlambicDatabase,
      $CardGroupsTable,
      CardGroup,
      $$CardGroupsTableFilterComposer,
      $$CardGroupsTableOrderingComposer,
      $$CardGroupsTableAnnotationComposer,
      $$CardGroupsTableCreateCompanionBuilder,
      $$CardGroupsTableUpdateCompanionBuilder,
      (CardGroup, $$CardGroupsTableReferences),
      CardGroup,
      PrefetchHooks Function({
        bool presetId,
        bool distillationsRefs,
        bool flashcardsRefs,
      })
    >;
typedef $$DistillationsTableCreateCompanionBuilder =
    DistillationsCompanion Function({
      Value<int> groupId,
      required int cardsPerBatch,
      required int everyDays,
      required bool prioritizeReviews,
      required DistillationStatus status,
      required DateTime startedAt,
      Value<DateTime?> lastBatchDay,
      Value<DateTime?> lastAdvancedDay,
    });
typedef $$DistillationsTableUpdateCompanionBuilder =
    DistillationsCompanion Function({
      Value<int> groupId,
      Value<int> cardsPerBatch,
      Value<int> everyDays,
      Value<bool> prioritizeReviews,
      Value<DistillationStatus> status,
      Value<DateTime> startedAt,
      Value<DateTime?> lastBatchDay,
      Value<DateTime?> lastAdvancedDay,
    });

final class $$DistillationsTableReferences
    extends
        BaseReferences<_$AlambicDatabase, $DistillationsTable, Distillation> {
  $$DistillationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardGroupsTable _groupIdTable(_$AlambicDatabase db) =>
      db.cardGroups.createAlias('distillations__group_id__card_groups__id');

  $$CardGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

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
}

class $$DistillationsTableFilterComposer
    extends Composer<_$AlambicDatabase, $DistillationsTable> {
  $$DistillationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cardsPerBatch => $composableBuilder(
    column: $table.cardsPerBatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get everyDays => $composableBuilder(
    column: $table.everyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get prioritizeReviews => $composableBuilder(
    column: $table.prioritizeReviews,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DistillationStatus, DistillationStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBatchDay => $composableBuilder(
    column: $table.lastBatchDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAdvancedDay => $composableBuilder(
    column: $table.lastAdvancedDay,
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
}

class $$DistillationsTableOrderingComposer
    extends Composer<_$AlambicDatabase, $DistillationsTable> {
  $$DistillationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cardsPerBatch => $composableBuilder(
    column: $table.cardsPerBatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyDays => $composableBuilder(
    column: $table.everyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get prioritizeReviews => $composableBuilder(
    column: $table.prioritizeReviews,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBatchDay => $composableBuilder(
    column: $table.lastBatchDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAdvancedDay => $composableBuilder(
    column: $table.lastAdvancedDay,
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
}

class $$DistillationsTableAnnotationComposer
    extends Composer<_$AlambicDatabase, $DistillationsTable> {
  $$DistillationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cardsPerBatch => $composableBuilder(
    column: $table.cardsPerBatch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get everyDays =>
      $composableBuilder(column: $table.everyDays, builder: (column) => column);

  GeneratedColumn<bool> get prioritizeReviews => $composableBuilder(
    column: $table.prioritizeReviews,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DistillationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBatchDay => $composableBuilder(
    column: $table.lastBatchDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAdvancedDay => $composableBuilder(
    column: $table.lastAdvancedDay,
    builder: (column) => column,
  );

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
}

class $$DistillationsTableTableManager
    extends
        RootTableManager<
          _$AlambicDatabase,
          $DistillationsTable,
          Distillation,
          $$DistillationsTableFilterComposer,
          $$DistillationsTableOrderingComposer,
          $$DistillationsTableAnnotationComposer,
          $$DistillationsTableCreateCompanionBuilder,
          $$DistillationsTableUpdateCompanionBuilder,
          (Distillation, $$DistillationsTableReferences),
          Distillation,
          PrefetchHooks Function({bool groupId})
        > {
  $$DistillationsTableTableManager(
    _$AlambicDatabase db,
    $DistillationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistillationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistillationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistillationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<int> cardsPerBatch = const Value.absent(),
                Value<int> everyDays = const Value.absent(),
                Value<bool> prioritizeReviews = const Value.absent(),
                Value<DistillationStatus> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> lastBatchDay = const Value.absent(),
                Value<DateTime?> lastAdvancedDay = const Value.absent(),
              }) => DistillationsCompanion(
                groupId: groupId,
                cardsPerBatch: cardsPerBatch,
                everyDays: everyDays,
                prioritizeReviews: prioritizeReviews,
                status: status,
                startedAt: startedAt,
                lastBatchDay: lastBatchDay,
                lastAdvancedDay: lastAdvancedDay,
              ),
          createCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                required int cardsPerBatch,
                required int everyDays,
                required bool prioritizeReviews,
                required DistillationStatus status,
                required DateTime startedAt,
                Value<DateTime?> lastBatchDay = const Value.absent(),
                Value<DateTime?> lastAdvancedDay = const Value.absent(),
              }) => DistillationsCompanion.insert(
                groupId: groupId,
                cardsPerBatch: cardsPerBatch,
                everyDays: everyDays,
                prioritizeReviews: prioritizeReviews,
                status: status,
                startedAt: startedAt,
                lastBatchDay: lastBatchDay,
                lastAdvancedDay: lastAdvancedDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DistillationsTable, Distillation>(table),
                  $$DistillationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
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
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$DistillationsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$DistillationsTableReferences
                            ._groupIdTable(db)
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

typedef $$DistillationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AlambicDatabase,
      $DistillationsTable,
      Distillation,
      $$DistillationsTableFilterComposer,
      $$DistillationsTableOrderingComposer,
      $$DistillationsTableAnnotationComposer,
      $$DistillationsTableCreateCompanionBuilder,
      $$DistillationsTableUpdateCompanionBuilder,
      (Distillation, $$DistillationsTableReferences),
      Distillation,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  required int groupId,
  Value<String?> frontText,
  Value<String?> frontImagePath,
  Value<String?> backText,
  Value<String?> backImagePath,
  Value<bool> suspended,
  required DateTime createdAt,
  required CardState state,
  Value<int?> step,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<DateTime?> notifiedAt,
  Value<int?> queuePosition,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<int> groupId,
  Value<String?> frontText,
  Value<String?> frontImagePath,
  Value<String?> backText,
  Value<String?> backImagePath,
  Value<bool> suspended,
  Value<DateTime> createdAt,
  Value<CardState> state,
  Value<int?> step,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<DateTime?> notifiedAt,
  Value<int?> queuePosition,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AlambicDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardGroupsTable _groupIdTable(_$AlambicDatabase db) =>
      db.cardGroups.createAlias('flashcards__group_id__card_groups__id');

  $$CardGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

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

  static MultiTypedResultKey<$ReviewRecordsTable, List<ReviewRecord>>
  _reviewRecordsRefsTable(_$AlambicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reviewRecords,
        aliasName: 'flashcards__id__review_records__card_id',
      );

  $$ReviewRecordsTableProcessedTableManager get reviewRecordsRefs {
    final manager = $$ReviewRecordsTableTableManager(
      $_db,
      $_db.reviewRecords,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExtraRemindersTable, List<ExtraReminder>>
  _extraRemindersRefsTable(_$AlambicDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.extraReminders,
        aliasName: 'flashcards__id__extra_reminders__card_id',
      );

  $$ExtraRemindersTableProcessedTableManager get extraRemindersRefs {
    final manager = $$ExtraRemindersTableTableManager(
      $_db,
      $_db.extraReminders,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_extraRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AlambicDatabase, $FlashcardsTable> {
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

  ColumnWithTypeConverterFilters<CardState, CardState, String> get state =>
      $composableBuilder(
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

  ColumnFilters<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
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

  Expression<bool> reviewRecordsRefs(
    Expression<bool> Function($$ReviewRecordsTableFilterComposer f) f,
  ) {
    final $$ReviewRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.cardId,
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
      getReferencedColumn: (t) => t.cardId,
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

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AlambicDatabase, $FlashcardsTable> {
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

  ColumnOrderings<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
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
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AlambicDatabase, $FlashcardsTable> {
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

  GeneratedColumnWithTypeConverter<CardState, String> get state =>
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

  GeneratedColumn<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
    builder: (column) => column,
  );

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

  Expression<T> reviewRecordsRefs<T extends Object>(
    Expression<T> Function($$ReviewRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.cardId,
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
      getReferencedColumn: (t) => t.cardId,
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

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$AlambicDatabase,
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
            bool reviewRecordsRefs,
            bool extraRemindersRefs,
          })
        > {
  $$FlashcardsTableTableManager(_$AlambicDatabase db, $FlashcardsTable table)
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
                Value<int> groupId = const Value.absent(),
                Value<String?> frontText = const Value.absent(),
                Value<String?> frontImagePath = const Value.absent(),
                Value<String?> backText = const Value.absent(),
                Value<String?> backImagePath = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<CardState> state = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
                Value<int?> queuePosition = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                groupId: groupId,
                frontText: frontText,
                frontImagePath: frontImagePath,
                backText: backText,
                backImagePath: backImagePath,
                suspended: suspended,
                createdAt: createdAt,
                state: state,
                step: step,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                notifiedAt: notifiedAt,
                queuePosition: queuePosition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                Value<String?> frontText = const Value.absent(),
                Value<String?> frontImagePath = const Value.absent(),
                Value<String?> backText = const Value.absent(),
                Value<String?> backImagePath = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                required DateTime createdAt,
                required CardState state,
                Value<int?> step = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
                Value<int?> queuePosition = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                id: id,
                groupId: groupId,
                frontText: frontText,
                frontImagePath: frontImagePath,
                backText: backText,
                backImagePath: backImagePath,
                suspended: suspended,
                createdAt: createdAt,
                state: state,
                step: step,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                notifiedAt: notifiedAt,
                queuePosition: queuePosition,
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

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          Flashcard,
                          $FlashcardsTable,
                          ReviewRecord,
                          $ReviewRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._reviewRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'card_id',
                          typedResults: items,
                        ),
                      if (extraRemindersRefs)
                        await $_getPrefetchedDataByColumns<
                          Flashcard,
                          $FlashcardsTable,
                          ExtraReminder,
                          $ExtraRemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._extraRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).extraRemindersRefs,
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
      _$AlambicDatabase,
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
        bool reviewRecordsRefs,
        bool extraRemindersRefs,
      })
    >;
typedef $$ReviewRecordsTableCreateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      required int cardId,
      required DateTime reviewedAt,
      required ReviewOutcome outcome,
      required bool isBonus,
      Value<int?> stepBefore,
      Value<int?> stepAfter,
      Value<CardState?> stateAfter,
      Value<DateTime?> dueAtAfter,
      required ReviewSource source,
    });
typedef $$ReviewRecordsTableUpdateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<DateTime> reviewedAt,
      Value<ReviewOutcome> outcome,
      Value<bool> isBonus,
      Value<int?> stepBefore,
      Value<int?> stepAfter,
      Value<CardState?> stateAfter,
      Value<DateTime?> dueAtAfter,
      Value<ReviewSource> source,
    });

final class $$ReviewRecordsTableReferences
    extends
        BaseReferences<_$AlambicDatabase, $ReviewRecordsTable, ReviewRecord> {
  $$ReviewRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlashcardsTable _cardIdTable(_$AlambicDatabase db) =>
      db.flashcards.createAlias('review_records__card_id__flashcards__id');

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
}

class $$ReviewRecordsTableFilterComposer
    extends Composer<_$AlambicDatabase, $ReviewRecordsTable> {
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

  ColumnWithTypeConverterFilters<CardState?, CardState, String>
  get stateAfter => $composableBuilder(
    column: $table.stateAfter,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dueAtAfter => $composableBuilder(
    column: $table.dueAtAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewSource, ReviewSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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
}

class $$ReviewRecordsTableOrderingComposer
    extends Composer<_$AlambicDatabase, $ReviewRecordsTable> {
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

  ColumnOrderings<String> get stateAfter => $composableBuilder(
    column: $table.stateAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAtAfter => $composableBuilder(
    column: $table.dueAtAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
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

class $$ReviewRecordsTableAnnotationComposer
    extends Composer<_$AlambicDatabase, $ReviewRecordsTable> {
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

  GeneratedColumnWithTypeConverter<CardState?, String> get stateAfter =>
      $composableBuilder(
        column: $table.stateAfter,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get dueAtAfter => $composableBuilder(
    column: $table.dueAtAfter,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReviewSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

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
}

class $$ReviewRecordsTableTableManager
    extends
        RootTableManager<
          _$AlambicDatabase,
          $ReviewRecordsTable,
          ReviewRecord,
          $$ReviewRecordsTableFilterComposer,
          $$ReviewRecordsTableOrderingComposer,
          $$ReviewRecordsTableAnnotationComposer,
          $$ReviewRecordsTableCreateCompanionBuilder,
          $$ReviewRecordsTableUpdateCompanionBuilder,
          (ReviewRecord, $$ReviewRecordsTableReferences),
          ReviewRecord,
          PrefetchHooks Function({bool cardId})
        > {
  $$ReviewRecordsTableTableManager(
    _$AlambicDatabase db,
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
                Value<int> cardId = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<ReviewOutcome> outcome = const Value.absent(),
                Value<bool> isBonus = const Value.absent(),
                Value<int?> stepBefore = const Value.absent(),
                Value<int?> stepAfter = const Value.absent(),
                Value<CardState?> stateAfter = const Value.absent(),
                Value<DateTime?> dueAtAfter = const Value.absent(),
                Value<ReviewSource> source = const Value.absent(),
              }) => ReviewRecordsCompanion(
                id: id,
                cardId: cardId,
                reviewedAt: reviewedAt,
                outcome: outcome,
                isBonus: isBonus,
                stepBefore: stepBefore,
                stepAfter: stepAfter,
                stateAfter: stateAfter,
                dueAtAfter: dueAtAfter,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required DateTime reviewedAt,
                required ReviewOutcome outcome,
                required bool isBonus,
                Value<int?> stepBefore = const Value.absent(),
                Value<int?> stepAfter = const Value.absent(),
                Value<CardState?> stateAfter = const Value.absent(),
                Value<DateTime?> dueAtAfter = const Value.absent(),
                required ReviewSource source,
              }) => ReviewRecordsCompanion.insert(
                id: id,
                cardId: cardId,
                reviewedAt: reviewedAt,
                outcome: outcome,
                isBonus: isBonus,
                stepBefore: stepBefore,
                stepAfter: stepAfter,
                stateAfter: stateAfter,
                dueAtAfter: dueAtAfter,
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
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ReviewRecordsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ReviewRecordsTableReferences
                            ._cardIdTable(db)
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
      _$AlambicDatabase,
      $ReviewRecordsTable,
      ReviewRecord,
      $$ReviewRecordsTableFilterComposer,
      $$ReviewRecordsTableOrderingComposer,
      $$ReviewRecordsTableAnnotationComposer,
      $$ReviewRecordsTableCreateCompanionBuilder,
      $$ReviewRecordsTableUpdateCompanionBuilder,
      (ReviewRecord, $$ReviewRecordsTableReferences),
      ReviewRecord,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$ExtraRemindersTableCreateCompanionBuilder =
    ExtraRemindersCompanion Function({
      Value<int> id,
      required int cardId,
      required DateTime remindAt,
      Value<DateTime?> notifiedAt,
    });
typedef $$ExtraRemindersTableUpdateCompanionBuilder =
    ExtraRemindersCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<DateTime> remindAt,
      Value<DateTime?> notifiedAt,
    });

final class $$ExtraRemindersTableReferences
    extends
        BaseReferences<_$AlambicDatabase, $ExtraRemindersTable, ExtraReminder> {
  $$ExtraRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlashcardsTable _cardIdTable(_$AlambicDatabase db) =>
      db.flashcards.createAlias('extra_reminders__card_id__flashcards__id');

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
}

class $$ExtraRemindersTableFilterComposer
    extends Composer<_$AlambicDatabase, $ExtraRemindersTable> {
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
}

class $$ExtraRemindersTableOrderingComposer
    extends Composer<_$AlambicDatabase, $ExtraRemindersTable> {
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

class $$ExtraRemindersTableAnnotationComposer
    extends Composer<_$AlambicDatabase, $ExtraRemindersTable> {
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
}

class $$ExtraRemindersTableTableManager
    extends
        RootTableManager<
          _$AlambicDatabase,
          $ExtraRemindersTable,
          ExtraReminder,
          $$ExtraRemindersTableFilterComposer,
          $$ExtraRemindersTableOrderingComposer,
          $$ExtraRemindersTableAnnotationComposer,
          $$ExtraRemindersTableCreateCompanionBuilder,
          $$ExtraRemindersTableUpdateCompanionBuilder,
          (ExtraReminder, $$ExtraRemindersTableReferences),
          ExtraReminder,
          PrefetchHooks Function({bool cardId})
        > {
  $$ExtraRemindersTableTableManager(
    _$AlambicDatabase db,
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
                Value<int> cardId = const Value.absent(),
                Value<DateTime> remindAt = const Value.absent(),
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => ExtraRemindersCompanion(
                id: id,
                cardId: cardId,
                remindAt: remindAt,
                notifiedAt: notifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required DateTime remindAt,
                Value<DateTime?> notifiedAt = const Value.absent(),
              }) => ExtraRemindersCompanion.insert(
                id: id,
                cardId: cardId,
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
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ExtraRemindersTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ExtraRemindersTableReferences
                            ._cardIdTable(db)
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
      _$AlambicDatabase,
      $ExtraRemindersTable,
      ExtraReminder,
      $$ExtraRemindersTableFilterComposer,
      $$ExtraRemindersTableOrderingComposer,
      $$ExtraRemindersTableAnnotationComposer,
      $$ExtraRemindersTableCreateCompanionBuilder,
      $$ExtraRemindersTableUpdateCompanionBuilder,
      (ExtraReminder, $$ExtraRemindersTableReferences),
      ExtraReminder,
      PrefetchHooks Function({bool cardId})
    >;

class $AlambicDatabaseManager {
  final _$AlambicDatabase _db;
  $AlambicDatabaseManager(this._db);
  $$PresetsTableTableManager get presets =>
      $$PresetsTableTableManager(_db, _db.presets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CardGroupsTableTableManager get cardGroups =>
      $$CardGroupsTableTableManager(_db, _db.cardGroups);
  $$DistillationsTableTableManager get distillations =>
      $$DistillationsTableTableManager(_db, _db.distillations);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$ReviewRecordsTableTableManager get reviewRecords =>
      $$ReviewRecordsTableTableManager(_db, _db.reviewRecords);
  $$ExtraRemindersTableTableManager get extraReminders =>
      $$ExtraRemindersTableTableManager(_db, _db.extraReminders);
}
