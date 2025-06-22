import 'package:flutter/material.dart';
import 'package:mercadolista/create_list_page.dart';
import 'package:mercadolista/history_page.dart';

// La función main vuelve a ser simple y directa.
void main() {
  runApp(const MyApp());
}

// El resto de la aplicación (MyApp, HomePage) no necesita cambios.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Listas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2a2a2a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Mercado APP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Hacer una lista'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateListPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Consultar Historial'),
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
