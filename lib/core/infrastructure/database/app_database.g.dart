// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta =
      const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _clientVersionMeta =
      const VerificationMeta('clientVersion');
  @override
  late final GeneratedColumn<int> clientVersion = GeneratedColumn<int>(
      'client_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _statusMeta =
      const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _conflictStrategyMeta =
      const VerificationMeta('conflictStrategy');
  @override
  late final GeneratedColumn<String> conflictStrategy = GeneratedColumn<String>(
      'conflict_strategy', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, entityType, entityId, operation, payload, clientVersion, status, retryCount, errorMessage, conflictStrategy, createdAt, updatedAt, scheduledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _idMeta,
          id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
 else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
 else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    }
 else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
          _entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
 else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
          _operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    }
 else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
          _payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
 else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('client_version')) {
      context.handle(
          _clientVersionMeta,
          clientVersion.isAcceptableOrUnknown(data['client_version']!, _clientVersionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
          _statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('conflict_strategy')) {
      context.handle(
          _conflictStrategyMeta,
          conflictStrategy.isAcceptableOrUnknown(data['conflict_strategy']!, _conflictStrategyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
 else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(data['scheduled_at']!, _scheduledAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      clientVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_version'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      conflictStrategy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conflict_strategy']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final String id;
  final String tenantId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final int clientVersion;
  final String status;
  final int retryCount;
  final String? errorMessage;
  final String? conflictStrategy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  const SyncQueueItem({
    required String id,
    required String tenantId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int clientVersion,
    required String status,
    required int retryCount,
    String? errorMessage,
    String? conflictStrategy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? scheduledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['client_version'] = Variable<int>(clientVersion);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || conflictStrategy != null) {
      map['conflict_strategy'] = Variable<String>(conflictStrategy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      clientVersion: Value(clientVersion),
      status: Value(status),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      conflictStrategy: conflictStrategy == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictStrategy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<String>(json['id'])!,
      tenantId: serializer.fromJson<String>(json['tenantId'])!,
      entityType: serializer.fromJson<String>(json['entityType'])!,
      entityId: serializer.fromJson<String>(json['entityId'])!,
      operation: serializer.fromJson<String>(json['operation'])!,
      payload: serializer.fromJson<String>(json['payload'])!,
      clientVersion: serializer.fromJson<int>(json['clientVersion'])!,
      status: serializer.fromJson<String>(json['status'])!,
      retryCount: serializer.fromJson<int>(json['retryCount'])!,
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      conflictStrategy: serializer.fromJson<String?>(json['conflictStrategy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'clientVersion': serializer.toJson<int>(clientVersion),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'conflictStrategy': serializer.toJson<String?>(conflictStrategy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
    };
  }

  SyncQueueItem copyWith({
    String? id,
    String? tenantId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    int? clientVersion,
    String? status,
    int? retryCount,
    String?? errorMessage,
    String?? conflictStrategy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime?? scheduledAt,
  }) =>
      SyncQueueItem(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        clientVersion: clientVersion ?? this.clientVersion,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        errorMessage: errorMessage ?? this.errorMessage,
        conflictStrategy: conflictStrategy ?? this.conflictStrategy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        scheduledAt: scheduledAt ?? this.scheduledAt,
      );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientVersion: data.clientVersion.present ? data.clientVersion.value : this.clientVersion,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present ? data.errorMessage.value : this.errorMessage,
      conflictStrategy: data.conflictStrategy.present ? data.conflictStrategy.value : this.conflictStrategy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      scheduledAt: data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientVersion: $clientVersion, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('conflictStrategy: $conflictStrategy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.id, this.tenantId, this.entityType, this.entityId, this.operation, this.payload, this.clientVersion, this.status, this.retryCount, this.errorMessage, this.conflictStrategy, this.createdAt, this.updatedAt, this.scheduledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.clientVersion == this.clientVersion &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.conflictStrategy == this.conflictStrategy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.scheduledAt == this.scheduledAt);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> clientVersion;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String> errorMessage;
  final Value<String> conflictStrategy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> scheduledAt;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.conflictStrategy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    required String id,
    required String tenantId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    this.clientVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.conflictStrategy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.scheduledAt = const Value.absent(),
  })
      : id = Value(id),
        tenantId = Value(tenantId),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncQueueItem> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? clientVersion,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<String>? conflictStrategy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? scheduledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (clientVersion != null) 'client_version': clientVersion,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (conflictStrategy != null) 'conflict_strategy': conflictStrategy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
    });
  }

  SyncQueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? clientVersion,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String>? errorMessage,
    Value<String>? conflictStrategy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? scheduledAt,
  }) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      clientVersion: clientVersion ?? this.clientVersion,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      conflictStrategy: conflictStrategy ?? this.conflictStrategy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientVersion.present) {
      map['client_version'] = Variable<int>(clientVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = errorMessage.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(errorMessage.value);
    }
    if (conflictStrategy.present) {
      map['conflict_strategy'] = conflictStrategy.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(conflictStrategy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = scheduledAt.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<DateTime>(scheduledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientVersion: $clientVersion, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('conflictStrategy: $conflictStrategy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write(')'))
        .toString();
  }
}

class $SyncCheckpointsTable extends SyncCheckpoints
    with TableInfo<$SyncCheckpointsTable, SyncCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCheckpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta =
      const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lastVersionMeta =
      const VerificationMeta('lastVersion');
  @override
  late final GeneratedColumn<int> lastVersion = GeneratedColumn<int>(
      'last_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, deviceId, entityType, lastVersion, lastSyncedAt, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_checkpoints';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCheckpoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _idMeta,
          id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
 else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
 else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
          _deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
 else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    }
 else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_version')) {
      context.handle(
          _lastVersionMeta,
          lastVersion.isAcceptableOrUnknown(data['last_version']!, _lastVersionMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(data['last_synced_at']!, _lastSyncedAtMeta));
    }
 else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
 else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCheckpoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_version'])!,
      lastSyncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncCheckpointsTable createAlias(String alias) {
    return $SyncCheckpointsTable(attachedDatabase, alias);
  }
}

class SyncCheckpoint extends DataClass implements Insertable<SyncCheckpoint> {
  final String id;
  final String tenantId;
  final String deviceId;
  final String entityType;
  final int lastVersion;
  final DateTime lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncCheckpoint({
    required String id,
    required String tenantId,
    required String deviceId,
    required String entityType,
    required int lastVersion,
    required DateTime lastSyncedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['last_version'] = Variable<int>(lastVersion);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return SyncCheckpointsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      lastVersion: Value(lastVersion),
      lastSyncedAt: Value(lastSyncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCheckpoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCheckpoint(
      id: serializer.fromJson<String>(json['id'])!,
      tenantId: serializer.fromJson<String>(json['tenantId'])!,
      deviceId: serializer.fromJson<String>(json['deviceId'])!,
      entityType: serializer.fromJson<String>(json['entityType'])!,
      lastVersion: serializer.fromJson<int>(json['lastVersion'])!,
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt'])!,
      createdAt: serializer.fromJson<DateTime>(json['createdAt'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'lastVersion': serializer.toJson<int>(lastVersion),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCheckpoint copyWith({
    String? id,
    String? tenantId,
    String? deviceId,
    String? entityType,
    int? lastVersion,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      SyncCheckpoint(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        deviceId: deviceId ?? this.deviceId,
        entityType: entityType ?? this.entityType,
        lastVersion: lastVersion ?? this.lastVersion,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncCheckpoint copyWithCompanion(SyncCheckpointsCompanion data) {
    return SyncCheckpoint(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      lastVersion: data.lastVersion.present ? data.lastVersion.value : this.lastVersion,
      lastSyncedAt: data.lastSyncedAt.present ? data.lastSyncedAt.value : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('SyncCheckpoint(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('lastVersion: $lastVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.id, this.tenantId, this.deviceId, this.entityType, this.lastVersion, this.lastSyncedAt, this.createdAt, this.updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCheckpoint &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.lastVersion == this.lastVersion &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncCheckpointsCompanion extends UpdateCompanion<SyncCheckpoint> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<int> lastVersion;
  final Value<DateTime> lastSyncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SyncCheckpointsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.lastVersion = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncCheckpointsCompanion.insert({
    required String id,
    required String tenantId,
    required String deviceId,
    required String entityType,
    this.lastVersion = const Value.absent(),
    required DateTime lastSyncedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  })
      : id = Value(id),
        tenantId = Value(tenantId),
        deviceId = Value(deviceId),
        entityType = Value(entityType),
        lastSyncedAt = Value(lastSyncedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncCheckpoint> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<int>? lastVersion,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (lastVersion != null) 'last_version': lastVersion,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncCheckpointsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<int>? lastVersion,
    Value<DateTime>? lastSyncedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SyncCheckpointsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      lastVersion: lastVersion ?? this.lastVersion,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastVersion.present) {
      map['last_version'] = Variable<int>(lastVersion.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCheckpointsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('lastVersion: $lastVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs
    with TableInfo<$SyncLogsTable, SyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta =
      const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _levelMeta =
      const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, level, message, entityType, entityId, metadata, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SyncLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _idMeta,
          id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
 else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta,
          level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
 else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
          _messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
 else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    }
    if (data.containsKey('entity_id')) {
      context.handle(
          _entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(
          _metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
 else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type']),
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLog extends DataClass implements Insertable<SyncLog> {
  final String id;
  final String? tenantId;
  final String level;
  final String message;
  final String? entityType;
  final String? entityId;
  final String metadata;
  final DateTime createdAt;
  const SyncLog({
    required String id,
    String? tenantId,
    required String level,
    required String message,
    String? entityType,
    String? entityId,
    required String metadata,
    required DateTime createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || entityType != null) {
      map['entity_type'] = Variable<String>(entityType);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
      level: Value(level),
      message: Value(message),
      entityType: entityType == null && nullToAbsent
          ? const Value.absent()
          : Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory SyncLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLog(
      id: serializer.fromJson<String>(json['id'])!,
      tenantId: serializer.fromJson<String?>(json['tenantId']),
      level: serializer.fromJson<String>(json['level'])!,
      message: serializer.fromJson<String>(json['message'])!,
      entityType: serializer.fromJson<String?>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      metadata: serializer.fromJson<String>(json['metadata'])!,
      createdAt: serializer.fromJson<DateTime>(json['createdAt'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String?>(tenantId),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'entityType': serializer.toJson<String?>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncLog copyWith({
    String? id,
    String?? tenantId,
    String? level,
    String? message,
    String?? entityType,
    String?? entityId,
    String? metadata,
    DateTime? createdAt,
  }) =>
      SyncLog(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        level: level ?? this.level,
        message: message ?? this.message,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncLog copyWithCompanion(SyncLogsCompanion data) {
    return SyncLog(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('SyncLog(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.id, this.tenantId, this.level, this.message, this.entityType, this.entityId, this.metadata, this.createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLog &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.level == this.level &&
          other.message == this.message &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLog> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> level;
  final Value<String> message;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    required String id,
    this.tenantId = const Value.absent(),
    required String level,
    required String message,
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime createdAt,
  })
      : id = Value(id),
        level = Value(level),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<SyncLog> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? level,
    Expression<String>? message,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? level,
    Value<String>? message,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      level: level ?? this.level,
      message: message ?? this.message,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = tenantId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(tenantId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (entityType.present) {
      map['entity_type'] = entityType.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = entityId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(entityId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write(')'))
        .toString();
  }
}

class $AuthCacheEntriesTable extends AuthCacheEntries
    with TableInfo<$AuthCacheEntriesTable, AuthCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta =
      const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta =
      const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AuthCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta,
          key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
 else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta,
          value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
 else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AuthCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthCacheEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AuthCacheEntriesTable createAlias(String alias) {
    return $AuthCacheEntriesTable(attachedDatabase, alias);
  }
}

class AuthCacheEntry extends DataClass implements Insertable<AuthCacheEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AuthCacheEntry({
    required String key,
    required String value,
    required DateTime updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuthCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return AuthCacheEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AuthCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthCacheEntry(
      key: serializer.fromJson<String>(json['key'])!,
      value: serializer.fromJson<String>(json['value'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AuthCacheEntry copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) =>
      AuthCacheEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AuthCacheEntry copyWithCompanion(AuthCacheEntriesCompanion data) {
    return AuthCacheEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('AuthCacheEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.key, this.value, this.updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthCacheEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AuthCacheEntriesCompanion extends UpdateCompanion<AuthCacheEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  const AuthCacheEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AuthCacheEntriesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
  })
      : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AuthCacheEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AuthCacheEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
  }) {
    return AuthCacheEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthCacheEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings
    with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta =
      const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta =
      const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, tenantId, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta,
          key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
 else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
 else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta,
          value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
 else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  final String key;
  final String tenantId;
  final String value;
  final DateTime updatedAt;
  const LocalSetting({
    required String key,
    required String tenantId,
    required String value,
    required DateTime updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['tenant_id'] = Variable<String>(tenantId);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(
      key: Value(key),
      tenantId: Value(tenantId),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
      key: serializer.fromJson<String>(json['key'])!,
      tenantId: serializer.fromJson<String>(json['tenantId'])!,
      value: serializer.fromJson<String>(json['value'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'tenantId': serializer.toJson<String>(tenantId),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSetting copyWith({
    String? key,
    String? tenantId,
    String? value,
    DateTime? updatedAt,
  }) =>
      LocalSetting(
        key: key ?? this.key,
        tenantId: tenantId ?? this.tenantId,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
          ..write('key: $key, ')
          ..write('tenantId: $tenantId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.key, this.tenantId, this.value, this.updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetting &&
          other.key == this.key &&
          other.tenantId == this.tenantId &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> tenantId;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String tenantId,
    required String value,
    required DateTime updatedAt,
  })
      : key = Value(key),
        tenantId = Value(tenantId),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<LocalSetting> custom({
    Expression<String>? key,
    Expression<String>? tenantId,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (tenantId != null) 'tenant_id': tenantId,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? tenantId,
    Value<String>? value,
    Value<DateTime>? updatedAt,
  }) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      tenantId: tenantId ?? this.tenantId,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('tenantId: $tenantId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }
}

class $AuditLogEntriesTable extends AuditLogEntries
    with TableInfo<$AuditLogEntriesTable, AuditLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta =
      const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
      'employee_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _actionMeta =
      const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _oldValueMeta =
      const VerificationMeta('oldValue');
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
      'old_value', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _newValueMeta =
      const VerificationMeta('newValue');
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
      'new_value', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta =
      const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, storeId, employeeId, deviceId, action, entityType, entityId, oldValue, newValue, metadata, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _idMeta,
          id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
 else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
    if (data.containsKey('store_id')) {
      context.handle(
          _storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
          _deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(
          _actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    }
 else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    }
 else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
          _entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('old_value')) {
      context.handle(
          _oldValueMeta,
          oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta));
    }
    if (data.containsKey('new_value')) {
      context.handle(
          _newValueMeta,
          newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(
          _metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
 else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
          _syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id']),
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id']),
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}employee_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      oldValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}old_value']),
      newValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_value']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $AuditLogEntriesTable createAlias(String alias) {
    return $AuditLogEntriesTable(attachedDatabase, alias);
  }
}

class AuditLogEntry extends DataClass implements Insertable<AuditLogEntry> {
  final String id;
  final String? tenantId;
  final String? storeId;
  final String? employeeId;
  final String? deviceId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? oldValue;
  final String? newValue;
  final String metadata;
  final DateTime createdAt;
  final bool synced;
  const AuditLogEntry({
    required String id,
    String? tenantId,
    String? storeId,
    String? employeeId,
    String? deviceId,
    required String action,
    required String entityType,
    String? entityId,
    String? oldValue,
    String? newValue,
    required String metadata,
    required DateTime createdAt,
    required bool synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    if (!nullToAbsent || storeId != null) {
      map['store_id'] = Variable<String>(storeId);
    }
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<String>(employeeId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  AuditLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return AuditLogEntriesCompanion(
      id: Value(id),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
      storeId: storeId == null && nullToAbsent
          ? const Value.absent()
          : Value(storeId),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory AuditLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogEntry(
      id: serializer.fromJson<String>(json['id'])!,
      tenantId: serializer.fromJson<String?>(json['tenantId']),
      storeId: serializer.fromJson<String?>(json['storeId']),
      employeeId: serializer.fromJson<String?>(json['employeeId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      action: serializer.fromJson<String>(json['action'])!,
      entityType: serializer.fromJson<String>(json['entityType'])!,
      entityId: serializer.fromJson<String?>(json['entityId']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      metadata: serializer.fromJson<String>(json['metadata'])!,
      createdAt: serializer.fromJson<DateTime>(json['createdAt'])!,
      synced: serializer.fromJson<bool>(json['synced'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String?>(tenantId),
      'storeId': serializer.toJson<String?>(storeId),
      'employeeId': serializer.toJson<String?>(employeeId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  AuditLogEntry copyWith({
    String? id,
    String?? tenantId,
    String?? storeId,
    String?? employeeId,
    String?? deviceId,
    String? action,
    String? entityType,
    String?? entityId,
    String?? oldValue,
    String?? newValue,
    String? metadata,
    DateTime? createdAt,
    bool? synced,
  }) =>
      AuditLogEntry(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        storeId: storeId ?? this.storeId,
        employeeId: employeeId ?? this.employeeId,
        deviceId: deviceId ?? this.deviceId,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        oldValue: oldValue ?? this.oldValue,
        newValue: newValue ?? this.newValue,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  AuditLogEntry copyWithCompanion(AuditLogEntriesCompanion data) {
    return AuditLogEntry(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }
  @override
  String toString() {
    return (StringBuffer('AuditLogEntry(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('storeId: $storeId, ')
          ..write('employeeId: $employeeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.id, this.tenantId, this.storeId, this.employeeId, this.deviceId, this.action, this.entityType, this.entityId, this.oldValue, this.newValue, this.metadata, this.createdAt, this.synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogEntry &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.storeId == this.storeId &&
          other.employeeId == this.employeeId &&
          other.deviceId == this.deviceId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class AuditLogEntriesCompanion extends UpdateCompanion<AuditLogEntry> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> storeId;
  final Value<String> employeeId;
  final Value<String> deviceId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> oldValue;
  final Value<String> newValue;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const AuditLogEntriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  AuditLogEntriesCompanion.insert({
    required String id,
    this.tenantId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
  })
      : id = Value(id),
        action = Value(action),
        entityType = Value(entityType),
        createdAt = Value(createdAt);
  static Insertable<AuditLogEntry> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? storeId,
    Expression<String>? employeeId,
    Expression<String>? deviceId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (storeId != null) 'store_id': storeId,
      if (employeeId != null) 'employee_id': employeeId,
      if (deviceId != null) 'device_id': deviceId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  AuditLogEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? storeId,
    Value<String>? employeeId,
    Value<String>? deviceId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? oldValue,
    Value<String>? newValue,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return AuditLogEntriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      employeeId: employeeId ?? this.employeeId,
      deviceId: deviceId ?? this.deviceId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = tenantId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(tenantId.value);
    }
    if (storeId.present) {
      map['store_id'] = storeId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(storeId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = employeeId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(employeeId.value);
    }
    if (deviceId.present) {
      map['device_id'] = deviceId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(deviceId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = entityId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(entityId.value);
    }
    if (oldValue.present) {
      map['old_value'] = oldValue.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = newValue.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(newValue.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('storeId: $storeId, ')
          ..write('employeeId: $employeeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write(')'))
        .toString();
  }
}

class $LicenseCacheEntriesTable extends LicenseCacheEntries
    with TableInfo<$LicenseCacheEntriesTable, LicenseCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenseCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _licenseTypeMeta =
      const VerificationMeta('licenseType');
  @override
  late final GeneratedColumn<String> licenseType = GeneratedColumn<String>(
      'license_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _statusMeta =
      const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _validUntilMeta =
      const VerificationMeta('validUntil');
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
      'valid_until', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  static const VerificationMeta _lastValidatedAtMeta =
      const VerificationMeta('lastValidatedAt');
  @override
  late final GeneratedColumn<DateTime> lastValidatedAt = GeneratedColumn<DateTime>(
      'last_validated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _gracePeriodEndsAtMeta =
      const VerificationMeta('gracePeriodEndsAt');
  @override
  late final GeneratedColumn<DateTime> gracePeriodEndsAt = GeneratedColumn<DateTime>(
      'grace_period_ends_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [tenantId, licenseType, status, validUntil, lastValidatedAt, gracePeriodEndsAt, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LicenseCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
 else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('license_type')) {
      context.handle(
          _licenseTypeMeta,
          licenseType.isAcceptableOrUnknown(data['license_type']!, _licenseTypeMeta));
    }
 else if (isInserting) {
      context.missing(_licenseTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
          _statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
 else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
          _validUntilMeta,
          validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta));
    }
    if (data.containsKey('last_validated_at')) {
      context.handle(
          _lastValidatedAtMeta,
          lastValidatedAt.isAcceptableOrUnknown(data['last_validated_at']!, _lastValidatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_lastValidatedAtMeta);
    }
    if (data.containsKey('grace_period_ends_at')) {
      context.handle(
          _gracePeriodEndsAtMeta,
          gracePeriodEndsAt.isAcceptableOrUnknown(data['grace_period_ends_at']!, _gracePeriodEndsAtMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
          _payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId};
  @override
  LicenseCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenseCacheEntry(
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      licenseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      validUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_until']),
      lastValidatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_validated_at'])!,
      gracePeriodEndsAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}grace_period_ends_at']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
    );
  }

  @override
  $LicenseCacheEntriesTable createAlias(String alias) {
    return $LicenseCacheEntriesTable(attachedDatabase, alias);
  }
}

class LicenseCacheEntry extends DataClass implements Insertable<LicenseCacheEntry> {
  final String tenantId;
  final String licenseType;
  final String status;
  final DateTime? validUntil;
  final DateTime lastValidatedAt;
  final DateTime? gracePeriodEndsAt;
  final String payload;
  const LicenseCacheEntry({
    required String tenantId,
    required String licenseType,
    required String status,
    DateTime? validUntil,
    required DateTime lastValidatedAt,
    DateTime? gracePeriodEndsAt,
    required String payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    map['license_type'] = Variable<String>(licenseType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<DateTime>(validUntil);
    }
    map['last_validated_at'] = Variable<DateTime>(lastValidatedAt);
    if (!nullToAbsent || gracePeriodEndsAt != null) {
      map['grace_period_ends_at'] = Variable<DateTime>(gracePeriodEndsAt);
    }
    map['payload'] = Variable<String>(payload);
    return map;
  }

  LicenseCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return LicenseCacheEntriesCompanion(
      tenantId: Value(tenantId),
      licenseType: Value(licenseType),
      status: Value(status),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      lastValidatedAt: Value(lastValidatedAt),
      gracePeriodEndsAt: gracePeriodEndsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(gracePeriodEndsAt),
      payload: Value(payload),
    );
  }

  factory LicenseCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenseCacheEntry(
      tenantId: serializer.fromJson<String>(json['tenantId'])!,
      licenseType: serializer.fromJson<String>(json['licenseType'])!,
      status: serializer.fromJson<String>(json['status'])!,
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
      lastValidatedAt: serializer.fromJson<DateTime>(json['lastValidatedAt'])!,
      gracePeriodEndsAt: serializer.fromJson<DateTime?>(json['gracePeriodEndsAt']),
      payload: serializer.fromJson<String>(json['payload'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'licenseType': serializer.toJson<String>(licenseType),
      'status': serializer.toJson<String>(status),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
      'lastValidatedAt': serializer.toJson<DateTime>(lastValidatedAt),
      'gracePeriodEndsAt': serializer.toJson<DateTime?>(gracePeriodEndsAt),
      'payload': serializer.toJson<String>(payload),
    };
  }

  LicenseCacheEntry copyWith({
    String? tenantId,
    String? licenseType,
    String? status,
    DateTime?? validUntil,
    DateTime? lastValidatedAt,
    DateTime?? gracePeriodEndsAt,
    String? payload,
  }) =>
      LicenseCacheEntry(
        tenantId: tenantId ?? this.tenantId,
        licenseType: licenseType ?? this.licenseType,
        status: status ?? this.status,
        validUntil: validUntil ?? this.validUntil,
        lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
        gracePeriodEndsAt: gracePeriodEndsAt ?? this.gracePeriodEndsAt,
        payload: payload ?? this.payload,
      );
  LicenseCacheEntry copyWithCompanion(LicenseCacheEntriesCompanion data) {
    return LicenseCacheEntry(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      licenseType: data.licenseType.present ? data.licenseType.value : this.licenseType,
      status: data.status.present ? data.status.value : this.status,
      validUntil: data.validUntil.present ? data.validUntil.value : this.validUntil,
      lastValidatedAt: data.lastValidatedAt.present ? data.lastValidatedAt.value : this.lastValidatedAt,
      gracePeriodEndsAt: data.gracePeriodEndsAt.present ? data.gracePeriodEndsAt.value : this.gracePeriodEndsAt,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }
  @override
  String toString() {
    return (StringBuffer('LicenseCacheEntry(')
          ..write('tenantId: $tenantId, ')
          ..write('licenseType: $licenseType, ')
          ..write('status: $status, ')
          ..write('validUntil: $validUntil, ')
          ..write('lastValidatedAt: $lastValidatedAt, ')
          ..write('gracePeriodEndsAt: $gracePeriodEndsAt, ')
          ..write('payload: $payload, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.tenantId, this.licenseType, this.status, this.validUntil, this.lastValidatedAt, this.gracePeriodEndsAt, this.payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenseCacheEntry &&
          other.tenantId == this.tenantId &&
          other.licenseType == this.licenseType &&
          other.status == this.status &&
          other.validUntil == this.validUntil &&
          other.lastValidatedAt == this.lastValidatedAt &&
          other.gracePeriodEndsAt == this.gracePeriodEndsAt &&
          other.payload == this.payload);
}

class LicenseCacheEntriesCompanion extends UpdateCompanion<LicenseCacheEntry> {
  final Value<String> tenantId;
  final Value<String> licenseType;
  final Value<String> status;
  final Value<DateTime> validUntil;
  final Value<DateTime> lastValidatedAt;
  final Value<DateTime> gracePeriodEndsAt;
  final Value<String> payload;
  const LicenseCacheEntriesCompanion({
    this.tenantId = const Value.absent(),
    this.licenseType = const Value.absent(),
    this.status = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.lastValidatedAt = const Value.absent(),
    this.gracePeriodEndsAt = const Value.absent(),
    this.payload = const Value.absent(),
  });
  LicenseCacheEntriesCompanion.insert({
    required String tenantId,
    required String licenseType,
    required String status,
    this.validUntil = const Value.absent(),
    required DateTime lastValidatedAt,
    this.gracePeriodEndsAt = const Value.absent(),
    this.payload = const Value.absent(),
  })
      : tenantId = Value(tenantId),
        licenseType = Value(licenseType),
        status = Value(status),
        lastValidatedAt = Value(lastValidatedAt);
  static Insertable<LicenseCacheEntry> custom({
    Expression<String>? tenantId,
    Expression<String>? licenseType,
    Expression<String>? status,
    Expression<DateTime>? validUntil,
    Expression<DateTime>? lastValidatedAt,
    Expression<DateTime>? gracePeriodEndsAt,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (licenseType != null) 'license_type': licenseType,
      if (status != null) 'status': status,
      if (validUntil != null) 'valid_until': validUntil,
      if (lastValidatedAt != null) 'last_validated_at': lastValidatedAt,
      if (gracePeriodEndsAt != null) 'grace_period_ends_at': gracePeriodEndsAt,
      if (payload != null) 'payload': payload,
    });
  }

  LicenseCacheEntriesCompanion copyWith({
    Value<String>? tenantId,
    Value<String>? licenseType,
    Value<String>? status,
    Value<DateTime>? validUntil,
    Value<DateTime>? lastValidatedAt,
    Value<DateTime>? gracePeriodEndsAt,
    Value<String>? payload,
  }) {
    return LicenseCacheEntriesCompanion(
      tenantId: tenantId ?? this.tenantId,
      licenseType: licenseType ?? this.licenseType,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      gracePeriodEndsAt: gracePeriodEndsAt ?? this.gracePeriodEndsAt,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (licenseType.present) {
      map['license_type'] = Variable<String>(licenseType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (validUntil.present) {
      map['valid_until'] = validUntil.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<DateTime>(validUntil.value);
    }
    if (lastValidatedAt.present) {
      map['last_validated_at'] = Variable<DateTime>(lastValidatedAt.value);
    }
    if (gracePeriodEndsAt.present) {
      map['grace_period_ends_at'] = gracePeriodEndsAt.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<DateTime>(gracePeriodEndsAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenseCacheEntriesCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('licenseType: $licenseType, ')
          ..write('status: $status, ')
          ..write('validUntil: $validUntil, ')
          ..write('lastValidatedAt: $lastValidatedAt, ')
          ..write('gracePeriodEndsAt: $gracePeriodEndsAt, ')
          ..write('payload: $payload, ')
          ..write(')'))
        .toString();
  }
}

class $SyncableRecordsTable extends SyncableRecords
    with TableInfo<$SyncableRecordsTable, SyncableRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncableRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta =
      const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _searchNameMeta =
      const VerificationMeta('searchName');
  @override
  late final GeneratedColumn<String> searchName = GeneratedColumn<String>(
      'search_name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _searchSkuMeta =
      const VerificationMeta('searchSku');
  @override
  late final GeneratedColumn<String> searchSku = GeneratedColumn<String>(
      'search_sku', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _searchBarcodeMeta =
      const VerificationMeta('searchBarcode');
  @override
  late final GeneratedColumn<String> searchBarcode = GeneratedColumn<String>(
      'search_barcode', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, entityType, storeId, payload, version, createdAt, updatedAt, deletedAt, syncStatus, isDirty, searchName, searchSku, searchBarcode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'syncable_records';
  @override
  VerificationContext validateIntegrity(Insertable<SyncableRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _idMeta,
          id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
 else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
          _tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
 else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    }
 else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
          _storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
          _payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
 else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
          _versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
 else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
          _deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
          _isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('search_name')) {
      context.handle(
          _searchNameMeta,
          searchName.isAcceptableOrUnknown(data['search_name']!, _searchNameMeta));
    }
    if (data.containsKey('search_sku')) {
      context.handle(
          _searchSkuMeta,
          searchSku.isAcceptableOrUnknown(data['search_sku']!, _searchSkuMeta));
    }
    if (data.containsKey('search_barcode')) {
      context.handle(
          _searchBarcodeMeta,
          searchBarcode.isAcceptableOrUnknown(data['search_barcode']!, _searchBarcodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncableRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncableRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      searchName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_name']),
      searchSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_sku']),
      searchBarcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_barcode']),
    );
  }

  @override
  $SyncableRecordsTable createAlias(String alias) {
    return $SyncableRecordsTable(attachedDatabase, alias);
  }
}

class SyncableRecord extends DataClass implements Insertable<SyncableRecord> {
  final String id;
  final String tenantId;
  final String entityType;
  final String? storeId;
  final String payload;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final bool isDirty;
  final String? searchName;
  final String? searchSku;
  final String? searchBarcode;
  const SyncableRecord({
    required String id,
    required String tenantId,
    required String entityType,
    String? storeId,
    required String payload,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required String syncStatus,
    required bool isDirty,
    String? searchName,
    String? searchSku,
    String? searchBarcode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || storeId != null) {
      map['store_id'] = Variable<String>(storeId);
    }
    map['payload'] = Variable<String>(payload);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_dirty'] = Variable<bool>(isDirty);
    if (!nullToAbsent || searchName != null) {
      map['search_name'] = Variable<String>(searchName);
    }
    if (!nullToAbsent || searchSku != null) {
      map['search_sku'] = Variable<String>(searchSku);
    }
    if (!nullToAbsent || searchBarcode != null) {
      map['search_barcode'] = Variable<String>(searchBarcode);
    }
    return map;
  }

  SyncableRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncableRecordsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      entityType: Value(entityType),
      storeId: storeId == null && nullToAbsent
          ? const Value.absent()
          : Value(storeId),
      payload: Value(payload),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      isDirty: Value(isDirty),
      searchName: searchName == null && nullToAbsent
          ? const Value.absent()
          : Value(searchName),
      searchSku: searchSku == null && nullToAbsent
          ? const Value.absent()
          : Value(searchSku),
      searchBarcode: searchBarcode == null && nullToAbsent
          ? const Value.absent()
          : Value(searchBarcode),
    );
  }

  factory SyncableRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncableRecord(
      id: serializer.fromJson<String>(json['id'])!,
      tenantId: serializer.fromJson<String>(json['tenantId'])!,
      entityType: serializer.fromJson<String>(json['entityType'])!,
      storeId: serializer.fromJson<String?>(json['storeId']),
      payload: serializer.fromJson<String>(json['payload'])!,
      version: serializer.fromJson<int>(json['version'])!,
      createdAt: serializer.fromJson<DateTime>(json['createdAt'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus'])!,
      isDirty: serializer.fromJson<bool>(json['isDirty'])!,
      searchName: serializer.fromJson<String?>(json['searchName']),
      searchSku: serializer.fromJson<String?>(json['searchSku']),
      searchBarcode: serializer.fromJson<String?>(json['searchBarcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'entityType': serializer.toJson<String>(entityType),
      'storeId': serializer.toJson<String?>(storeId),
      'payload': serializer.toJson<String>(payload),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDirty': serializer.toJson<bool>(isDirty),
      'searchName': serializer.toJson<String?>(searchName),
      'searchSku': serializer.toJson<String?>(searchSku),
      'searchBarcode': serializer.toJson<String?>(searchBarcode),
    };
  }

  SyncableRecord copyWith({
    String? id,
    String? tenantId,
    String? entityType,
    String?? storeId,
    String? payload,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime?? deletedAt,
    String? syncStatus,
    bool? isDirty,
    String?? searchName,
    String?? searchSku,
    String?? searchBarcode,
  }) =>
      SyncableRecord(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        entityType: entityType ?? this.entityType,
        storeId: storeId ?? this.storeId,
        payload: payload ?? this.payload,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
        searchName: searchName ?? this.searchName,
        searchSku: searchSku ?? this.searchSku,
        searchBarcode: searchBarcode ?? this.searchBarcode,
      );
  SyncableRecord copyWithCompanion(SyncableRecordsCompanion data) {
    return SyncableRecord(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      payload: data.payload.present ? data.payload.value : this.payload,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      searchName: data.searchName.present ? data.searchName.value : this.searchName,
      searchSku: data.searchSku.present ? data.searchSku.value : this.searchSku,
      searchBarcode: data.searchBarcode.present ? data.searchBarcode.value : this.searchBarcode,
    );
  }
  @override
  String toString() {
    return (StringBuffer('SyncableRecord(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('storeId: $storeId, ')
          ..write('payload: $payload, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('searchName: $searchName, ')
          ..write('searchSku: $searchSku, ')
          ..write('searchBarcode: $searchBarcode, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.id, this.tenantId, this.entityType, this.storeId, this.payload, this.version, this.createdAt, this.updatedAt, this.deletedAt, this.syncStatus, this.isDirty, this.searchName, this.searchSku, this.searchBarcode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncableRecord &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.entityType == this.entityType &&
          other.storeId == this.storeId &&
          other.payload == this.payload &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.isDirty == this.isDirty &&
          other.searchName == this.searchName &&
          other.searchSku == this.searchSku &&
          other.searchBarcode == this.searchBarcode);
}

class SyncableRecordsCompanion extends UpdateCompanion<SyncableRecord> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> entityType;
  final Value<String> storeId;
  final Value<String> payload;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> deletedAt;
  final Value<String> syncStatus;
  final Value<bool> isDirty;
  final Value<String> searchName;
  final Value<String> searchSku;
  final Value<String> searchBarcode;
  const SyncableRecordsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.storeId = const Value.absent(),
    this.payload = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.searchName = const Value.absent(),
    this.searchSku = const Value.absent(),
    this.searchBarcode = const Value.absent(),
  });
  SyncableRecordsCompanion.insert({
    required String id,
    required String tenantId,
    required String entityType,
    this.storeId = const Value.absent(),
    required String payload,
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.searchName = const Value.absent(),
    this.searchSku = const Value.absent(),
    this.searchBarcode = const Value.absent(),
  })
      : id = Value(id),
        tenantId = Value(tenantId),
        entityType = Value(entityType),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncableRecord> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? entityType,
    Expression<String>? storeId,
    Expression<String>? payload,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<bool>? isDirty,
    Expression<String>? searchName,
    Expression<String>? searchSku,
    Expression<String>? searchBarcode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (entityType != null) 'entity_type': entityType,
      if (storeId != null) 'store_id': storeId,
      if (payload != null) 'payload': payload,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDirty != null) 'is_dirty': isDirty,
      if (searchName != null) 'search_name': searchName,
      if (searchSku != null) 'search_sku': searchSku,
      if (searchBarcode != null) 'search_barcode': searchBarcode,
    });
  }

  SyncableRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? entityType,
    Value<String>? storeId,
    Value<String>? payload,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? deletedAt,
    Value<String>? syncStatus,
    Value<bool>? isDirty,
    Value<String>? searchName,
    Value<String>? searchSku,
    Value<String>? searchBarcode,
  }) {
    return SyncableRecordsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      entityType: entityType ?? this.entityType,
      storeId: storeId ?? this.storeId,
      payload: payload ?? this.payload,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
      searchName: searchName ?? this.searchName,
      searchSku: searchSku ?? this.searchSku,
      searchBarcode: searchBarcode ?? this.searchBarcode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (storeId.present) {
      map['store_id'] = storeId.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(storeId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = deletedAt.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (searchName.present) {
      map['search_name'] = searchName.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(searchName.value);
    }
    if (searchSku.present) {
      map['search_sku'] = searchSku.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(searchSku.value);
    }
    if (searchBarcode.present) {
      map['search_barcode'] = searchBarcode.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<String>(searchBarcode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncableRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('storeId: $storeId, ')
          ..write('payload: $payload, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDirty: $isDirty, ')
          ..write('searchName: $searchName, ')
          ..write('searchSku: $searchSku, ')
          ..write('searchBarcode: $searchBarcode, ')
          ..write(')'))
        .toString();
  }
}

class $FeatureFlagEntriesTable extends FeatureFlagEntries
    with TableInfo<$FeatureFlagEntriesTable, FeatureFlagEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureFlagEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta =
      const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta =
      const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta =
      const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('remote'));
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [key, value, source, fetchedAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_flag_entries';
  @override
  VerificationContext validateIntegrity(Insertable<FeatureFlagEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta,
          key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
 else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta,
          value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
 else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
          _sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
          _fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    }
 else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
          _expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  FeatureFlagEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureFlagEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $FeatureFlagEntriesTable createAlias(String alias) {
    return $FeatureFlagEntriesTable(attachedDatabase, alias);
  }
}

class FeatureFlagEntry extends DataClass implements Insertable<FeatureFlagEntry> {
  final String key;
  final String value;
  final String source;
  final DateTime fetchedAt;
  final DateTime? expiresAt;
  const FeatureFlagEntry({
    required String key,
    required String value,
    required String source,
    required DateTime fetchedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  FeatureFlagEntriesCompanion toCompanion(bool nullToAbsent) {
    return FeatureFlagEntriesCompanion(
      key: Value(key),
      value: Value(value),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory FeatureFlagEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureFlagEntry(
      key: serializer.fromJson<String>(json['key'])!,
      value: serializer.fromJson<String>(json['value'])!,
      source: serializer.fromJson<String>(json['source'])!,
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt'])!,
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  FeatureFlagEntry copyWith({
    String? key,
    String? value,
    String? source,
    DateTime? fetchedAt,
    DateTime?? expiresAt,
  }) =>
      FeatureFlagEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        source: source ?? this.source,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  FeatureFlagEntry copyWithCompanion(FeatureFlagEntriesCompanion data) {
    return FeatureFlagEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('FeatureFlagEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.key, this.value, this.source, this.fetchedAt, this.expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureFlagEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class FeatureFlagEntriesCompanion extends UpdateCompanion<FeatureFlagEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> expiresAt;
  const FeatureFlagEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  FeatureFlagEntriesCompanion.insert({
    required String key,
    required String value,
    this.source = const Value.absent(),
    required DateTime fetchedAt,
    this.expiresAt = const Value.absent(),
  })
      : key = Value(key),
        value = Value(value),
        fetchedAt = Value(fetchedAt);
  static Insertable<FeatureFlagEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  FeatureFlagEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? expiresAt,
  }) {
    return FeatureFlagEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = expiresAt.value == null && nullToAbsent
          ? const Value.absent()
          : Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureFlagEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write(')'))
        .toString();
  }
}

class $AppRecoveryEntriesTable extends AppRecoveryEntries
    with TableInfo<$AppRecoveryEntriesTable, AppRecoveryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppRecoveryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta =
      const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta =
      const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_recovery_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AppRecoveryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta,
          key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
 else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta,
          value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
 else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
 else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppRecoveryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppRecoveryEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppRecoveryEntriesTable createAlias(String alias) {
    return $AppRecoveryEntriesTable(attachedDatabase, alias);
  }
}

class AppRecoveryEntry extends DataClass implements Insertable<AppRecoveryEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppRecoveryEntry({
    required String key,
    required String value,
    required DateTime updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppRecoveryEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppRecoveryEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppRecoveryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppRecoveryEntry(
      key: serializer.fromJson<String>(json['key'])!,
      value: serializer.fromJson<String>(json['value'])!,
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt'])!,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppRecoveryEntry copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) =>
      AppRecoveryEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppRecoveryEntry copyWithCompanion(AppRecoveryEntriesCompanion data) {
    return AppRecoveryEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('AppRecoveryEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(this.key, this.value, this.updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppRecoveryEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppRecoveryEntriesCompanion extends UpdateCompanion<AppRecoveryEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  const AppRecoveryEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppRecoveryEntriesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
  })
      : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppRecoveryEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppRecoveryEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
  }) {
    return AppRecoveryEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppRecoveryEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $SyncCheckpointsTable syncCheckpoints = $SyncCheckpointsTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $AuthCacheEntriesTable authCacheEntries = $AuthCacheEntriesTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final $AuditLogEntriesTable auditLogEntries = $AuditLogEntriesTable(this);
  late final $LicenseCacheEntriesTable licenseCacheEntries = $LicenseCacheEntriesTable(this);
  late final $SyncableRecordsTable syncableRecords = $SyncableRecordsTable(this);
  late final $FeatureFlagEntriesTable featureFlagEntries = $FeatureFlagEntriesTable(this);
  late final $AppRecoveryEntriesTable appRecoveryEntries = $AppRecoveryEntriesTable(this);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final SyncCheckpointDao syncCheckpointDao = SyncCheckpointDao(this as AppDatabase);
  late final SyncLogDao syncLogDao = SyncLogDao(this as AppDatabase);
  late final SyncableRecordDao syncableRecordDao = SyncableRecordDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final AuthCacheDao authCacheDao = AuthCacheDao(this as AppDatabase);
  late final AuditLogDao auditLogDao = AuditLogDao(this as AppDatabase);
  late final LicenseCacheDao licenseCacheDao = LicenseCacheDao(this as AppDatabase);
  late final FeatureFlagDao featureFlagDao = FeatureFlagDao(this as AppDatabase);
  late final RecoveryDao recoveryDao = RecoveryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        syncQueueItems,
        syncCheckpoints,
        syncLogs,
        authCacheEntries,
        localSettings,
        auditLogEntries,
        licenseCacheEntries,
        syncableRecords,
        featureFlagEntries,
        appRecoveryEntries,
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

mixin _$SyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQueueItemsTable get syncQueueItems =>
      attachedDatabase.syncQueueItems;
}

mixin _$SyncCheckpointDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncCheckpointsTable get syncCheckpoints =>
      attachedDatabase.syncCheckpoints;
}

mixin _$SyncLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncLogsTable get syncLogs =>
      attachedDatabase.syncLogs;
}

mixin _$SyncableRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncableRecordsTable get syncableRecords =>
      attachedDatabase.syncableRecords;
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalSettingsTable get localSettings =>
      attachedDatabase.localSettings;
}

mixin _$AuthCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuthCacheEntriesTable get authCacheEntries =>
      attachedDatabase.authCacheEntries;
}

mixin _$AuditLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuditLogEntriesTable get auditLogEntries =>
      attachedDatabase.auditLogEntries;
}

mixin _$LicenseCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $LicenseCacheEntriesTable get licenseCacheEntries =>
      attachedDatabase.licenseCacheEntries;
}

mixin _$FeatureFlagDaoMixin on DatabaseAccessor<AppDatabase> {
  $FeatureFlagEntriesTable get featureFlagEntries =>
      attachedDatabase.featureFlagEntries;
}

mixin _$RecoveryDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppRecoveryEntriesTable get appRecoveryEntries =>
      attachedDatabase.appRecoveryEntries;
}

typedef $$$SyncQueueItemsTableCreateCompanionBuilder = SyncQueueItemsCompanion Function({
  required String id,
  required String tenantId,
  required String entityType,
  required String entityId,
  required String operation,
  required String payload,
  Value<int> clientVersion,
  Value<String> status,
  Value<int> retryCount,
  Value<String> errorMessage,
  Value<String> conflictStrategy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime> scheduledAt,
});
typedef $$$SyncQueueItemsTableUpdateCompanionBuilder = SyncQueueItemsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payload,
  Value<int> clientVersion,
  Value<String> status,
  Value<int> retryCount,
  Value<String> errorMessage,
  Value<String> conflictStrategy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> scheduledAt,
});

class $$$SyncQueueItemsTableFilterComposer extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$$SyncQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get clientVersion => $composableBuilder(
      column: $table.clientVersion, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get conflictStrategy => $composableBuilder(
      column: $table.conflictStrategy, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));
}

class $$$SyncQueueItemsTableOrderingComposer extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$$SyncQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get clientVersion => $composableBuilder(
      column: $table.clientVersion, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get conflictStrategy => $composableBuilder(
      column: $table.conflictStrategy, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));
}

class $$$SyncQueueItemsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);
  GeneratedColumn get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);
  GeneratedColumn get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);
  GeneratedColumn get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
  GeneratedColumn get clientVersion =>
      $composableBuilder(column: $table.clientVersion, builder: (column) => column);
  GeneratedColumn get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
  GeneratedColumn get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => column);
  GeneratedColumn get errorMessage =>
      $composableBuilder(column: $table.errorMessage, builder: (column) => column);
  GeneratedColumn get conflictStrategy =>
      $composableBuilder(column: $table.conflictStrategy, builder: (column) => column);
  GeneratedColumn get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
  GeneratedColumn get scheduledAt =>
      $composableBuilder(column: $table.scheduledAt, builder: (column) => column);
}

class $$$SyncQueueItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$$SyncQueueItemsTableFilterComposer,
    $$$SyncQueueItemsTableOrderingComposer,
    $$$SyncQueueItemsTableAnnotationComposer,
    $$$SyncQueueItemsTableCreateCompanionBuilder,
    $$$SyncQueueItemsTableUpdateCompanionBuilder,
    (SyncQueueItem, BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$$SyncQueueItemsTableTableManager(_$AppDatabase db, $SyncQueueItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> clientVersion = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> errorMessage = const Value.absent(),
            Value<String> conflictStrategy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            clientVersion: clientVersion,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            conflictStrategy: conflictStrategy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String entityType,
            required String entityId,
            required String operation,
            required String payload,
            Value<int> clientVersion = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> errorMessage = const Value.absent(),
            Value<String> conflictStrategy = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime> scheduledAt = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion.insert(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            clientVersion: clientVersion,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            conflictStrategy: conflictStrategy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$SyncQueueItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$$SyncQueueItemsTableFilterComposer,
    $$$SyncQueueItemsTableOrderingComposer,
    $$$SyncQueueItemsTableAnnotationComposer,
    $$$SyncQueueItemsTableCreateCompanionBuilder,
    $$$SyncQueueItemsTableUpdateCompanionBuilder,
    (SyncQueueItem, BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>),
    SyncQueueItem,
    PrefetchHooks Function()>;

typedef $$$SyncCheckpointsTableCreateCompanionBuilder = SyncCheckpointsCompanion Function({
  required String id,
  required String tenantId,
  required String deviceId,
  required String entityType,
  Value<int> lastVersion,
  required DateTime lastSyncedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$$SyncCheckpointsTableUpdateCompanionBuilder = SyncCheckpointsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> deviceId,
  Value<String> entityType,
  Value<int> lastVersion,
  Value<DateTime> lastSyncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$$SyncCheckpointsTableFilterComposer extends Composer<_$AppDatabase, $SyncCheckpointsTable> {
  $$$SyncCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get lastVersion => $composableBuilder(
      column: $table.lastVersion, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$$SyncCheckpointsTableOrderingComposer extends Composer<_$AppDatabase, $SyncCheckpointsTable> {
  $$$SyncCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get lastVersion => $composableBuilder(
      column: $table.lastVersion, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$$SyncCheckpointsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncCheckpointsTable> {
  $$$SyncCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
  GeneratedColumn get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);
  GeneratedColumn get lastVersion =>
      $composableBuilder(column: $table.lastVersion, builder: (column) => column);
  GeneratedColumn get lastSyncedAt =>
      $composableBuilder(column: $table.lastSyncedAt, builder: (column) => column);
  GeneratedColumn get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$$SyncCheckpointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCheckpointsTable,
    SyncCheckpoint,
    $$$SyncCheckpointsTableFilterComposer,
    $$$SyncCheckpointsTableOrderingComposer,
    $$$SyncCheckpointsTableAnnotationComposer,
    $$$SyncCheckpointsTableCreateCompanionBuilder,
    $$$SyncCheckpointsTableUpdateCompanionBuilder,
    (SyncCheckpoint, BaseReferences<_$AppDatabase, $SyncCheckpointsTable, SyncCheckpoint>),
    SyncCheckpoint,
    PrefetchHooks Function()> {
  $$$SyncCheckpointsTableTableManager(_$AppDatabase db, $SyncCheckpointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$SyncCheckpointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$SyncCheckpointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$SyncCheckpointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int> lastVersion = const Value.absent(),
            Value<DateTime> lastSyncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SyncCheckpointsCompanion(
            id: id,
            tenantId: tenantId,
            deviceId: deviceId,
            entityType: entityType,
            lastVersion: lastVersion,
            lastSyncedAt: lastSyncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String deviceId,
            required String entityType,
            Value<int> lastVersion = const Value.absent(),
            required DateTime lastSyncedAt,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              SyncCheckpointsCompanion.insert(
            id: id,
            tenantId: tenantId,
            deviceId: deviceId,
            entityType: entityType,
            lastVersion: lastVersion,
            lastSyncedAt: lastSyncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$SyncCheckpointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCheckpointsTable,
    SyncCheckpoint,
    $$$SyncCheckpointsTableFilterComposer,
    $$$SyncCheckpointsTableOrderingComposer,
    $$$SyncCheckpointsTableAnnotationComposer,
    $$$SyncCheckpointsTableCreateCompanionBuilder,
    $$$SyncCheckpointsTableUpdateCompanionBuilder,
    (SyncCheckpoint, BaseReferences<_$AppDatabase, $SyncCheckpointsTable, SyncCheckpoint>),
    SyncCheckpoint,
    PrefetchHooks Function()>;

typedef $$$SyncLogsTableCreateCompanionBuilder = SyncLogsCompanion Function({
  required String id,
  Value<String> tenantId,
  required String level,
  required String message,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> metadata,
  required DateTime createdAt,
});
typedef $$$SyncLogsTableUpdateCompanionBuilder = SyncLogsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> level,
  Value<String> message,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> metadata,
  Value<DateTime> createdAt,
});

class $$$SyncLogsTableFilterComposer extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$$SyncLogsTableOrderingComposer extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$$SyncLogsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
  GeneratedColumn get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);
  GeneratedColumn get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);
  GeneratedColumn get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);
  GeneratedColumn get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
  GeneratedColumn get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$$SyncLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncLogsTable,
    SyncLog,
    $$$SyncLogsTableFilterComposer,
    $$$SyncLogsTableOrderingComposer,
    $$$SyncLogsTableAnnotationComposer,
    $$$SyncLogsTableCreateCompanionBuilder,
    $$$SyncLogsTableUpdateCompanionBuilder,
    (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
    SyncLog,
    PrefetchHooks Function()> {
  $$$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncLogsCompanion(
            id: id,
            tenantId: tenantId,
            level: level,
            message: message,
            entityType: entityType,
            entityId: entityId,
            metadata: metadata,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> tenantId = const Value.absent(),
            required String level,
            required String message,
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            required DateTime createdAt,
          }) =>
              SyncLogsCompanion.insert(
            id: id,
            tenantId: tenantId,
            level: level,
            message: message,
            entityType: entityType,
            entityId: entityId,
            metadata: metadata,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$SyncLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncLogsTable,
    SyncLog,
    $$$SyncLogsTableFilterComposer,
    $$$SyncLogsTableOrderingComposer,
    $$$SyncLogsTableAnnotationComposer,
    $$$SyncLogsTableCreateCompanionBuilder,
    $$$SyncLogsTableUpdateCompanionBuilder,
    (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
    SyncLog,
    PrefetchHooks Function()>;

typedef $$$AuthCacheEntriesTableCreateCompanionBuilder = AuthCacheEntriesCompanion Function({
  required String key,
  required String value,
  required DateTime updatedAt,
});
typedef $$$AuthCacheEntriesTableUpdateCompanionBuilder = AuthCacheEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
});

class $$$AuthCacheEntriesTableFilterComposer extends Composer<_$AppDatabase, $AuthCacheEntriesTable> {
  $$$AuthCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$$AuthCacheEntriesTableOrderingComposer extends Composer<_$AppDatabase, $AuthCacheEntriesTable> {
  $$$AuthCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$$AuthCacheEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $AuthCacheEntriesTable> {
  $$$AuthCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
  GeneratedColumn get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$$AuthCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuthCacheEntriesTable,
    AuthCacheEntry,
    $$$AuthCacheEntriesTableFilterComposer,
    $$$AuthCacheEntriesTableOrderingComposer,
    $$$AuthCacheEntriesTableAnnotationComposer,
    $$$AuthCacheEntriesTableCreateCompanionBuilder,
    $$$AuthCacheEntriesTableUpdateCompanionBuilder,
    (AuthCacheEntry, BaseReferences<_$AppDatabase, $AuthCacheEntriesTable, AuthCacheEntry>),
    AuthCacheEntry,
    PrefetchHooks Function()> {
  $$$AuthCacheEntriesTableTableManager(_$AppDatabase db, $AuthCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$AuthCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$AuthCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$AuthCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AuthCacheEntriesCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
          }) =>
              AuthCacheEntriesCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$AuthCacheEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuthCacheEntriesTable,
    AuthCacheEntry,
    $$$AuthCacheEntriesTableFilterComposer,
    $$$AuthCacheEntriesTableOrderingComposer,
    $$$AuthCacheEntriesTableAnnotationComposer,
    $$$AuthCacheEntriesTableCreateCompanionBuilder,
    $$$AuthCacheEntriesTableUpdateCompanionBuilder,
    (AuthCacheEntry, BaseReferences<_$AppDatabase, $AuthCacheEntriesTable, AuthCacheEntry>),
    AuthCacheEntry,
    PrefetchHooks Function()>;

typedef $$$LocalSettingsTableCreateCompanionBuilder = LocalSettingsCompanion Function({
  required String key,
  required String tenantId,
  required String value,
  required DateTime updatedAt,
});
typedef $$$LocalSettingsTableUpdateCompanionBuilder = LocalSettingsCompanion Function({
  Value<String> key,
  Value<String> tenantId,
  Value<String> value,
  Value<DateTime> updatedAt,
});

class $$$LocalSettingsTableFilterComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$$LocalSettingsTableOrderingComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$$LocalSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$$LocalSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSettingsTable,
    LocalSetting,
    $$$LocalSettingsTableFilterComposer,
    $$$LocalSettingsTableOrderingComposer,
    $$$LocalSettingsTableAnnotationComposer,
    $$$LocalSettingsTableCreateCompanionBuilder,
    $$$LocalSettingsTableUpdateCompanionBuilder,
    (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
    LocalSetting,
    PrefetchHooks Function()> {
  $$$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalSettingsCompanion(
            key: key,
            tenantId: tenantId,
            value: value,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            required String key,
            required String tenantId,
            required String value,
            required DateTime updatedAt,
          }) =>
              LocalSettingsCompanion.insert(
            key: key,
            tenantId: tenantId,
            value: value,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$LocalSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSettingsTable,
    LocalSetting,
    $$$LocalSettingsTableFilterComposer,
    $$$LocalSettingsTableOrderingComposer,
    $$$LocalSettingsTableAnnotationComposer,
    $$$LocalSettingsTableCreateCompanionBuilder,
    $$$LocalSettingsTableUpdateCompanionBuilder,
    (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
    LocalSetting,
    PrefetchHooks Function()>;

typedef $$$AuditLogEntriesTableCreateCompanionBuilder = AuditLogEntriesCompanion Function({
  required String id,
  Value<String> tenantId,
  Value<String> storeId,
  Value<String> employeeId,
  Value<String> deviceId,
  required String action,
  required String entityType,
  Value<String> entityId,
  Value<String> oldValue,
  Value<String> newValue,
  Value<String> metadata,
  required DateTime createdAt,
  Value<bool> synced,
});
typedef $$$AuditLogEntriesTableUpdateCompanionBuilder = AuditLogEntriesCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> storeId,
  Value<String> employeeId,
  Value<String> deviceId,
  Value<String> action,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> oldValue,
  Value<String> newValue,
  Value<String> metadata,
  Value<DateTime> createdAt,
  Value<bool> synced,
});

class $$$AuditLogEntriesTableFilterComposer extends Composer<_$AppDatabase, $AuditLogEntriesTable> {
  $$$AuditLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get oldValue => $composableBuilder(
      column: $table.oldValue, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get newValue => $composableBuilder(
      column: $table.newValue, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$$AuditLogEntriesTableOrderingComposer extends Composer<_$AppDatabase, $AuditLogEntriesTable> {
  $$$AuditLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get oldValue => $composableBuilder(
      column: $table.oldValue, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get newValue => $composableBuilder(
      column: $table.newValue, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$$AuditLogEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $AuditLogEntriesTable> {
  $$$AuditLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);
  GeneratedColumn get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);
  GeneratedColumn get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
  GeneratedColumn get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);
  GeneratedColumn get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);
  GeneratedColumn get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);
  GeneratedColumn get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);
  GeneratedColumn get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);
  GeneratedColumn get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
  GeneratedColumn get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
  GeneratedColumn get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$$AuditLogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogEntriesTable,
    AuditLogEntry,
    $$$AuditLogEntriesTableFilterComposer,
    $$$AuditLogEntriesTableOrderingComposer,
    $$$AuditLogEntriesTableAnnotationComposer,
    $$$AuditLogEntriesTableCreateCompanionBuilder,
    $$$AuditLogEntriesTableUpdateCompanionBuilder,
    (AuditLogEntry, BaseReferences<_$AppDatabase, $AuditLogEntriesTable, AuditLogEntry>),
    AuditLogEntry,
    PrefetchHooks Function()> {
  $$$AuditLogEntriesTableTableManager(_$AppDatabase db, $AuditLogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$AuditLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$AuditLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$AuditLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<String> employeeId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> oldValue = const Value.absent(),
            Value<String> newValue = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              AuditLogEntriesCompanion(
            id: id,
            tenantId: tenantId,
            storeId: storeId,
            employeeId: employeeId,
            deviceId: deviceId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValue: oldValue,
            newValue: newValue,
            metadata: metadata,
            createdAt: createdAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> tenantId = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<String> employeeId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            required String action,
            required String entityType,
            Value<String> entityId = const Value.absent(),
            Value<String> oldValue = const Value.absent(),
            Value<String> newValue = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            required DateTime createdAt,
            Value<bool> synced = const Value.absent(),
          }) =>
              AuditLogEntriesCompanion.insert(
            id: id,
            tenantId: tenantId,
            storeId: storeId,
            employeeId: employeeId,
            deviceId: deviceId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValue: oldValue,
            newValue: newValue,
            metadata: metadata,
            createdAt: createdAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$AuditLogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogEntriesTable,
    AuditLogEntry,
    $$$AuditLogEntriesTableFilterComposer,
    $$$AuditLogEntriesTableOrderingComposer,
    $$$AuditLogEntriesTableAnnotationComposer,
    $$$AuditLogEntriesTableCreateCompanionBuilder,
    $$$AuditLogEntriesTableUpdateCompanionBuilder,
    (AuditLogEntry, BaseReferences<_$AppDatabase, $AuditLogEntriesTable, AuditLogEntry>),
    AuditLogEntry,
    PrefetchHooks Function()>;

typedef $$$LicenseCacheEntriesTableCreateCompanionBuilder = LicenseCacheEntriesCompanion Function({
  required String tenantId,
  required String licenseType,
  required String status,
  Value<DateTime> validUntil,
  required DateTime lastValidatedAt,
  Value<DateTime> gracePeriodEndsAt,
  Value<String> payload,
});
typedef $$$LicenseCacheEntriesTableUpdateCompanionBuilder = LicenseCacheEntriesCompanion Function({
  Value<String> tenantId,
  Value<String> licenseType,
  Value<String> status,
  Value<DateTime> validUntil,
  Value<DateTime> lastValidatedAt,
  Value<DateTime> gracePeriodEndsAt,
  Value<String> payload,
});

class $$$LicenseCacheEntriesTableFilterComposer extends Composer<_$AppDatabase, $LicenseCacheEntriesTable> {
  $$$LicenseCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get lastValidatedAt => $composableBuilder(
      column: $table.lastValidatedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get gracePeriodEndsAt => $composableBuilder(
      column: $table.gracePeriodEndsAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));
}

class $$$LicenseCacheEntriesTableOrderingComposer extends Composer<_$AppDatabase, $LicenseCacheEntriesTable> {
  $$$LicenseCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get lastValidatedAt => $composableBuilder(
      column: $table.lastValidatedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get gracePeriodEndsAt => $composableBuilder(
      column: $table.gracePeriodEndsAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));
}

class $$$LicenseCacheEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $LicenseCacheEntriesTable> {
  $$$LicenseCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get licenseType =>
      $composableBuilder(column: $table.licenseType, builder: (column) => column);
  GeneratedColumn get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
  GeneratedColumn get validUntil =>
      $composableBuilder(column: $table.validUntil, builder: (column) => column);
  GeneratedColumn get lastValidatedAt =>
      $composableBuilder(column: $table.lastValidatedAt, builder: (column) => column);
  GeneratedColumn get gracePeriodEndsAt =>
      $composableBuilder(column: $table.gracePeriodEndsAt, builder: (column) => column);
  GeneratedColumn get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$$LicenseCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LicenseCacheEntriesTable,
    LicenseCacheEntry,
    $$$LicenseCacheEntriesTableFilterComposer,
    $$$LicenseCacheEntriesTableOrderingComposer,
    $$$LicenseCacheEntriesTableAnnotationComposer,
    $$$LicenseCacheEntriesTableCreateCompanionBuilder,
    $$$LicenseCacheEntriesTableUpdateCompanionBuilder,
    (LicenseCacheEntry, BaseReferences<_$AppDatabase, $LicenseCacheEntriesTable, LicenseCacheEntry>),
    LicenseCacheEntry,
    PrefetchHooks Function()> {
  $$$LicenseCacheEntriesTableTableManager(_$AppDatabase db, $LicenseCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$LicenseCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$LicenseCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$LicenseCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tenantId = const Value.absent(),
            Value<String> licenseType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> validUntil = const Value.absent(),
            Value<DateTime> lastValidatedAt = const Value.absent(),
            Value<DateTime> gracePeriodEndsAt = const Value.absent(),
            Value<String> payload = const Value.absent(),
          }) =>
              LicenseCacheEntriesCompanion(
            tenantId: tenantId,
            licenseType: licenseType,
            status: status,
            validUntil: validUntil,
            lastValidatedAt: lastValidatedAt,
            gracePeriodEndsAt: gracePeriodEndsAt,
            payload: payload,
          ),
          createCompanionCallback: ({
            required String tenantId,
            required String licenseType,
            required String status,
            Value<DateTime> validUntil = const Value.absent(),
            required DateTime lastValidatedAt,
            Value<DateTime> gracePeriodEndsAt = const Value.absent(),
            Value<String> payload = const Value.absent(),
          }) =>
              LicenseCacheEntriesCompanion.insert(
            tenantId: tenantId,
            licenseType: licenseType,
            status: status,
            validUntil: validUntil,
            lastValidatedAt: lastValidatedAt,
            gracePeriodEndsAt: gracePeriodEndsAt,
            payload: payload,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$LicenseCacheEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LicenseCacheEntriesTable,
    LicenseCacheEntry,
    $$$LicenseCacheEntriesTableFilterComposer,
    $$$LicenseCacheEntriesTableOrderingComposer,
    $$$LicenseCacheEntriesTableAnnotationComposer,
    $$$LicenseCacheEntriesTableCreateCompanionBuilder,
    $$$LicenseCacheEntriesTableUpdateCompanionBuilder,
    (LicenseCacheEntry, BaseReferences<_$AppDatabase, $LicenseCacheEntriesTable, LicenseCacheEntry>),
    LicenseCacheEntry,
    PrefetchHooks Function()>;

typedef $$$SyncableRecordsTableCreateCompanionBuilder = SyncableRecordsCompanion Function({
  required String id,
  required String tenantId,
  required String entityType,
  Value<String> storeId,
  required String payload,
  Value<int> version,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime> deletedAt,
  Value<String> syncStatus,
  Value<bool> isDirty,
  Value<String> searchName,
  Value<String> searchSku,
  Value<String> searchBarcode,
});
typedef $$$SyncableRecordsTableUpdateCompanionBuilder = SyncableRecordsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> entityType,
  Value<String> storeId,
  Value<String> payload,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> deletedAt,
  Value<String> syncStatus,
  Value<bool> isDirty,
  Value<String> searchName,
  Value<String> searchSku,
  Value<String> searchBarcode,
});

class $$$SyncableRecordsTableFilterComposer extends Composer<_$AppDatabase, $SyncableRecordsTable> {
  $$$SyncableRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get searchName => $composableBuilder(
      column: $table.searchName, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get searchSku => $composableBuilder(
      column: $table.searchSku, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get searchBarcode => $composableBuilder(
      column: $table.searchBarcode, builder: (column) => ColumnFilters(column));
}

class $$$SyncableRecordsTableOrderingComposer extends Composer<_$AppDatabase, $SyncableRecordsTable> {
  $$$SyncableRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get searchName => $composableBuilder(
      column: $table.searchName, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get searchSku => $composableBuilder(
      column: $table.searchSku, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get searchBarcode => $composableBuilder(
      column: $table.searchBarcode, builder: (column) => ColumnOrderings(column));
}

class $$$SyncableRecordsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncableRecordsTable> {
  $$$SyncableRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
  GeneratedColumn get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);
  GeneratedColumn get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);
  GeneratedColumn get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
  GeneratedColumn get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
  GeneratedColumn get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
  GeneratedColumn get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
  GeneratedColumn get syncStatus =>
      $composableBuilder(column: $table.syncStatus, builder: (column) => column);
  GeneratedColumn get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
  GeneratedColumn get searchName =>
      $composableBuilder(column: $table.searchName, builder: (column) => column);
  GeneratedColumn get searchSku =>
      $composableBuilder(column: $table.searchSku, builder: (column) => column);
  GeneratedColumn get searchBarcode =>
      $composableBuilder(column: $table.searchBarcode, builder: (column) => column);
}

class $$$SyncableRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncableRecordsTable,
    SyncableRecord,
    $$$SyncableRecordsTableFilterComposer,
    $$$SyncableRecordsTableOrderingComposer,
    $$$SyncableRecordsTableAnnotationComposer,
    $$$SyncableRecordsTableCreateCompanionBuilder,
    $$$SyncableRecordsTableUpdateCompanionBuilder,
    (SyncableRecord, BaseReferences<_$AppDatabase, $SyncableRecordsTable, SyncableRecord>),
    SyncableRecord,
    PrefetchHooks Function()> {
  $$$SyncableRecordsTableTableManager(_$AppDatabase db, $SyncableRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$SyncableRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$SyncableRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$SyncableRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<String> searchName = const Value.absent(),
            Value<String> searchSku = const Value.absent(),
            Value<String> searchBarcode = const Value.absent(),
          }) =>
              SyncableRecordsCompanion(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            storeId: storeId,
            payload: payload,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            isDirty: isDirty,
            searchName: searchName,
            searchSku: searchSku,
            searchBarcode: searchBarcode,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String entityType,
            Value<String> storeId = const Value.absent(),
            required String payload,
            Value<int> version = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<String> searchName = const Value.absent(),
            Value<String> searchSku = const Value.absent(),
            Value<String> searchBarcode = const Value.absent(),
          }) =>
              SyncableRecordsCompanion.insert(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            storeId: storeId,
            payload: payload,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            isDirty: isDirty,
            searchName: searchName,
            searchSku: searchSku,
            searchBarcode: searchBarcode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$SyncableRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncableRecordsTable,
    SyncableRecord,
    $$$SyncableRecordsTableFilterComposer,
    $$$SyncableRecordsTableOrderingComposer,
    $$$SyncableRecordsTableAnnotationComposer,
    $$$SyncableRecordsTableCreateCompanionBuilder,
    $$$SyncableRecordsTableUpdateCompanionBuilder,
    (SyncableRecord, BaseReferences<_$AppDatabase, $SyncableRecordsTable, SyncableRecord>),
    SyncableRecord,
    PrefetchHooks Function()>;

typedef $$$FeatureFlagEntriesTableCreateCompanionBuilder = FeatureFlagEntriesCompanion Function({
  required String key,
  required String value,
  Value<String> source,
  required DateTime fetchedAt,
  Value<DateTime> expiresAt,
});
typedef $$$FeatureFlagEntriesTableUpdateCompanionBuilder = FeatureFlagEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime> expiresAt,
});

class $$$FeatureFlagEntriesTableFilterComposer extends Composer<_$AppDatabase, $FeatureFlagEntriesTable> {
  $$$FeatureFlagEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$$FeatureFlagEntriesTableOrderingComposer extends Composer<_$AppDatabase, $FeatureFlagEntriesTable> {
  $$$FeatureFlagEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$$FeatureFlagEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $FeatureFlagEntriesTable> {
  $$$FeatureFlagEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
  GeneratedColumn get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
  GeneratedColumn get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
  GeneratedColumn get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
  GeneratedColumn get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$$FeatureFlagEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeatureFlagEntriesTable,
    FeatureFlagEntry,
    $$$FeatureFlagEntriesTableFilterComposer,
    $$$FeatureFlagEntriesTableOrderingComposer,
    $$$FeatureFlagEntriesTableAnnotationComposer,
    $$$FeatureFlagEntriesTableCreateCompanionBuilder,
    $$$FeatureFlagEntriesTableUpdateCompanionBuilder,
    (FeatureFlagEntry, BaseReferences<_$AppDatabase, $FeatureFlagEntriesTable, FeatureFlagEntry>),
    FeatureFlagEntry,
    PrefetchHooks Function()> {
  $$$FeatureFlagEntriesTableTableManager(_$AppDatabase db, $FeatureFlagEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$FeatureFlagEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$FeatureFlagEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$FeatureFlagEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
          }) =>
              FeatureFlagEntriesCompanion(
            key: key,
            value: value,
            source: source,
            fetchedAt: fetchedAt,
            expiresAt: expiresAt,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<String> source = const Value.absent(),
            required DateTime fetchedAt,
            Value<DateTime> expiresAt = const Value.absent(),
          }) =>
              FeatureFlagEntriesCompanion.insert(
            key: key,
            value: value,
            source: source,
            fetchedAt: fetchedAt,
            expiresAt: expiresAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$FeatureFlagEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeatureFlagEntriesTable,
    FeatureFlagEntry,
    $$$FeatureFlagEntriesTableFilterComposer,
    $$$FeatureFlagEntriesTableOrderingComposer,
    $$$FeatureFlagEntriesTableAnnotationComposer,
    $$$FeatureFlagEntriesTableCreateCompanionBuilder,
    $$$FeatureFlagEntriesTableUpdateCompanionBuilder,
    (FeatureFlagEntry, BaseReferences<_$AppDatabase, $FeatureFlagEntriesTable, FeatureFlagEntry>),
    FeatureFlagEntry,
    PrefetchHooks Function()>;

typedef $$$AppRecoveryEntriesTableCreateCompanionBuilder = AppRecoveryEntriesCompanion Function({
  required String key,
  required String value,
  required DateTime updatedAt,
});
typedef $$$AppRecoveryEntriesTableUpdateCompanionBuilder = AppRecoveryEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
});

class $$$AppRecoveryEntriesTableFilterComposer extends Composer<_$AppDatabase, $AppRecoveryEntriesTable> {
  $$$AppRecoveryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$$AppRecoveryEntriesTableOrderingComposer extends Composer<_$AppDatabase, $AppRecoveryEntriesTable> {
  $$$AppRecoveryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$$AppRecoveryEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $AppRecoveryEntriesTable> {
  $$$AppRecoveryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
  GeneratedColumn get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
  GeneratedColumn get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$$AppRecoveryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppRecoveryEntriesTable,
    AppRecoveryEntry,
    $$$AppRecoveryEntriesTableFilterComposer,
    $$$AppRecoveryEntriesTableOrderingComposer,
    $$$AppRecoveryEntriesTableAnnotationComposer,
    $$$AppRecoveryEntriesTableCreateCompanionBuilder,
    $$$AppRecoveryEntriesTableUpdateCompanionBuilder,
    (AppRecoveryEntry, BaseReferences<_$AppDatabase, $AppRecoveryEntriesTable, AppRecoveryEntry>),
    AppRecoveryEntry,
    PrefetchHooks Function()> {
  $$$AppRecoveryEntriesTableTableManager(_$AppDatabase db, $AppRecoveryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$$AppRecoveryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$$AppRecoveryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$$AppRecoveryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AppRecoveryEntriesCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
          }) =>
              AppRecoveryEntriesCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$$AppRecoveryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppRecoveryEntriesTable,
    AppRecoveryEntry,
    $$$AppRecoveryEntriesTableFilterComposer,
    $$$AppRecoveryEntriesTableOrderingComposer,
    $$$AppRecoveryEntriesTableAnnotationComposer,
    $$$AppRecoveryEntriesTableCreateCompanionBuilder,
    $$$AppRecoveryEntriesTableUpdateCompanionBuilder,
    (AppRecoveryEntry, BaseReferences<_$AppDatabase, $AppRecoveryEntriesTable, AppRecoveryEntry>),
    AppRecoveryEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$$SyncCheckpointsTableTableManager get syncCheckpoints =>
      $$$SyncCheckpointsTableTableManager(_db, _db.syncCheckpoints);
  $$$SyncLogsTableTableManager get syncLogs =>
      $$$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$$AuthCacheEntriesTableTableManager get authCacheEntries =>
      $$$AuthCacheEntriesTableTableManager(_db, _db.authCacheEntries);
  $$$LocalSettingsTableTableManager get localSettings =>
      $$$LocalSettingsTableTableManager(_db, _db.localSettings);
  $$$AuditLogEntriesTableTableManager get auditLogEntries =>
      $$$AuditLogEntriesTableTableManager(_db, _db.auditLogEntries);
  $$$LicenseCacheEntriesTableTableManager get licenseCacheEntries =>
      $$$LicenseCacheEntriesTableTableManager(_db, _db.licenseCacheEntries);
  $$$SyncableRecordsTableTableManager get syncableRecords =>
      $$$SyncableRecordsTableTableManager(_db, _db.syncableRecords);
  $$$FeatureFlagEntriesTableTableManager get featureFlagEntries =>
      $$$FeatureFlagEntriesTableTableManager(_db, _db.featureFlagEntries);
  $$$AppRecoveryEntriesTableTableManager get appRecoveryEntries =>
      $$$AppRecoveryEntriesTableTableManager(_db, _db.appRecoveryEntries);
}