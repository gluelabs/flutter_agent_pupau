import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/google_maps_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class GoogleMapContainer extends StatefulWidget {
  final GoogleMapData googleMapData;

  const GoogleMapContainer({super.key, required this.googleMapData});

  @override
  State<GoogleMapContainer> createState() => _GoogleMapContainerState();
}

class _GoogleMapContainerState extends State<GoogleMapContainer> {
  bool _hasError = false;
  final ChatController _controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    final String? apiKey = _controller.pupauConfig?.googleMapsApiKey;
    final bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MyStyles.pupauTheme(
                !Get.isDarkMode,
              ).lilacPressed, // Adjust as per your theme
            ),
          ),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (apiKey == null || apiKey.trim() == "") {
                    return _buildErrorMessage(
                      constraints,
                      Strings.googleMapsApiKeyNotConfigured.tr,
                      isTablet,
                    );
                  }

                  if (_hasError) {
                    return _buildErrorMessage(
                      constraints,
                      Strings.googleMapsApiKeyFailed.tr,
                      isTablet,
                    );
                  }

                  final String htmlContent =
                      '''
  <html>
    <head>
      <script>
        window.onerror = function(msg, url, line) {
          if (msg && (msg.toString().includes('Google Maps') || 
              msg.toString().includes('API key') || 
              msg.toString().includes('403') || 
              msg.toString().includes('400'))) {
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              window.flutter_inappwebview.callHandler('onGoogleMapsError');
            }
          }
        };
      </script>
    </head>
    <body>
      <iframe 
        width="100%" 
        height="100%" 
        load="lazy" 
        allowfullscreen
        src="${generateGoogleMapsUrl(widget.googleMapData, apiKey)}">
      </iframe>
    </body>
  </html>
  ''';
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth,
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
                        onWebViewCreated: (controller) {
                          controller.addJavaScriptHandler(
                            handlerName: 'onGoogleMapsError',
                            callback: (args) {
                              if (mounted) {
                                setState(() {
                                  _hasError = true;
                                });
                              }
                            },
                          );
                        },
                        onReceivedError: (controller, request, error) {
                          if (mounted) {
                            setState(() {
                              _hasError = true;
                            });
                          }
                        },
                        onReceivedHttpError: (controller, request, response) {
                          // Google Maps API typically returns 403 or 400 for invalid API keys
                          if (response.statusCode != null &&
                              response.statusCode! >= 400 &&
                              mounted) {
                            setState(() {
                              _hasError = true;
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: CustomButton(
                  iconIsLeft: false,
                  onPressed: () =>
                      GoogleMapsService.openGoogleMaps(widget.googleMapData),
                  icon: Icon(
                    Icons.directions,
                    color: Get.isDarkMode ? Colors.black : Colors.white,
                  ),
                  text: 'Google Maps',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    BoxConstraints constraints,
    String message,
    bool isTablet,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: constraints.maxWidth,
        height: constraints.maxWidth,
        color: MyStyles.pupauTheme(
          !Get.isDarkMode,
        ).lilacPressed.withValues(alpha: 0.1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isTablet ? 17 : 15),
            ),
          ),
        ),
      ),
    );
  }

  String generateGoogleMapsUrl(GoogleMapData googleMapData, String apiKey) {
    String baseUrl =
        'https://www.google.com/maps/embed/v1/place?zoom=17&key=$apiKey';
    if (googleMapData.address?.isNotEmpty ?? false) {
      return '$baseUrl&q=${googleMapData.address}';
    }
    return '$baseUrl&q=${googleMapData.position?.latitude ?? 0},${googleMapData.position?.longitude ?? 0}';
  }
}
