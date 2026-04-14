import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/basic_app_bar.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

/// Full-screen Mermaid view: blocks the entire body with an opaque loading
/// layer until [mermaid.run] completes (not merely document load).
class ChatMermaidFull extends StatefulWidget {
  const ChatMermaidFull({super.key, required this.mermaidCode});

  final String mermaidCode;

  @override
  State<ChatMermaidFull> createState() => _ChatMermaidFullState();
}

class _ChatMermaidFullState extends State<ChatMermaidFull> {
  static const Duration _failSafeDuration = Duration(seconds: 25);

  late final WebUri _pageUri;
  bool _isLoading = true;
  Timer? _failSafe;

  @override
  void initState() {
    super.initState();
    final theme = MyStyles.pupauTheme(!Get.isDarkMode);
    _pageUri = _buildPageUri(theme);
    _failSafe = Timer(_failSafeDuration, _onMermaidReady);
  }

  @override
  void dispose() {
    _failSafe?.cancel();
    super.dispose();
  }

  void _onMermaidReady() {
    if (!mounted) return;
    _failSafe?.cancel();
    _failSafe = null;
    if (!_isLoading) return;
    setState(() {
      _isLoading = false;
    });
  }

  static String _cssRgb(Color c) {
    final int r = (c.r * 255.0).round().clamp(0, 255);
    final int g = (c.g * 255.0).round().clamp(0, 255);
    final int b = (c.b * 255.0).round().clamp(0, 255);
    return 'rgb($r,$g,$b)';
  }

  WebUri _buildPageUri(PupauThemeData theme) {
    final bool isDarkMode = Get.isDarkMode;
    final String html = _buildHtml(
      isDarkMode: isDarkMode,
      bodyBackgroundCss: _cssRgb(theme.white),
      bodyForegroundCss: _cssRgb(theme.black),
    );
    return WebUri.uri(
      Uri.dataFromString(html, mimeType: 'text/html', encoding: utf8),
    );
  }

  String _buildHtml({
    required bool isDarkMode,
    required String bodyBackgroundCss,
    required String bodyForegroundCss,
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes, maximum-scale=6.0">
        <style>
          html {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            -webkit-tap-highlight-color: transparent;
          }
          body {
            margin: 0;
            padding: 0;
            width: 100%;
            min-height: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            min-height: -webkit-fill-available;
            overflow: auto;
            display: flex;
            flex-direction: column;
            align-items: stretch;
            box-sizing: border-box;
            background-color: $bodyBackgroundCss;
            color: $bodyForegroundCss;
          }
          .mermaid {
            width: 100%;
            max-width: 100%;
            margin-block: auto;
            padding: 16px;
            box-sizing: border-box;
            display: flex;
            flex-shrink: 0;
            justify-content: center;
            align-items: center;
          }
          svg {
            max-width: 100% !important;
            height: auto !important;
          }
        </style>
        <script type="module">
          import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.5.0/dist/mermaid.esm.min.mjs';

          mermaid.initialize({
            startOnLoad: false,
            suppressErrorRendering: true,
            ${isDarkMode ? 'theme: "dark",' : ''}
          });

          (async () => {
            try {
              await mermaid.run({ querySelector: '.mermaid' });
            } catch (e) {
              console.error(e);
            }
            await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
            setTimeout(() => {
              const h = document.body ? document.body.scrollHeight : 0;
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('mermaidReady', h);
              }
            }, 0);
          })();
        </script>
      </head>
      <body>
        <div class="mermaid">
          ${TagService.cleanMermaidCode(widget.mermaidCode)}
        </div>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final Color scaffoldBg = MyStyles.pupauTheme(!Get.isDarkMode).white;

    return Scaffold(
      appBar: const BasicAppBar(title: "", hasBackground: true),
      backgroundColor: scaffoldBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: scaffoldBg,
            child: SafeArea(
              child: AbsorbPointer(
                absorbing: _isLoading,
                child: InAppWebView(
                  key: ValueKey<String>(_pageUri.toString()),
                  initialUrlRequest: URLRequest(url: _pageUri),
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: false,
                    supportZoom: true,
                  ),
                  onWebViewCreated: (webViewController) {
                    webViewController.addJavaScriptHandler(
                      handlerName: 'mermaidReady',
                      callback: (args) {
                        _onMermaidReady();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Material(
                color: scaffoldBg,
                child: SafeArea(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: MyStyles.pupauTheme(!Get.isDarkMode).accent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
