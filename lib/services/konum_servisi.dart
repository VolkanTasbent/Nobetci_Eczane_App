import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class KonumServisi {
  static Future<String?> konumuAl() async {
    bool servisIzni;
    LocationPermission izin;

    servisIzni = await Geolocator.isLocationServiceEnabled();
    if (!servisIzni) return null;

    izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
      if (izin == LocationPermission.denied) return null;
    }
    if (izin == LocationPermission.deniedForever) return null;

    Position konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    
    List<Placemark> placemarks = await placemarkFromCoordinates(konum.latitude, konum.longitude);
    return placemarks.isNotEmpty ? placemarks[0].administrativeArea : null;
  }
}
