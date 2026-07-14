import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

/// Standard query object for repository pagination, filtering, and sorting.
class RepositoryQuery extends Equatable {
  const RepositoryQuery({
    this.page = 1,
    this.pageSize = 50,
    this.sortBy,
    this.sortDescending = true,
    this.searchTerm,
    this.tenantId,
    this.entityType,
    this.storeId,
    this.syncStatus,
    this.onlyDirty = false,
    this.includeDeleted = false,
    this.filters = const {},
  });

  final int page;
  final int pageSize;
  final String? sortBy;
  final bool sortDescending;
  final String? searchTerm;
  final String? tenantId;
  final String? entityType;
  final String? storeId;
  final LocalSyncStatus? syncStatus;
  final bool onlyDirty;
  final bool includeDeleted;
  final Map<String, String> filters;

  int get offset => (page - 1) * pageSize;

  RepositoryQuery nextPage() => RepositoryQuery(
        page: page + 1,
        pageSize: pageSize,
        sortBy: sortBy,
        sortDescending: sortDescending,
        searchTerm: searchTerm,
        tenantId: tenantId,
        entityType: entityType,
        storeId: storeId,
        syncStatus: syncStatus,
        onlyDirty: onlyDirty,
        includeDeleted: includeDeleted,
        filters: filters,
      );

  @override
  List<Object?> get props => [page, pageSize, tenantId, entityType, searchTerm];
}
