import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:lru_cache/lru_cache.dart';

/// LRU cache implementation that logs entries evicted purely because the
/// cache is over [maxSize] (as opposed to explicit [LruCache.remove] calls
/// or [LruCache.put] overwrites, which are logged by [AssistantCacheService]
/// itself since it has richer context there).
class _LoggingLruCache extends LruCache<String, Assistant> {
  _LoggingLruCache(super.maxSize);

  @override
  void entryRemoved(
    bool evicted,
    String key,
    Assistant oldValue,
    Assistant? newValue,
  ) {
    if (evicted) {
      debugPrint('[AssistantCache] Evicted (cache full): $key');
    }
  }
}

/// In-memory LRU cache for [Assistant] data (normal + marketplace agents
/// combined), so already-fetched agent data can be reused instead of being
/// re-fetched from the API.
///
/// Keys are `pupau_agent_<agent_id>` for normal agents and
/// `pupau_marketplace_agent_<agent_id>` for marketplace agents.
///
/// All cache mutations/lookups emit a `debugPrint` so cache behavior can be
/// observed while testing.
class AssistantCacheService {
  AssistantCacheService._();

  /// Max number of agents (normal + marketplace combined) kept in the cache.
  static const int maxSize = 20;

  static final _LoggingLruCache _cache = _LoggingLruCache(maxSize);

  /// Cache key for [assistantId] in [mode].
  ///
  /// Exhaustive on purpose: a Living Agent must never be cached (there is one
  /// per account and callers guard against it), but folding its mode into the
  /// plain assistant branch would file it under the SAME key as an assistant
  /// sharing that id — so a single future caller that forgets the guard would
  /// serve one aggregate's data to the other. Give it its own namespace so
  /// the mistake cannot alias.
  static String keyFor(String assistantId, PupauAgentMode mode) {
    switch (mode) {
      case PupauAgentMode.marketplace:
        return 'pupau_marketplace_agent_$assistantId';
      case PupauAgentMode.livingAgent:
        return 'pupau_living_agent_$assistantId';
      case PupauAgentMode.assistant:
        return 'pupau_agent_$assistantId';
    }
  }

  /// Inserts or updates [assistant] in the cache.
  static Future<void> put(Assistant assistant) async {
    if (assistant.id.trim().isEmpty) return;
    final String key = keyFor(
      assistant.id,
      assistant.type == AssistantType.marketplace
          ? PupauAgentMode.marketplace
          : PupauAgentMode.assistant,
    );
    final Assistant? previous = await _cache.put(key, assistant);
    if (previous == null) {
      debugPrint('[AssistantCache] Saved: $key');
    } else {
      debugPrint('[AssistantCache] Updated: $key');
    }
  }

  /// Returns the cached assistant for [assistantId]/[mode], or
  /// `null` if not cached.
  static Future<Assistant?> get(String assistantId, PupauAgentMode mode) async {
    if (assistantId.trim().isEmpty) return null;
    final String key = keyFor(assistantId, mode);
    final Assistant? cached = await _cache.get(key);
    if (cached != null) {
      debugPrint('[AssistantCache] Loaded: $key');
    } else {
      debugPrint('[AssistantCache] Miss (not cached): $key');
    }
    return cached;
  }

  /// Removes the cached assistant for [assistantId]/[mode].
  static Future<Assistant?> remove(String assistantId, PupauAgentMode mode) async {
    final String key = keyFor(assistantId, mode);
    final Assistant? removed = await _cache.remove(key);
    if (removed != null) {
      debugPrint('[AssistantCache] Deleted: $key');
    }
    return removed;
  }

  /// Clears the entire cache.
  static Future<void> clear() async {
    await _cache.evictAll();
    debugPrint('[AssistantCache] Cleared entire cache');
  }
}
