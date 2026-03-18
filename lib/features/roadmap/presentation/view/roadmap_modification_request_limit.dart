const int roadmapModificationRequestLimit = 5;

bool hasReachedRoadmapModificationRequestLimit(
  int requestCount, {
  int limit = roadmapModificationRequestLimit,
}) {
  return requestCount >= limit;
}

int remainingRoadmapModificationRequests(
  int requestCount, {
  int limit = roadmapModificationRequestLimit,
}) {
  if (requestCount <= 0) return limit;
  final remaining = limit - requestCount;
  return remaining < 0 ? 0 : remaining;
}

int incrementRoadmapModificationRequestCount(
  int requestCount, {
  int limit = roadmapModificationRequestLimit,
}) {
  if (requestCount >= limit) return limit;
  return requestCount + 1;
}
