import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_deleted_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_distinct_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_error_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_info_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_row_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_sample_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_search.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_summary_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info_list.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class MessageSpreadsheet extends StatelessWidget {
  const MessageSpreadsheet({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseSpreadsheetData? data = toolUseMessage?.spreadsheetData;
    if (data == null) return const SizedBox.shrink();

    switch (data.resultType) {
      case SpreadsheetToolResultType.error:
        return SpreadsheetErrorBox(
          message: data.errorMessage ?? (data.raw?['error']?.toString() ?? ''),
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.info:
        return SpreadsheetInfoCard(data: data, isAnonymous: isAnonymous);
      case SpreadsheetToolResultType.sample:
        return SpreadsheetSampleCard(data: data, isAnonymous: isAnonymous);
      case SpreadsheetToolResultType.search:
        return SpreadsheetSearchResults(
          data: data,
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.rowCreated:
        return SpreadsheetRowCard(
          title: Strings.spreadsheetRowAdded.tr,
          icon: Symbols.check_circle,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).green,
          row: data.row ?? const {},
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.rowUpdated:
        return SpreadsheetRowCard(
          title: Strings.spreadsheetRowUpdated.tr,
          icon: Symbols.edit,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          row: data.row ?? const {},
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.rowDeleted:
        return SpreadsheetDeletedCard(
          data: data,
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.summary:
        return SpreadsheetSummaryCard(
          data: data,
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.distinct:
        return SpreadsheetDistinctCard(
          data: data,
          isAnonymous: isAnonymous,
        );
      case SpreadsheetToolResultType.raw:
        return ToolUseInfoList(
          infoList: toolUseMessage?.nativeToolData ?? const {},
          isAnonymous: isAnonymous,
          forceExpanded: true,
        );
    }
  }
}
