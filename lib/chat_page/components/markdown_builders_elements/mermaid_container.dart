import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

class MermaidContainer extends StatefulWidget {
  const MermaidContainer({super.key, required this.mermaidCode});

  final String mermaidCode;

  @override
  State<MermaidContainer> createState() => _MermaidContainerState();
}

class _MermaidContainerState extends State<MermaidContainer> {
  double _contentHeight = 300.0;
  bool _isLoading = true;

  void _updateHeight(double height) {
    if (mounted) {
      setState(() {
        _contentHeight = height;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
