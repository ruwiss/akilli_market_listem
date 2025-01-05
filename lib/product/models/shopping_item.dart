class ShoppingItem {
  final int? id;
  final String name;
  final double price;
  final double unit_price;
  final double quantity;
  final String? unit;
  final String? description;
  final String? imageUrl;
  final String? marketImageUrl;
  final bool isCompleted;

  ShoppingItem({
    this.id,
    required this.name,
    required this.price,
    this.unit_price = 0,
    required this.quantity,
    this.unit,
    this.description,
    this.imageUrl,
    this.marketImageUrl,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit_price': unit_price,
      'quantity': quantity,
      'unit': unit,
      'description': description,
      'image_url': imageUrl,
      'market_image_url': marketImageUrl,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      unit_price: map['unit_price'] ?? 0,
      quantity: map['quantity'],
      unit: map['unit'],
      description: map['description'],
      imageUrl: map['image_url'],
      marketImageUrl: map['market_image_url'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  double get totalPrice => price * quantity;
}
