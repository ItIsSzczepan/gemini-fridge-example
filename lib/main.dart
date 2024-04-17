import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Fridge Example App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ignore: prefer_final_fields
  List _products = [
    'apple',
    'milk',
    'eggs',
    'yogurt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Fridge Example App'),
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: _products.length + 1,
          itemBuilder: (context, index) {
            if (index == _products.length) {
              return TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  hintText: 'Add a product',
                ),
                onSubmitted: (value) {
                  setState(() {
                    _products.add(value);
                  });
                },
              );
            }
            return ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _products.removeAt(index);
                  });
                },
              ),
              title: Text(_products[index]),
            );
          },
          separatorBuilder: (_, __) => const Divider(),
        ),
      ),
    );
  }
}
