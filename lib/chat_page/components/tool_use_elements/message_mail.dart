import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_mail_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

// <iframe>s are stripped out of the HTML entirely before HtmlWidget ever
// sees them (see _stripIframes below) and rendered as independent
// CustomButtons instead - this factory's webView/buildWebViewLinkOnly stay
// only as a safety net for any malformed <iframe> markup that regex doesn't
// match, so untrusted email content is never embedded as a live platform
// view either way.
class _EmailHtmlWidgetFactory extends WidgetFactory {
  @override
  bool get webView => false;

  // Replaces fwfh_webview's own default fallback (a bare GestureDetector
  // wrapping Text(url) - the whole text area is tappable) with an explicit
  // CustomButton. Only a tap on the button itself opens the link; nothing
  // else in the mail body becomes tappable because of this.
  @override
  Widget? buildWebViewLinkOnly(BuildTree meta, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomButton(
          text: '${Strings.navigateTo.tr} $url',
          isPrimary: false,
          hasBorders: true,
          onPressed: () => DeviceService.openLink(url),
        ),
      ),
    );
  }

  // WebViewFactory.parse() applies `height: ${height}px; width: ${width}px;`
  // to the iframe's CSS box whenever the tag declares width/height
  // attributes - correct for an actual embedded webview, but in link-only
  // mode it just reserves a large fixed-size empty box around our small
  // button. Stripping those attributes before delegating makes it fall
  // through to that same method's own default case (height/width: auto),
  // which sizes the box to whatever we actually render instead.
  @override
  void parse(BuildTree meta) {
    if (meta.element.localName == 'iframe') {
      meta.element.attributes.remove('width');
      meta.element.attributes.remove('height');
    }
    super.parse(meta);
  }
}

// Matches a whole <iframe ...>...</iframe> (or a self-closing/unclosed
// <iframe ... />) element, capturing its attribute string.
final RegExp _iframeTagRegex = RegExp(
  r'<iframe\b([^>]*)>(?:[\s\S]*?<\/iframe\s*>)?',
  caseSensitive: false,
);
final RegExp _srcAttrRegex = RegExp(
  '''src\\s*=\\s*["']([^"']*)["']''',
  caseSensitive: false,
);

/// Removes every <iframe> from [html] entirely and returns their `src`
/// URLs separately, instead of letting flutter_widget_from_html embed a
/// replacement widget *through* its own inline/WidgetSpan machinery for
/// that tag.
({String html, List<String> iframeUrls}) _stripIframes(String html) {
  final List<String> urls = [];
  final String stripped = html.replaceAllMapped(_iframeTagRegex, (match) {
    final String attrs = match.group(1) ?? '';
    final String? url = _srcAttrRegex.firstMatch(attrs)?.group(1);
    if (url != null && url.trim().isNotEmpty) {
      urls.add(url.trim());
    }
    return '';
  });
  return (html: stripped, iframeUrls: urls);
}

class MessageMail extends StatelessWidget {
  const MessageMail({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseMailData? data = toolUseMessage?.mailData;
    final bool isTablet = DeviceService.isTablet;

    final TextStyle labelStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode || isAnonymous ? Colors.white : Colors.black87,
    );
    final TextStyle secondaryTextStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      color: Get.isDarkMode || isAnonymous ? Colors.white70 : Colors.black87,
    );

    if (data == null) {
      final String fallbackBody =
          toolUseMessage?.nativeToolData?['message']?.toString() ?? '';
      return fallbackBody.trim().isEmpty
          ? const SizedBox.shrink()
          : CustomSelectableText(text: fallbackBody, isAnonymous: isAnonymous);
    }

    final String bodyPreview = data.hasHtmlBody
        ? data.bodyPlaintextPreview
        : data.body.trim();

    String htmlBodyToRender = data.body.trim();
    List<String> strippedIframeUrls = const [];
    if (data.hasHtmlBody) {
      final stripped = _stripIframes(htmlBodyToRender);
      htmlBodyToRender = stripped.html;
      strippedIframeUrls = stripped.iframeUrls;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.to.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.toEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.to.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.cc.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.ccEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.cc.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.bcc.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.bccEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.bcc.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.subject.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.subject.tr}: ', style: labelStyle),
              Expanded(
                child: Text(data.subject.trim(), style: secondaryTextStyle),
              ),
            ],
          ),
        ],
        if (bodyPreview.trim().isNotEmpty || strippedIframeUrls.isNotEmpty) ...[
          Theme(
            data: StyleService.expansionTileThemeData(context, isAnonymous),
            child: ExpansionTile(
              // Without an explicit identity, this tile's own expand state
              // (initiallyExpanded is only read once, in its State's
              // initState) can get reused across different messages in the
              // same list position.
              key: ValueKey('mail-body-${toolUseMessage?.id}'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: true,
              title: Text(Strings.body.tr, style: labelStyle),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: data.hasHtmlBody
                      ? HtmlWidget(
                          // HtmlWidget's factoryBuilder only ever runs once,
                          // inside its State.initState() - never again on
                          // rebuild. With no key anywhere in this chain,
                          // Flutter's element reconciliation can reuse the
                          // same State (and its already-locked-in factory)
                          // across what are logically different messages in
                          // the same list position. Tying the key to the
                          // message id and body guarantees a fresh instance
                          // per distinct message.
                          key: ValueKey(
                            '${toolUseMessage?.id}-$htmlBodyToRender',
                          ),
                          htmlBodyToRender,
                          textStyle: secondaryTextStyle,
                          factoryBuilder: () => _EmailHtmlWidgetFactory(),
                          onTapUrl: (url) {
                            DeviceService.openLink(url);
                            return true;
                          },
                        )
                      : CustomSelectableText(
                          text: data.body.trim(),
                          isAnonymous: isAnonymous,
                          openLinks: true,
                        ),
                ),
                // Rendered as fully independent widgets here, outside
                // HtmlWidget entirely - see _stripIframes for why an
                // <iframe>'s replacement content can't safely be embedded
                // *through* flutter_widget_from_html's own inline widget
                // machinery.
                for (final String url in strippedIframeUrls)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        text: 'Open $url',
                        isPrimary: false,
                        hasBorders: true,
                        onPressed: () => DeviceService.openLink(url),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
