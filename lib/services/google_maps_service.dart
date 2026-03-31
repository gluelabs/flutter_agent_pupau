import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';

class GoogleMapsService {
  static void openGoogleMaps(GoogleMapData googleMapData) {
    String url;
    if (googleMapData.address != null && googleMapData.address!.isNotEmpty) {
      if (!kIsWeb && Platform.isAndroid) {
        url =
            'https://maps.google.com/?q=${Uri.encodeFull(googleMapData.address!)}';
      } else {
        url =
            'https://www.google.com/maps/search/?q=${Uri.encodeFull(googleMapData.address!)}';
      }
    } else if (googleMapData.position != null) {
      if (!kIsWeb && Platform.isAndroid) {
        url =
            'https://maps.google.com/?q=${googleMapData.position?.latitude},${googleMapData.position?.longitude}';
      } else {
        url =
            'https://www.google.com/maps?q=${googleMapData.position?.latitude},${googleMapData.position?.longitude}';
      }
    } else {
      return;
    }
    DeviceService.openLink(url, preferNonBrowserApp: true);
  }

  /// Opens Google Maps with turn-by-turn navigation to the given place.
  /// Uses native app schemes so the Maps app starts navigation when installed.
  static void openGoogleMapsNavigation(GoogleMapData googleMapData) {
    if (!kIsWeb && Platform.isAndroid) {
      String query;
      if (googleMapData.address != null && googleMapData.address!.isNotEmpty) {
        query = Uri.encodeQueryComponent(googleMapData.address!);
      } else if (googleMapData.position != null) {
        query =
            '${googleMapData.position!.latitude},${googleMapData.position!.longitude}';
      } else {
        return;
      }
      final Uri uri = Uri.parse('google.navigation:q=$query');
      DeviceService.openLinkUri(uri, preferNonBrowserApp: true);
    } else {
      // iOS: comgooglemaps://?daddr=...&directionsmode=driving
      String destinationAddress;
      if (googleMapData.address != null && googleMapData.address!.isNotEmpty) {
        destinationAddress = Uri.encodeQueryComponent(googleMapData.address!);
      } else if (googleMapData.position != null) {
        destinationAddress =
            '${googleMapData.position!.latitude},${googleMapData.position!.longitude}';
      } else {
        return;
      }
      final Uri uri = Uri.parse(
          'comgooglemaps://?daddr=$destinationAddress&directionsmode=driving');
      DeviceService.openLinkUri(uri, preferNonBrowserApp: true);
    }
  }

  /// Returns true if [url] is a Google Maps directions/navigation link
  /// (user tapped "Directions" in the embed).
  static bool isMapsDirectionsUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    return (lower.contains('google.com/maps/dir') ||
        lower.contains('/dir/') ||
        lower.contains('directionsmode=') ||
        lower.contains('travelmode='));
  }

  /// Returns true if [url] is a Google Maps URL that should open externally
  /// (browser or native Maps app) instead of inside the webview.
  /// Excludes the embed API URL so the iframe can load the map.
  static bool isExternalMapsUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    // Do not open externally for the embed API (iframe source) — only on user tap to directions etc.
    if (lower.contains('/maps/embed') || lower.contains('maps/embed/')) {
      return false;
    }
    return lower.contains('maps.google.com') ||
        lower.contains('google.com/maps') ||
        lower.startsWith('https://maps.app.goo.gl/') ||
        lower.startsWith('http://maps.app.goo.gl/');
  }
}

class GoogleMapData {
  final LatLng? position;
  final String? address;

  GoogleMapData({this.position, this.address});
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude});
}