import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_mermaid_full.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Persists measured Mermaid WebView heights so when list items are disposed
/// past [cacheExtent] and rebuilt, layout does not jump from the default stub
/// height to the real height.
class MermaidHeightCache {
  static final Map<String, double> _heights = {};

  static double? get(String key) => _heights[key];

  static void put(String key, double height) {
    _heights[key] = height;
  }
}

class MermaidContainer extends StatefulWidget {
  const MermaidContainer({
    super.key,
    required this.cacheKey,
    required this.mermaidCode,
  });

  final String cacheKey;
  final String mermaidCode;

  @override
  State<MermaidContainer> createState() => _MermaidContainerState();
}

class _MermaidContainerState extends State<MermaidContainer>
    with AutomaticKeepAliveClientMixin {
  static const double _defaultHeight = 300.0;

  late double _contentHeight;
  late bool _isLoading;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final double? cached = MermaidHeightCache.get(widget.cacheKey);
    _contentHeight = cached ?? _defaultHeight;
    _isLoading = cached == null;
  }

  @override
  void didUpdateWidget(MermaidContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cacheKey != oldWidget.cacheKey) {
      final double? cached = MermaidHeightCache.get(widget.cacheKey);
      _contentHeight = cached ?? _defaultHeight;
      _isLoading = cached == null;
    }
  }

  void _updateHeight(double height) {
    if (!mounted) return;
    if (!height.isFinite) return;
    // Never shrink: a mid-frame scroll extent reduction can cause a brief blank
    // viewport while the scroll position is being clamped.
    final double nextHeight = height < _defaultHeight
        ? _defaultHeight
        : (height < _contentHeight ? _contentHeight : height);
    MermaidHeightCache.put(widget.cacheKey, nextHeight);
    setState(() {
      _contentHeight = nextHeight;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDarkMode = Get.isDarkMode;

    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            margin: 0; 
            padding: 0; 
            ${isDarkMode ? 'background-color: transparent; color: white;' : ''}
          }
          .mermaid { 
            width: 100%; 
            ${isDarkMode ? 'color: white;' : ''}
          }
        </style>
        <script type="module">
          import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.5.0/dist/mermaid.esm.min.mjs';
          mermaid.initialize({
            startOnLoad: true, 
            suppressErrorRendering: true,
            ${isDarkMode ? 'theme: "dark",' : ''}
          });
          
          window.addEventListener('load', function() {
            setTimeout(() => {
              const height = document.body.scrollHeight; 
              window.flutter_inappwebview.callHandler('getContentHeight', height);
            }, 600);
          });
        </script>
      </head>
      <body>
        <div class="mermaid">
          ${TagService.cleanMermaidCode(widget.mermaidCode)}
        </div>
      </body>
      </html>
    ''';

    void openFull() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMermaidFull(mermaidCode: widget.mermaidCode),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // SizedBox height is updated via setState; InAppWebView itself is
              // never rebuilt, so _PlatformViewPlaceholderBox is never detached
              // mid-frame (avoids the getTransformTo null-check crash).
              SizedBox(
                width: constraints.maxWidth,
                height: _contentHeight,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri.uri(
                      Uri.dataFromString(
                        htmlContent,
                        mimeType: 'text/html',
                        encoding: Encoding.getByName('utf-8'),
                      ),
                    ),
                  ),
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: true,
                  ),
                  onWebViewCreated: (webViewController) {
                    webViewController.addJavaScriptHandler(
                      handlerName: 'getContentHeight',
                      callback: (args) {
                        if (args.isNotEmpty && args[0] is num) {
                          _updateHeight((args[0] as num).toDouble());
                        }
                      },
                    );
                  },
                  onLoadStop: (webViewController, url) {
                    webViewController.evaluateJavascript(
                      source:
                          'window.flutter_inappwebview.callHandler(\'getContentHeight\', document.body.scrollHeight);',
                    );
                  },
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  color: MyStyles.pupauTheme(!Get.isDarkMode).accent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: openFull,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Symbols.open_in_full,
                        size: 22,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).white,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
