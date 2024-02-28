/// The function used for making the method caching conditional.
/// Returns "true" to always cache method results.
typedef CacheCondition = bool Function(
    Object target, String methodName, List args);

/// Annotation indicating that a method triggers a cache put operation.
class CachePut {
  /// The key used by the cached data
  final String key;

  /// Update the cache if the condition evaluates to true.
  final CacheCondition? condition;

  /// Cached data time-to-live
  final int? ttl;

  const CachePut(this.key, {this.condition, this.ttl});
}

/// Annotation indicating that the result of invoking a method can be cached.
class Cacheable {
  /// The key used by the cached data
  final String key;

  /// Cache the result if the condition evaluates to true.
  final CacheCondition? condition;

  /// Cached data time-to-live
  final int? ttl;

  const Cacheable(this.key, {this.condition, this.ttl});
}

/// Annotation indicating that a method triggers a cache evict operation.
class CacheEvict {
  /// The key used by the cached data
  final String key;

  /// Evict that cache if the condition evaluates to true.
  final CacheCondition? condition;

  /// Whether all the entries inside the cache(s) are removed.
  final bool allEntries;

  /// Whether the eviction should occur before the method is invoked.
  /// Setting this attribute to true, causes the eviction to occur irrespective of the method outcome (i.e., whether it threw an exception or not).
  /// Defaults to false, meaning that the cache eviction operation will occur after the advised method is invoked successfully (i.e. only if the invocation did not throw an exception).
  final bool beforeInvocation;

  const CacheEvict(this.key,
      {this.condition, this.allEntries = false, this.beforeInvocation = false});
}
