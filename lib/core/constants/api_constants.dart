class ApiConstants {
  static const String baseUrl = 'http://192.168.1.103:8000';
  static const String apiUrl = '$baseUrl/api';

  // Image URLs
  static String getImageUrl(String imagePath) => '$baseUrl$imagePath';
  static String getMerchantLogoUrl(String logoPath) => '$baseUrl$logoPath';
}
