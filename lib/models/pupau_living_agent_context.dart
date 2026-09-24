/// Context the host attaches to ONE Living Agent turn.
///
/// The refs are relayed to the backend exactly as the server handed them to
/// the host (`LaChatDto.contextRefs`): their shape differs per kind —
/// `{kind: ITEM|NEWS, id}`, `{kind: MAIL, ref}`, `{kind: EVENT, surfaceKey,
/// eventId}` — and re-typing them here would only risk dropping a field the
/// backend needs. This class is a relay, not an interpreter.
class PupauLivingAgentContext {
  /// The backend caps `contextRefs` at 10 and rejects the whole request over
  /// it, so the cap is applied here rather than losing the turn.
  static const int maxContextRefs = 10;

  final List<Map<String, dynamic>> contextRefs;

  const PupauLivingAgentContext._(this.contextRefs);

  /// Keeps only entries that carry a non-empty `kind`, and at most
  /// [maxContextRefs] of them.
  factory PupauLivingAgentContext({
    List<Map<String, dynamic>> contextRefs = const <Map<String, dynamic>>[],
  }) {
    final List<Map<String, dynamic>> usable = contextRefs
        .where((Map<String, dynamic> ref) =>
            ref['kind'] is String && (ref['kind'] as String).isNotEmpty)
        .take(maxContextRefs)
        .toList();
    return PupauLivingAgentContext._(List<Map<String, dynamic>>.unmodifiable(usable));
  }

  bool get isEmpty => contextRefs.isEmpty;
  bool get isNotEmpty => contextRefs.isNotEmpty;

  /// The fields to merge into the chat body. Empty when there is nothing to
  /// send, so the caller never has to branch.
  Map<String, dynamic> toBodyFields() => isEmpty
      ? const <String, dynamic>{}
      // A fresh growable copy: the body is handed to an HTTP client that may
      // add to it, and [contextRefs] is unmodifiable by design.
      : <String, dynamic>{
          'contextRefs': List<Map<String, dynamic>>.from(contextRefs),
        };
}
