import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

/// Human-readable labels for the JIT attachment tools
/// (list_attachments / attachment_outline / attachment_read / attachment_grep /
/// attachment_search). Used both for the loading spinner label and for the
/// completed tool bubble title.
class AttachmentToolLabelService {
  static const List<String> toolNames = <String>[
    'list_attachments',
    'attachment_outline',
    'attachment_read',
    'attachment_grep',
    'attachment_search',
  ];

  static bool isAttachmentToolName(String toolName) =>
      toolNames.contains(toolName.trim());

  /// Fallback label shown before [toolArgs] are known (e.g. on TOOL_PENDING).
  static String genericLabel(String toolName) {
    switch (toolName.trim()) {
      case 'list_attachments':
        return Strings.attachmentToolLoadingList.tr;
      case 'attachment_outline':
        return Strings.attachmentToolLoadingOutline.tr;
      case 'attachment_read':
        return Strings.attachmentToolLoadingRead.tr;
      case 'attachment_grep':
        return Strings.attachmentToolLoadingGrep.tr;
      case 'attachment_search':
        return Strings.attachmentToolLoadingSearch.tr;
      default:
        return '';
    }
  }

  /// Rich label derived from [toolArgs] (e.g. "Reading report.pdf (lines
  /// 1-200)"). Returns null when there isn't enough information yet, in
  /// which case callers should fall back to [genericLabel].
  static String? richLabel(String toolName, Map<String, dynamic>? toolArgs) {
    if (toolArgs == null || toolArgs.isEmpty) return null;
    final String fileName = getString(
      toolArgs['fileName'] ?? toolArgs['filename'],
    ).trim();

    switch (toolName.trim()) {
      case 'attachment_read':
        if (fileName.isEmpty) return null;
        final String fromLine = getString(toolArgs['fromLine']).trim();
        final String toLine = getString(toolArgs['toLine']).trim();
        if (fromLine.isEmpty && toLine.isEmpty) {
          return Strings.attachmentToolReadLabel.trParams({
            'fileName': fileName,
          });
        }
        return Strings.attachmentToolReadRangeLabel.trParams({
          'fileName': fileName,
          'fromLine': fromLine.isEmpty ? '1' : fromLine,
          'toLine': toLine.isEmpty ? '?' : toLine,
        });

      case 'attachment_grep':
        final String pattern = getString(toolArgs['pattern']).trim();
        if (pattern.isEmpty) return null;
        if (fileName.isEmpty) {
          return Strings.attachmentToolGrepAllLabel.trParams({
            'pattern': pattern,
          });
        }
        return Strings.attachmentToolGrepLabel.trParams({
          'pattern': pattern,
          'fileName': fileName,
        });

      case 'attachment_search':
        final String searchText = getString(toolArgs['searchText']).trim();
        if (searchText.isEmpty) return null;
        return Strings.attachmentToolSearchLabel.trParams({
          'searchText': searchText,
        });

      case 'attachment_outline':
        if (fileName.isEmpty) return null;
        return Strings.attachmentToolOutlineLabel.trParams({
          'fileName': fileName,
        });

      case 'list_attachments':
        return null;

      default:
        return null;
    }
  }
}
