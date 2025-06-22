import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mercadolista/list_detail_page.dart';
import 'package:mercadolista/models/shopping_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ShoppingList> _shoppingLists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  Future<void> _refreshLists() async {
    // Esta inicialización es necesaria para formatear fechas.
    await initializeDateFormatting('es_ES', null);
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedListsJson = prefs.getStringList('shopping_lists') ?? [];
    
    final lists = savedListsJson.map((jsonString) {
      final jsonMap = jsonDecode(jsonString);
      return ShoppingList.fromJson(jsonMap);
    }).toList();
    
    // Ordenamos las listas, mostrando las más nuevas primero.
    lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (mounted) {
      setState(() {
        _shoppingLists = lists;
        _isLoading = false;
      });
    }
  }

  // --- NUEVA FUNCIÓN PARA ELIMINAR UNA LISTA ---
  Future<void> _deleteList(String idToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Eliminamos la lista de nuestra variable de estado.
    _shoppingLists.removeWhere((list) => list.id == idToDelete);
    
    // Convertimos la lista de objetos actualizada de nuevo a una lista de Strings en formato JSON.
    List<String> updatedListsJson = _shoppingLists.map((list) => jsonEncode(list.toJson())).toList();
    
    // Guardamos la lista de vuelta en SharedPreferences.
    await prefs.setStringList('shopping_lists', updatedListsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text('La lista ha sido eliminada.')),
    );
    
    // Actualizamos la interfaz de usuario.
    setState(() {});
  }

  // --- NUEVO WIDGET: DIÁLOGO DE CONFIRMACIÓN DE BORRADO ---
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta lista de forma permanente?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(false), // Devuelve false si se cancela.
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true), // Devuelve true si se confirma.
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Listas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _shoppingLists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, size: 80, color: Colors.white24),
                      SizedBox(height: 20),
                      Text('Aún no hay listas guardadas.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _shoppingLists.length,
                  itemBuilder: (context, index) {
                    final list = _shoppingLists[index];
                    final currencySymbol = list.currency == 'Euros' ? '€' : '\$';
                    final DateFormat formatter = DateFormat('d \'de\' MMMM, y', 'es_ES');
                    
                    // --- WIDGET DISMISSIBLE AÑADIDO ---
                    // Este widget envuelve nuestra tarjeta y le da la capacidad de ser deslizada.
                    return Dismissible(
                      // La 'key' es fundamental para que Flutter sepa qué elemento único eliminar de la lista.
                      key: Key(list.id),
                      direction: DismissDirection.endToStart, // Solo permite deslizar de derecha a izquierda.
                      
                      // Muestra el diálogo de confirmación antes de hacer nada.
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmationDialog();
                      },

                      // Esto se ejecuta solo si el usuario confirma en el diálogo.
                      onDismissed: (direction) {
                        _deleteList(list.id);
                      },
                      
                      // Este es el fondo rojo que aparece mientras se desliza.
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_forever, color: Colors.white),
                      ),
                      
                      // Este es el contenido que siempre es visible: nuestra tarjeta.
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: const Color(0xFF2a2a2a),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: const Color(0xFF3a3a3a), child: Icon(Icons.list_alt, color: Colors.white70)),
                          title: Text('Lista de ${list.creatorName}'),
                          subtitle: Text(formatter.format(list.createdAt)),
                          trailing: Text('$currencySymbol${list.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ListDetailPage(list: list)),
                            ).then((_) => _refreshLists());
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
