import 'package:shared_preferences/shared_preferences.dart';

/// Sayfa bazlı uygulama turu durumunu kalıcı olarak saklar.
///
/// Her sayfa için ayrı bir anahtar tutulur; böylece kullanıcı bir sayfayı
/// ilk kez gördükten sonra aynı tur sonraki girişlerde otomatik açılmaz.
class AppTourService {
  static const _storagePrefix = 'app_tour.completed.';

  Future<bool> isCompleted(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_storagePrefix$tourId') ?? false;
  }

  Future<void> markCompleted(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_storagePrefix$tourId', true);
  }

  /// Test, QA veya ayarlar ekranından manuel tekrar gösterim için kullanılabilir.
  Future<void> reset(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_storagePrefix$tourId');
  }
}

class AppTourIds {
  const AppTourIds._();

  // Tur içerikleri değiştiğinde ID'yi sürümlemek mevcut kullanıcılarda
  // eski "tamamlandı" kaydının yeni kartları engellemesini önler.
  static const dashboard = 'dashboard_v2';
}
