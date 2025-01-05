class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double unitPrice;
  final String quantity;
  final String unit;
  final String merchantId;
  final String merchantLogo;
  final String image;
  final String url;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.merchantId,
    required this.merchantLogo,
    required this.image,
    required this.url,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      merchantId: json['merchant_id'].toString(),
      merchantLogo: json['merchant_logo'] as String,
      image: json['image'] as String,
      url: json['url'] as String,
    );
  }
}

class ProductDetail {
  final String id;
  final String name;
  final String? description;
  final List<SpecGroup> specs;
  final List<PriceHistory> priceHistory;
  final List<Offer> offers;

  ProductDetail({
    required this.id,
    required this.name,
    this.description,
    required this.specs,
    required this.priceHistory,
    required this.offers,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      specs: (json['specs'] as List<dynamic>)
          .map((e) => SpecGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      priceHistory: (json['price_history'] as List<dynamic>)
          .map((e) => PriceHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      offers: (json['offers'] as List<dynamic>)
          .map((e) => Offer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpecGroup {
  final String group;
  final List<SpecItem> items;

  SpecGroup({
    required this.group,
    required this.items,
  });

  factory SpecGroup.fromJson(Map<String, dynamic> json) {
    return SpecGroup(
      group: json['group'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => SpecItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpecItem {
  final String name;
  final String value;

  SpecItem({
    required this.name,
    required this.value,
  });

  factory SpecItem.fromJson(Map<String, dynamic> json) {
    return SpecItem(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}

class PriceHistory {
  final DateTime date;
  final double price;

  PriceHistory({
    required this.date,
    required this.price,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Offer {
  final String merchantId;
  final String merchantName;
  final String merchantLogo;
  final double price;
  final double unitPrice;

  Offer({
    required this.merchantId,
    required this.merchantName,
    required this.merchantLogo,
    required this.price,
    required this.unitPrice,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      merchantId: json['merchant_id'].toString(),
      merchantName: json['merchant_name'] as String,
      merchantLogo: json['merchant_logo'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
