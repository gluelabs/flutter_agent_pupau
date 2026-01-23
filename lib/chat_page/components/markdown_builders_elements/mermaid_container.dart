import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

class MermaidController extends GetxController {
  final String mermaidCode;

  MermaidController({required this.mermaidCode});

  RxDouble contentHeight = 300.0.obs;
  RxBool isLoading = true.obs;
  final double minHeight = 100.0;

  void updateHeight(double height) {
    contentHeight.value = height;
    isLoading.value = false;
  }
}

class MermaidContainer extends StatelessWidget {
  final String mermaidCode;

  const MermaidContainer({super.key, required this.mermaidCode});

  @override
  Widget build(BuildContext context) {
    // Create or find the controller
    final MermaidController controller = Get.put(
      MermaidController(mermaidCode: mermaidCode),
      tag: mermaidCode, // Use the mermaid code as a unique tag
      permanent: false,
    );

    // Check if dark mode is enabled
    final bool isDarkMode = Get.isDarkMode;

    // HTML content that loads Mermaid.js and the Mermaid diagram
    String htmlContent = '''
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
          
          // Function to measure content height and send it to Flutter
          window.addEventListener('load', function() {
            setTimeout(() => {
              const height = document.body.scrollHeight; 
              window.flutter_inappwebview.callHandler('getContentHeight', height);
            }, 600); // Small delay to ensure diagram is rendered
          });
        </script>
      </head>
      <body>
        <div class="mermaid">
          ${TagService.cleanMermaidCode(mermaidCode)}
        </div>
      </body>
      </html>
    ''';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Obx(() => SizedBox(
                  width: constraints.maxWidth,
                  height: controller.contentHeight.value,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                        url: WebUri.uri(Uri.dataFromString(htmlContent,
                            mimeType: 'text/html',
                            encoding: Encoding.getByName('utf-8')))),
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                    ),
                    onWebViewCreated: (webViewController) {
                      webViewController.addJavaScriptHandler(
                        handlerName: 'getContentHeight',
                        callback: (args) {
                          if (args.isNotEmpty && args[0] is num) {
                            controller
                                .updateHeight((args[0] as num).toDouble());
                          }
                        },
                      );
                    },
                    onLoadStop: (webViewController, url) {
                      // Backup method to get height in case the JavaScript event doesn't fire
                      webViewController.evaluateJavascript(source: '''
                    window.flutter_inappwebview.callHandler('getContentHeight', document.body.scrollHeight);
                  ''');
                    },
                  ),
                )),
            Obx(() => controller.isLoading.value
                ? Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}
