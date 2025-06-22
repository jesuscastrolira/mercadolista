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

  int? _editingIndex; // Nuevo: Almacena el índice del producto que se está editando

  // Función para añadir o actualizar un producto en la lista
  void _addItem() {
    final String productName = _productController.text.trim();
    final int? quantity = int.tryParse(_quantityController.text.trim());
    // Aseguramos que el separador decimal sea un punto antes de parsear
    final String amountText = _amountController.text.trim().replaceAll(',', '.');
    final double? amount = double.tryParse(amountText);

    if (productName.isEmpty || quantity == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos (Producto, Cantidad, Monto).'),
        ),
      );
      return;
    }

    final newItem = ShoppingItem(
      name: productName,
      quantity: quantity,
      amount: amount,
    );

    setState(() {
      if (_editingIndex != null) {
        // Si _editingIndex tiene un valor, significa que estamos actualizando un producto existente
        _items[_editingIndex!] = newItem;
        _editingIndex = null; // Reseteamos el índice de edición
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente.')),
        );
      } else {
        // Si _editingIndex es nulo, estamos añadiendo un nuevo producto
        _items.add(newItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto añadido a la lista.')),
        );
      }
      _calculateTotal(); // Recalculamos el total
      _clearProductFields(); // Limpiamos los campos de entrada
    });
    FocusScope.of(context).unfocus(); // Cierra el teclado
  }

  // Función para eliminar un producto de la lista
  void _removeItem(int index) {
    setState(() {
      final removedProductName = _items[index].name;
      _items.removeAt(index);
      _calculateTotal(); // Recalculamos el total
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$removedProductName" eliminado de la lista.')),
      );
    });
  }

  // Nuevo: Función para cargar los datos de un producto para edición
  void _editItem(int index) {
    setState(() {
      _editingIndex = index; // Establecemos el índice del producto a editar
      final productToEdit = _items[index];
      _productController.text = productToEdit.name;
      _quantityController.text = productToEdit.quantity.toString();
      // Mostramos el monto con 2 decimales y usamos coma como separador para edición
      _amountController.text = productToEdit.amount.toStringAsFixed(2).replaceAll('.', ',');
    });
  }

  // Limpia los campos de entrada de producto
  void _clearProductFields() {
    _productController.clear();
    _quantityController.clear();
    _amountController.clear();
  }

  // Recalcula el total de la lista
  void _calculateTotal() {
    double total = 0.0;
    for (var item in _items) {
      total += item.amount * item.quantity;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  // Función para guardar la lista completa usando SharedPreferences
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
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único basado en timestamp
      creatorName: _nameController.text,
      currency: _selectedCurrency,
      items: _items,
      total: _totalAmount,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final List<String> savedLists = prefs.getStringList('shopping_lists') ?? [];
    savedLists.add(jsonEncode(newList.toJson())); // Convertimos la lista a JSON string y la añadimos
    await prefs.setStringList('shopping_lists', savedLists); // Guardamos la lista actualizada

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('¡Lista guardada con éxito!'),
      ),
    );
    // Vuelve a la pantalla anterior después de guardar
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Define el símbolo de la moneda basado en la selección del usuario
    String currencySymbol = _selectedCurrency == 'Euros' ? '€' : '\$';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Lista'),
        backgroundColor: Colors.black, // Estilo minimalista
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white), // Color del texto de entrada
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  labelStyle: TextStyle(color: Colors.white70), // Color del label
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30), // Borde normal
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Borde al enfocar
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                style: const TextStyle(color: Colors.white), // Color del texto del valor seleccionado
                dropdownColor: Colors.black87, // Fondo del menú desplegable
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.white70,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                items: <String>['Euros', 'Dólares']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)), // Color de los items en el menú
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCurrency = newValue);
                    _calculateTotal(); // Recalcular total si cambia la moneda (aunque no afecte el valor, es buena práctica)
                  }
                },
                iconEnabledColor: Colors.white70, // Color del icono de la flecha
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white70,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: Colors.white70,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Monto Unitario',
                        labelStyle: const TextStyle(color: Colors.white70),
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
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
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
                icon: Icon(_editingIndex != null ? Icons.save : Icons.add), // Icono cambia según el modo
                label: Text(_editingIndex != null ? 'Actualizar Producto' : 'Añadir Producto'), // Texto cambia según el modo
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
              // Lista de productos añadidos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    color: const Color(0xFF303030), // Color de la tarjeta para que contraste
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF5a5a5a), // Color del avatar
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Monto unitario: $currencySymbol${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currencySymbol${(item.amount * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          // Nuevo: Botón de edición
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editItem(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Botón para guardar la lista completa
              ElevatedButton(
                onPressed: _saveList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fondo blanco
                  foregroundColor: Colors.black, // Texto negro
                  padding: const EdgeInsets.symmetric(vertical: 20), // Aumenta la altura
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes un poco redondeados si no lo estaban
                  ),
                ),
                child: const Text(
                  'Guardar Lista Completa',
                  style: TextStyle(
                    fontSize: 18, // Puedes ajustar el tamaño de la fuente si lo deseas
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
