import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mercadolista/models/shopping_list_model.dart';
// ¡Importante! Importamos el paquete que sí funciona en la web
import 'package:shared_preferences/shared_preferences.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});
  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final _nameController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCurrency = 'Euros';
  final List<ShoppingItem> _items = [];
  double _totalAmount = 0.0;

  void _addItem() {
    final String productName = _productController.text;
    final int? quantity = int.tryParse(_quantityController.text);
    final String amountText = _amountController.text.replaceAll(',', '.');
    final double? amount = double.tryParse(amountText);
    if (productName.isNotEmpty && quantity != null && amount != null) {
      final newItem = ShoppingItem(
        name: productName,
        quantity: quantity,
        amount: amount,
      );
      setState(() {
        _items.add(newItem);
        _calculateTotal();
      });
      _productController.clear();
      _quantityController.clear();
      _amountController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in _items) {
      total += item.amount * item.quantity;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  // --- FUNCIÓN DE GUARDADO RECONSTRUIDA PARA SHARED PREFERENCES ---
  Future<void> _saveList() async {
    if (_nameController.text.isEmpty || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, introduce tu nombre y añade al menos un producto.',
          ),
        ),
      );
      return;
    }

    final newList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorName: _nameController.text,
      currency: _selectedCurrency,
      items: _items,
      total: _totalAmount,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final List<String> savedLists = prefs.getStringList('shopping_lists') ?? [];
    savedLists.add(jsonEncode(newList.toJson()));
    await prefs.setStringList('shopping_lists', savedLists);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('¡Lista guardada con éxito!'),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String currencySymbol = _selectedCurrency == 'Euros' ? '€' : '\$';
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nueva Lista')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                  prefixIcon: Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.white70,
                  ),
                ),
                items: <String>['Euros', 'Dólares']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null)
                    setState(() => _selectedCurrency = newValue);
                },
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  prefixIcon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: Colors.white70,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Monto Unitario',
                        prefixIcon: Text(
                          " $currencySymbol",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Añadir Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4a4a4a),
                  foregroundColor: Colors.white,
                ),
                onPressed: _addItem,
              ),
              const SizedBox(height: 24),
              Text(
                'Total: $currencySymbol${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF3a3a3a),
                      child: Text(item.quantity.toString()),
                    ),
                    title: Text(item.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currencySymbol${(item.amount * item.quantity).toStringAsFixed(2)}',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveList,
                child: const Text('Guardar Lista Completa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
