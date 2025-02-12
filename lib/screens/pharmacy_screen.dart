import 'package:flutter/material.dart';
import 'package:nobetci_eczane_app/services/pharmacy_service.dart';
import 'package:nobetci_eczane_app/services/konum_servisi.dart';
import 'package:geolocator/geolocator.dart';

class PharmacyScreen extends StatefulWidget {
  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  List pharmacies = [];
  TextEditingController cityController = TextEditingController();
  bool isLoading = false;

  Future<void> getPharmacies() async {
    setState(() => isLoading = true);

    String city = cityController.text.isNotEmpty
        ? cityController.text
        : await KonumServisi.konumuAl() ?? "";

    if (city.isEmpty) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Konum alınamadı, lütfen şehir girin.")),
      );
      return;
    }

    var data = await PharmacyService.fetchPharmacies(city);

    Position? userLocation;
    try {
      userLocation = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Konum alınamadı: $e");
    }

    if (userLocation != null) {
      data.sort((a, b) {
        double latA = (a["lat"] ?? 0).toDouble();
        double lonA = (a["lon"] ?? 0).toDouble();
        double latB = (b["lat"] ?? 0).toDouble();
        double lonB = (b["lon"] ?? 0).toDouble();

        double distanceA = Geolocator.distanceBetween(
          userLocation!.latitude, userLocation.longitude,
          latA, lonA
        );
        double distanceB = Geolocator.distanceBetween(
          userLocation.latitude, userLocation.longitude,
          latB, lonB
        );
        return distanceA.compareTo(distanceB);
      });
    }

    setState(() {
      pharmacies = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nöbetçi Eczaneler'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'Şehir Girin (Boş bırakılırsa konum kullanılır)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: getPharmacies,
              icon: Icon(Icons.search),
              label: Text('Nöbetçi Eczaneleri Getir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
            ),
            SizedBox(height: 15),
            isLoading
                ? CircularProgressIndicator()
                : pharmacies.isEmpty
                    ? Center(child: Text("Eczane bulunamadı."))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: pharmacies.length,
                          itemBuilder: (context, index) {
                            var pharmacy = pharmacies[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.local_pharmacy, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text(
                                          pharmacy['name'] ?? 'Bilinmiyor',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      pharmacy['address'] ?? 'Adres yok',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: Icon(Icons.call, color: Colors.green),
                                          label: Text("Ara"),
                                          onPressed: () {
                                            // Telefon araması ekleyebilirsiniz
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
