import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_mail.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_mail_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

void main() {
  Widget wrap(Widget child) => GetMaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  ToolUseMessage mailMessage(String body) => ToolUseMessage(
        id: 'msg-1',
        assistantName: 'Test Assistant',
        type: ToolUseType.nativeToolsMail,
        toolName: 'send_email',
        queryGroupId: 'group-1',
        mailData: ToolUseMailData(
          to: 'someone@example.com',
          subject: 'Test subject',
          body: body,
          cc: '',
          bcc: '',
          attachConversation: false,
          statusMessage: 'sent',
        ),
      );

  testWidgets(
    'MessageMail strips an <iframe> out of the HtmlWidget content entirely',
    (tester) async {
      const String iframeUrl = 'https://example.com/embed';
      await tester.pumpWidget(wrap(MessageMail(
        toolUseMessage: mailMessage(
          '<html><body><p>Hello</p>'
          '<iframe src="$iframeUrl" width="300" height="200"></iframe>'
          '</body></html>',
        ),
        isAnonymous: false,
      )));
      await tester.pumpAndSettle();

      final HtmlWidget htmlWidget = tester.widget<HtmlWidget>(
        find.byType(HtmlWidget),
      );
      expect(htmlWidget.html.contains('<iframe'), isFalse);
      expect(htmlWidget.html.contains('Hello'), isTrue);
    },
  );

  testWidgets(
    'MessageMail renders the stripped iframe URL as an independent button',
    (tester) async {
      const String iframeUrl = 'https://example.com/embed';
      await tester.pumpWidget(wrap(MessageMail(
        toolUseMessage: mailMessage(
          '<html><body><p>Hello</p>'
          '<iframe src="$iframeUrl" width="300" height="200"></iframe>'
          '</body></html>',
        ),
        isAnonymous: false,
      )));
      await tester.pumpAndSettle();

      // CustomButton renders its text via a nested RichText/TextSpan, which
      // find.textContaining doesn't see into - check the button's own
      // `text` field instead, which is the actual widget-level contract.
      final CustomButton button = tester.widget<CustomButton>(
        find.byType(CustomButton),
      );
      expect(button.text, contains(iframeUrl));
    },
  );

  testWidgets(
    'MessageMail with no iframe leaves the html untouched',
    (tester) async {
      const String html = '<html><body><p>No embeds here.</p></body></html>';
      await tester.pumpWidget(wrap(MessageMail(
        toolUseMessage: mailMessage(html),
        isAnonymous: false,
      )));
      await tester.pumpAndSettle();

      final HtmlWidget htmlWidget = tester.widget<HtmlWidget>(
        find.byType(HtmlWidget),
      );
      expect(htmlWidget.html, html);
    },
  );
}
