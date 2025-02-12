import 'dart:convert';
import 'package:http/http.dart' as http;

class PharmacyService {
  static const String apiKey = "apikey 3txcwXm2c66ZYan8ToE33h:2sVrFHRswbVFfCILiuALzk";
  static const String baseUrl = "https://api.collectapi.com/health/dutyPharmacy";

  static Future<List> fetchPharmacies(String city) async {
    var formattedCity = Uri.encodeComponent(city);
    var url = Uri.parse('$baseUrl?il=$formattedCity');

    var response = await http.get(
      url,
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      },
    );

    print("📡 İstek URL: $url");
    print("📩 API Yanıtı: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['result'] == null) {
        print("⚠️ Hata: 'result' verisi eksik!");
        return [];
      }

      return data['result'];
    } else {
      print("❌ API Hatası: ${response.statusCode} - ${response.body}");
      return [];
    }
  }
}
