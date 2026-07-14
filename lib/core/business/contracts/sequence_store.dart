import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Persists and retrieves monotonic document number sequences.
abstract class SequenceStore {
  Future<int> nextSequence({
    required String tenantId,
    required DocumentNumberType documentType,
    String? storeId,
  });
}

/// In-memory sequence store for tests and offline operation.
class InMemorySequenceStore implements SequenceStore {
  final Map<String, int> _sequences = {};

  @override
  Future<int> nextSequence({
    required String tenantId,
    required DocumentNumberType documentType,
    String? storeId,
  }) async {
    final key = '${tenantId}_${storeId ?? 'global'}_${documentType.name}';
    final next = (_sequences[key] ?? 0) + 1;
    _sequences[key] = next;
    return next;
  }

  void reset() => _sequences.clear();
}
