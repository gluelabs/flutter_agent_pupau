import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/grounding_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Bottom sheet opened by tapping a [CitationChip] (§2 of the citations spec).
void showCitationSourcePanel({required CitationElementData data}) {
  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;

  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.sources.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: _CitationSourceBody(data: data),
      ),
    );
  }

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (modalSheetContext) => [page(modalSheetContext)],
  );
}

class _CitationSourceBody extends StatefulWidget {
  const _CitationSourceBody({required this.data});

  final CitationElementData data;

  @override
  State<_CitationSourceBody> createState() => _CitationSourceBodyState();
}

class _CitationSourceBodyState extends State<_CitationSourceBody> {
  bool _loadingSnippet = false;
  GroundingChunkSnippet? _snippet;
  bool _fetched = false;

  CitationElementData get _data => widget.data;

  bool get _canFetchSnippet =>
      (_data.origin == GroundingOrigin.implicit ||
          _data.origin == GroundingOrigin.kbTool) &&
      (_data.embeddingId ?? '').isNotEmpty &&
      (_data.queryId ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_canFetchSnippet) _fetchSnippet();
  }

  Future<void> _fetchSnippet() async {
    setState(() => _loadingSnippet = true);
    final GroundingChunkSnippet? snippet = await GroundingService.getChunkSnippet(
      _data.embeddingId!,
      queryId: _data.queryId!,
    );
    if (!mounted) return;
    setState(() {
      _snippet = snippet;
      _loadingSnippet = false;
      _fetched = true;
    });
  }

  Widget _body(bool isDark) {
    switch (_data.origin) {
      case GroundingOrigin.implicit:
      case GroundingOrigin.kbTool:
        if (!_canFetchSnippet) {
          return _unavailableText(isDark);
        }
        if (_loadingSnippet) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final String? content = _snippet?.content;
        if (!_fetched || content == null || content.trim().isEmpty) {
          return _unavailableText(isDark);
        }
        return CustomSelectableText(text: content);
      case GroundingOrigin.webSearch:
        if ((_data.url ?? '').isEmpty) return _unavailableText(isDark);
        return _ActionButton(
          label: _data.url!,
          icon: Symbols.open_in_new,
          onTap: () => DeviceService.openLink(_data.url!),
        );
      case GroundingOrigin.attachment:
        if ((_data.attachmentId ?? '').isEmpty) return _unavailableText(isDark);
        return _ActionButton(
          label: Strings.citationOpenAttachment.tr,
          icon: Symbols.attach_file,
          onTap: () => Get.find<PupauAttachmentsController>()
              .downloadAttachment(_data.attachmentId!),
        );
      case GroundingOrigin.unknown:
      case null:
        return _unavailableText(isDark);
    }
  }

  Widget _unavailableText(bool isDark) => Text(
    Strings.citationPreviewUnavailable.tr,
    style: StyleService.toolNormalTextStyle(isDark),
  );

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_data.resolvedName, style: StyleService.toolHeaderTextStyle(isDark)),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 12),
          child: Text(
            _data.originCategoryLabel,
            style: StyleService.toolNormalTextStyle(isDark),
          ),
        ),
        _body(isDark),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: MyStyles.pupauTheme(!Get.isDarkMode).primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StyleService.toolNormalTextStyle(isDark).copyWith(
                  color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
