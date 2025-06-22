class ShoppingList {
  // El ID vuelve a ser un String
  final String id;
  final String creatorName;
  final String currency;
  final List<ShoppingItem> items;
  final double total;
  final DateTime createdAt;

  ShoppingList({
    required this.id,
    required this.creatorName,
    required this.currency,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  // Re-introducimos el constructor fromJson
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<ShoppingItem> items = itemsList.map((i) => ShoppingItem.fromJson(i)).toList();
    return ShoppingList(
      id: json['id'],
      creatorName: json['creatorName'],
      currency: json['currency'],
      items: items,
      total: json['total'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Re-introducimos el método toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorName': creatorName,
      'currency': currency,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ShoppingItem {
  final String name;
  final int quantity;
  final double amount;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      quantity: json['quantity'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'amount': amount,
    };
  }
}
