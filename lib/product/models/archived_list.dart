import 'shopping_item.dart';

class ArchivedList {
  final int? id;
  final String date;
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  ArchivedList({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'totalAmount': totalAmount,
      'items': items,
    };
  }

  factory ArchivedList.fromMap(Map<String, dynamic> map) {
    return ArchivedList(
      id: map['id'],
      date: map['date'],
      totalAmount: map['totalAmount'],
      items: List<Map<String, dynamic>>.from(map['items']),
    );
  }
}

class ArchivedItem {
  final int? id;
  final int listId;
  final String name;
  final double price;
  final double quantity;
  final String? unit;
  final String? description;
  final bool isCompleted;

  ArchivedItem({
    this.id,
    required this.listId,
    required this.name,
    required this.price,
    required this.quantity,
    this.unit,
    this.description,
    this.isCompleted = false,
  });

  factory ArchivedItem.fromShoppingItem(ShoppingItem item, int listId) {
    return ArchivedItem(
      listId: listId,
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      unit: item.unit,
      description: item.description,
      isCompleted: item.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory ArchivedItem.fromMap(Map<String, dynamic> map) {
    return ArchivedItem(
      id: map['id'],
      listId: map['list_id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      unit: map['unit'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
    );
  }
}
