import 'package:equatable/equatable.dart';

/// Normalized remote entity row returned from a delta pull.
class RemoteSyncRecord extends Equatable {
  const RemoteSyncRecord({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.payload,
    required this.version,
    required this.updatedAt,
    this.deletedAt,
    this.searchName,
    this.searchSku,
    this.searchBarcode,
    this.storeId,
  });

  final String id;
  final String tenantId;
  final String entityType;
  final Map<String, dynamic> payload;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? searchName;
  final String? searchSku;
  final String? searchBarcode;
  final String? storeId;

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [id, tenantId, entityType, version, updatedAt];
}

/// Result of an entity pull delta request.
class PullDeltaResult extends Equatable {
  const PullDeltaResult({
    this.records = const [],
    this.maxUpdatedAt,
    this.maxVersion = 0,
  });

  final List<RemoteSyncRecord> records;
  final DateTime? maxUpdatedAt;
  final int maxVersion;

  @override
  List<Object?> get props => [records.length, maxUpdatedAt, maxVersion];
}
