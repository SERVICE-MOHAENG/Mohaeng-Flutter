/// Returns a new map with any `null` values removed.
///
/// Notes:
/// - This is intentionally shallow (no deep traversal).
/// - Dates should be provided as ISO8601 strings at the call site.
Map<String, dynamic>? removeNullQueryParams(Map<String, Object?>? query) {
  if (query == null) return null;
  if (query.isEmpty) return const <String, dynamic>{};

  final result = <String, dynamic>{};
  for (final entry in query.entries) {
    final value = entry.value;
    if (value != null) {
      result[entry.key] = value;
    }
  }
  return result;
}
