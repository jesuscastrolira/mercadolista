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
    await initializeDateFormatting('es_ES', null);
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedListsJson = prefs.getStringList('shopping_lists') ?? [];
    
    final lists = savedListsJson.map((jsonString) {
      final jsonMap = jsonDecode(jsonString);
      return ShoppingList.fromJson(jsonMap);
    }).toList();
    
    lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (mounted) {
      setState(() {
        _shoppingLists = lists;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteList(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _shoppingLists.removeWhere((list) => list.id == id);
    
    List<String> updatedListsJson = _shoppingLists.map((list) => jsonEncode(list.toJson())).toList();
    await prefs.setStringList('shopping_lists', updatedListsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text('La lista ha sido eliminada.')),
    );
    
    setState(() {});
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta lista?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)), onPressed: () => Navigator.of(context).pop(true)),
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
                    
                    return Dismissible(
                      key: Key(list.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _showDeleteConfirmationDialog(),
                      onDismissed: (direction) {
                        _deleteList(list.id);
                      },
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_forever, color: Colors.white),
                      ),
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
