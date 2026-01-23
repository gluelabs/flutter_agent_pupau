import 'package:flutter_agent_pupau/services/device_service.dart';
import 'dart:io';
class GoogleMapsService {
  static void openGoogleMaps(GoogleMapData googleMapData) {
    String url;
    if (googleMapData.address != null && googleMapData.address!.isNotEmpty) {
      if (Platform.isAndroid) {
        url =
            'https://maps.google.com/?q=${Uri.encodeFull(googleMapData.address!)}';
      } else {
        url =
            'https://www.google.com/maps/search/?q=${Uri.encodeFull(googleMapData.address!)}';
      }
    } else if (googleMapData.position != null) {
      if (Platform.isAndroid) {
        url =
            'https://maps.google.com/?q=${googleMapData.position?.latitude},${googleMapData.position?.longitude}';
      } else {
        url =
            'https://www.google.com/maps?q=${googleMapData.position?.latitude},${googleMapData.position?.longitude}';
      }
    } else {
      return;
    }
    DeviceService.openLink(url);
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
