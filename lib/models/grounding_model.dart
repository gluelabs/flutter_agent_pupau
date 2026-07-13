import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:get/get.dart';

/// Canonical `[n]` citation marker pattern (§1 of the citations spec) — the
/// single source of truth for both `CitationSyntax`'s markdown match and any
/// plain-text existence check (e.g. "does this turn's text contain a
/// citation?", used to decide whether to schedule a grounding refetch).
const String citationMarkerPattern = r'\[(\d+)\]';
final RegExp citationMarkerRegex = RegExp(citationMarkerPattern);

enum GroundingOrigin { implicit, kbTool, webSearch, attachment, unknown }

extension GroundingOriginParsing on GroundingOrigin {
  static GroundingOrigin fromWireValue(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'IMPLICIT':
        return GroundingOrigin.implicit;
      case 'KB_TOOL':
        return GroundingOrigin.kbTool;
      case 'WEB_SEARCH':
        return GroundingOrigin.webSearch;
      case 'ATTACHMENT':
        return GroundingOrigin.attachment;
      default:
        return GroundingOrigin.unknown;
    }
  }

  /// KB snippet fetch (`GET /grounding/chunks/:embeddingId`) only ever makes
  /// sense for chunk-backed origins (§2.2).
  bool get supportsSnippetFetch =>
      this == GroundingOrigin.implicit || this == GroundingOrigin.kbTool;
}

enum GroundingVerdictType { supported, partial, unsupported, unknown }

extension GroundingVerdictTypeParsing on GroundingVerdictType {
  static GroundingVerdictType fromWireValue(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'SUPPORTED':
        return GroundingVerdictType.supported;
      case 'PARTIAL':
        return GroundingVerdictType.partial;
      case 'UNSUPPORTED':
        return GroundingVerdictType.unsupported;
      default:
        return GroundingVerdictType.unknown;
    }
  }
}

enum GroundingVerificationStatus { pending, skipped, failed, done }

extension GroundingVerificationStatusParsing on GroundingVerificationStatus {
  /// Returns null for an absent/unrecognized status — §3.2: absence means no
  /// verification UI at all, distinct from any known status value.
  static GroundingVerificationStatus? fromWireValue(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'PENDING':
        return GroundingVerificationStatus.pending;
      case 'SKIPPED':
        return GroundingVerificationStatus.skipped;
      case 'FAILED':
        return GroundingVerificationStatus.failed;
      case 'DONE':
        return GroundingVerificationStatus.done;
      default:
        return null;
    }
  }
}

/// One cited source (`extraInfo.grounding.sources[]` / live `groundingSources[]`), §2.1.
///
/// [id] is only reliable as the `[n]` marker ordinal on the *live* partial
/// shape (the `kb` frame's `groundingSources[]`, where the wire sends a
/// numeric `id` equal to the marker). On the *authoritative* shape
/// (`extraInfo.grounding.sources[]`, from history/refetch), the wire `id` is
/// an opaque sqid unrelated to the marker ordinal — marker resolution falls
/// back to positional pairing with `GroundingInfo.citedIds` in that case
/// (see [GroundingInfo.sourceForMarker]).
class GroundingSource {
  final int id;
  final GroundingOrigin origin;
  final String mediaType;
  final String name;
  final String? embeddingId;
  final String? kbId;
  final String? dataSourceId;
  final String? linkId;
  final String? url;
  final String? attachmentId;
  final String? type;
  final List<String> pageNumbers;
  final int? chunkOrder;
  final double? similarity;
  final String? toolSessionId;

  GroundingSource({
    required this.id,
    required this.origin,
    required this.mediaType,
    required this.name,
    this.embeddingId,
    this.kbId,
    this.dataSourceId,
    this.linkId,
    this.url,
    this.attachmentId,
    this.type,
    this.pageNumbers = const [],
    this.chunkOrder,
    this.similarity,
    this.toolSessionId,
  });

  factory GroundingSource.fromMap(Map<String, dynamic> json) {
    final List pages = json['pageNumbers'] is List
        ? json['pageNumbers'] as List
        : const [];
    return GroundingSource(
      id: getInt(json['id']),
      origin: GroundingOriginParsing.fromWireValue(getString(json['origin'])),
      mediaType: getString(json['mediaType']),
      name: getString(json['name']),
      embeddingId: getStringOrNull(json['embeddingId']),
      kbId: getStringOrNull(json['kbId']),
      dataSourceId: getStringOrNull(json['dataSourceId']),
      linkId: getStringOrNull(json['linkId']),
      url: getStringOrNull(json['url']),
      attachmentId: getStringOrNull(json['attachmentId']),
      type: getStringOrNull(json['type']),
      pageNumbers: pages.map((e) => getString(e)).toList(),
      chunkOrder: getIntOrNull(json['chunkOrder']),
      similarity: getDoubleOrNull(json['similarity']),
      toolSessionId: getStringOrNull(json['toolSessionId']),
    );
  }
}

/// One verification verdict (§3.3): `occurrence` is local to [sourceId] —
/// the n-th time that source was cited in the answer, 0-based.
class GroundingVerdict {
  final int sourceId;
  final int occurrence;
  final GroundingVerdictType verdict;

  GroundingVerdict({
    required this.sourceId,
    required this.occurrence,
    required this.verdict,
  });

  factory GroundingVerdict.fromMap(Map<String, dynamic> json) =>
      GroundingVerdict(
        sourceId: getInt(json['sourceId']),
        occurrence: getInt(json['occurrence']),
        verdict: GroundingVerdictTypeParsing.fromWireValue(
          getString(json['verdict']),
        ),
      );
}

/// `grounding.verification` (§3.2/3.3) — only meaningful when
/// `verificationStatus == DONE`.
class GroundingVerification {
  final double score;
  final List<GroundingVerdict> verdicts;
  final String? model;
  final double? credit;
  final int? timeMs;

  GroundingVerification({
    required this.score,
    required this.verdicts,
    this.model,
    this.credit,
    this.timeMs,
  });

  factory GroundingVerification.fromMap(Map<String, dynamic> json) {
    final List verdictsRaw = json['verdicts'] is List
        ? json['verdicts'] as List
        : const [];
    return GroundingVerification(
      score: getDouble(json['score']),
      verdicts: verdictsRaw
          .whereType<Map>()
          .map((e) => GroundingVerdict.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      model: getStringOrNull(json['model']),
      credit: getDoubleOrNull(json['credit']),
      timeMs: getIntOrNull(json['timeMs']),
    );
  }

  GroundingVerdict? verdictFor(int sourceId, int occurrence) =>
      verdicts.firstWhereOrNull(
        (GroundingVerdict v) =>
            v.sourceId == sourceId && v.occurrence == occurrence,
      );
}

/// `extraInfo.grounding` block (§2.1), or a partial live version built from
/// the `kb` frame's `groundingSources[]` before the turn closes (§1.2).
class GroundingInfo {
  final String? mode;
  final List<GroundingSource> sources;

  /// Authoritative list of cited marker ordinals. Empty on the live partial
  /// shape (not known yet) — see the chip-resolution rule in
  /// `CitationSyntax`: empty ⇒ optimistic (render every complete `[n]` as a
  /// chip), non-empty ⇒ strict validation against this list.
  final List<int> citedIds;
  final GroundingVerificationStatus? verificationStatus;
  final GroundingVerification? verification;

  /// §1.3: a guardrail replaced the response — render a normal message, no
  /// citation/verification UI at all.
  final bool overridden;

  /// The id of the *owning* row (the one this grounding block was actually
  /// persisted on / fetched for) — used as the `queryId` param on the
  /// snippet endpoint (§2.2). Kept distinct from whichever message this
  /// object ends up attached to after [backfillGroupGrounding], since a
  /// multi-row turn backfills the *same* object onto earlier rows whose own
  /// `.id` would be the wrong `queryId` to send.
  final String? queryId;

  GroundingInfo({
    this.mode,
    this.sources = const [],
    this.citedIds = const [],
    this.verificationStatus,
    this.verification,
    this.overridden = false,
    this.queryId,
  });

  factory GroundingInfo.fromMap(Map<String, dynamic> json) {
    final List sourcesRaw = json['sources'] is List
        ? json['sources'] as List
        : const [];
    final List citedIdsRaw = json['citedIds'] is List
        ? json['citedIds'] as List
        : const [];
    return GroundingInfo(
      mode: getStringOrNull(json['mode']),
      sources: sourcesRaw
          .whereType<Map>()
          .map((e) => GroundingSource.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      citedIds: citedIdsRaw.map((e) => getInt(e)).toList(),
      verificationStatus: GroundingVerificationStatusParsing.fromWireValue(
        getString(json['verificationStatus']),
      ),
      verification: json['verification'] is Map
          ? GroundingVerification.fromMap(
              Map<String, dynamic>.from(json['verification'] as Map),
            )
          : null,
      overridden: getBool(json['overridden']),
    );
  }

  /// Live partial shape: only IMPLICIT `sources` known so far (from the `kb`
  /// frame), nothing else resolved yet.
  factory GroundingInfo.liveSourcesOnly(List<GroundingSource> sources) =>
      GroundingInfo(sources: sources);

  GroundingInfo copyWith({
    String? mode,
    List<GroundingSource>? sources,
    List<int>? citedIds,
    GroundingVerificationStatus? verificationStatus,
    GroundingVerification? verification,
    bool? overridden,
    String? queryId,
  }) => GroundingInfo(
    mode: mode ?? this.mode,
    sources: sources ?? this.sources,
    citedIds: citedIds ?? this.citedIds,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    verification: verification ?? this.verification,
    overridden: overridden ?? this.overridden,
    queryId: queryId ?? this.queryId,
  );

  GroundingInfo withQueryId(String id) => copyWith(queryId: id);

  /// Applies a [GroundingVerificationFrame] update (last-write-wins — §3.1's
  /// idempotency rule). Built by hand rather than via [copyWith]: it must be
  /// able to *clear* `verification` back to null when the new status isn't
  /// `DONE`, which `copyWith`'s `??`-based "keep old value if absent"
  /// semantics can't express (there's no way to distinguish "not passed" from
  /// "explicitly null" through a single nullable parameter).
  GroundingInfo withVerification(GroundingVerificationFrame frame) =>
      GroundingInfo(
        mode: mode,
        sources: sources,
        citedIds: citedIds,
        verificationStatus: frame.verificationStatus,
        verification:
            frame.verificationStatus == GroundingVerificationStatus.done
            ? GroundingVerification(
                score: frame.score,
                verdicts: frame.verdicts,
                model: frame.model,
                credit: frame.credit,
              )
            : null,
        overridden: overridden,
        queryId: queryId,
      );

  /// Marker ordinal → source, resolved once per instance (not per lookup)
  /// since [sources]/[citedIds] never change after construction. Handles
  /// both observed wire shapes:
  /// - Live partial: `sources[].id` *is* the marker ordinal.
  /// - Authoritative: `sources[].id` is an opaque sqid; pair positionally
  ///   with `citedIds` instead (`sources[i]` ↔ `citedIds[i]`).
  late final Map<int, GroundingSource> _byMarker = _buildMarkerIndex();

  Map<int, GroundingSource> _buildMarkerIndex() {
    final Map<int, GroundingSource> index = <int, GroundingSource>{};
    final bool citedIdsAlign = citedIds.length == sources.length;
    for (int i = 0; i < sources.length; i++) {
      final GroundingSource source = sources[i];
      final int marker = source.id > 0
          ? source.id
          : (citedIdsAlign ? citedIds[i] : 0);
      if (marker > 0) index[marker] = source;
    }
    return index;
  }

  GroundingSource? sourceForMarker(int n) => _byMarker[n];
}

/// `source` block of the on-demand snippet response (§2.2).
class GroundingChunkSnippetSource {
  final String name;
  final String? type;
  final String? pageNumber;
  final int? chunkOrder;
  final String? url;

  GroundingChunkSnippetSource({
    required this.name,
    this.type,
    this.pageNumber,
    this.chunkOrder,
    this.url,
  });

  factory GroundingChunkSnippetSource.fromMap(Map<String, dynamic> json) =>
      GroundingChunkSnippetSource(
        name: getString(json['name']),
        type: getStringOrNull(json['type']),
        pageNumber: getStringOrNull(json['pageNumber']),
        chunkOrder: getIntOrNull(json['chunkOrder']),
        url: getStringOrNull(json['url']),
      );
}

/// `GET /grounding/chunks/:embeddingId?queryId=<sqid>` response (§2.2) — the
/// on-demand snippet for a KB-origin (IMPLICIT/KB_TOOL) citation chip.
class GroundingChunkSnippet {
  final String? content;
  final String mediaType;
  final GroundingChunkSnippetSource? source;

  GroundingChunkSnippet({this.content, required this.mediaType, this.source});

  factory GroundingChunkSnippet.fromJson(Map<String, dynamic> json) =>
      GroundingChunkSnippet(
        content: getStringOrNull(json['content']),
        mediaType: getString(json['mediaType']),
        source: json['source'] is Map
            ? GroundingChunkSnippetSource.fromMap(
                Map<String, dynamic>.from(json['source'] as Map),
              )
            : null,
      );
}

/// A verification result delivered outside the normal answer stream (§3.1):
/// either the live `grounding_verification` frame (`messageType:'LLM'`,
/// `type:'grounding_verification'`) or the reconnect catch-up
/// `grounding_verified` event payload. Both carry the same core fields.
class GroundingVerificationFrame {
  final String queryId;
  final String? queryGroupId;
  final double score;
  final List<GroundingVerdict> verdicts;
  final GroundingVerificationStatus? verificationStatus;
  final String? model;
  final double? credit;

  GroundingVerificationFrame({
    required this.queryId,
    this.queryGroupId,
    required this.score,
    required this.verdicts,
    required this.verificationStatus,
    this.model,
    this.credit,
  });

  factory GroundingVerificationFrame.fromJson(Map<String, dynamic> json) {
    final List verdictsRaw = json['verdicts'] is List
        ? json['verdicts'] as List
        : const [];
    return GroundingVerificationFrame(
      queryId: getString(json['queryId']),
      queryGroupId: getStringOrNull(json['queryGroupId']),
      score: getDouble(json['score']),
      verdicts: verdictsRaw
          .whereType<Map>()
          .map((e) => GroundingVerdict.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      verificationStatus: GroundingVerificationStatusParsing.fromWireValue(
        getString(json['verificationStatus']),
      ),
      model: getStringOrNull(json['model']),
      credit: getDoubleOrNull(json['credit']),
    );
  }
}
