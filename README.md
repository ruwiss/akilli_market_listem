# Akıllı Alışveriş Listem

Bu proje, Flutter kullanılarak geliştirilmiş modern bir alışveriş listesi mobil uygulamasıdır. MVVM (Model-View-ViewModel) mimarisi kullanılarak temiz ve sürdürülebilir bir kod yapısı oluşturulmuştur.

## Özellikler

- Alışveriş listesi oluşturma ve yönetme
- Ürünleri kategorilere ayırma
- Alışveriş geçmişi ve istatistikler
- Offline kullanım için yerel veritabanı desteği
- Modern ve kullanıcı dostu arayüz
- Sürükle-bırak ile kolay liste düzenleme
- Alışveriş bütçesi takibi ve grafikleri

## Kullanılan Teknolojiler

- **State Management:** Provider
- **Routing:** Go Router
- **API İletişimi:** Dio
- **Veritabanı:** SQLite
- **Grafikler:** FL Chart
- **Görsel Önbellekleme:** Cached Network Image
- **Bildirimler:** Toastification

## Mimari

Uygulama MVVM mimarisi ile geliştirilmiş olup, aşağıdaki katmanlardan oluşmaktadır:

- **Model:** Veri modelleri ve iş mantığı
- **View:** Kullanıcı arayüzü bileşenleri
- **ViewModel:** View ve Model arasındaki iletişimi sağlayan katman
