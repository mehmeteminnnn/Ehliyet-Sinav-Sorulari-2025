import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppDialog {
  // TODO: Burayı kendi paket adınızla değiştirin (android/app/build.gradle dosyasında applicationId olarak yazar)
  // Örneğin: 'com.mehmet.ehliyet'
  static const String _packageName = 'com.meminapp.ehliyet2025';

  /// Diyaloğu gösteren fonksiyon
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Kullanıcı dışarı tıklayarak kapatamasın
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 10),
              Text('Destek Olun'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Merhaba! Ben yeni bir geliştiriciyim.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Uygulamamı geliştirmeye devam edebilmem için desteğine ihtiyacım var. '
                  'Eğer testi beğendiysen ve faydalı bulduysan, Play Store\'da 5 yıldız vererek beni çok mutlu edebilirsin.',
                ),
                SizedBox(height: 10),
                Text('Şimdiden teşekkürler!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Daha Sonra',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('5 Yıldız Ver'),
              onPressed: () {
                _openStore();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Play Store'u açan yardımcı fonksiyon
  static Future<void> _openStore() async {
    final Uri marketUrl = Uri.parse("market://details?id=$_packageName");
    final Uri webUrl = Uri.parse(
        "https://play.google.com/store/apps/details?id=$_packageName");

    try {
      if (await canLaunchUrl(marketUrl)) {
        await launchUrl(marketUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Store açılamadı: $e");
    }
  }
}
