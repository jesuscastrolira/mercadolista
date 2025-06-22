import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mercadolista/models/shopping_list_model.dart';

class ListDetailPage extends StatelessWidget {
  final ShoppingList list;

  const ListDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    // Formateador para la fecha
    final DateFormat formatter = DateFormat('d \'de\' MMMM \'de\' y', 'es_ES');
    final String formattedDate = formatter.format(list.createdAt);
    final String currencySymbol = list.currency == 'Euros' ? '€' : '\$';

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de ${list.creatorName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cabecera con la información general ---
            Text(
              'Detalles de la Compra',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF2a2a2a),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.white70),
                title: Text(list.creatorName),
                subtitle: Text('Creada el $formattedDate'),
              ),
            ),
            const SizedBox(height: 24),

            // --- Lista de productos ---
            Text(
              'Productos',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.7)),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                itemCount: list.items.length,
                itemBuilder: (context, index) {
                  final item = list.items[index];
                  return ListTile(
                    leading: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    title: Text(item.name),
                    trailing: Text(
                        '$currencySymbol${(item.amount * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),

            // --- Total ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('$currencySymbol${list.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
