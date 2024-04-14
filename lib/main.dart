import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

/// Replace this with your API key.
/// You can get it from https://aistudio.google.com/
/// or from https://cloud.google.com/vertex-ai/docs/authentication if you are from Europe
const String apiKey = 'YOUR_API_KEY';

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
  late final GenerativeModel _model = GenerativeModel(
    /// If you are from Europe, you need to use VertexHttpClient and specify the project URL https://<REGION>-aiplatform.googleapis.com/v1/projects/<PROJECT_ID>/locations/<REGION>/publishers/google/models
    model: 'gemini-pro-vision',
    apiKey: apiKey,
    // uncomment this line if you are from Europe
    // httpClient: VertexHttpClient(
    //    'https://<region>-aiplatform.googleapis.com/v1/projects/<your-project-id>/locations/<region>/publishers/google/models'),
  );
  late final ImagePicker _picker = ImagePicker();

  // ignore: prefer_final_fields
  List _products = [
    'apple',
    'milk',
    'eggs',
    'yogurt',
  ];
  List _dishes = [];
  bool _isFetchingDishes = false;
  bool _isAddingProducts = false;

  @override
  void initState() {
    super.initState();
    _fetchDishes();
  }

  void _fetchDishes() async {
    setState(() {
      _isFetchingDishes = true;
    });
    final prompt =
        'Do no add, additional context. Write list of dishes that i can make using only those products: ${_products.join(', ')}. Answear in format like this [dish 1; dish2; dish3; dish4]';
    final List<Content> content = [Content.text(prompt)];
    final String? response = (await _model.generateContent(content)).text;
    if (response == null) return;
    setState(() {
      _dishes = response.replaceAll(RegExp(r'[\[\]]'), '').split(';');
      _isFetchingDishes = false;
    });
  }

  void _addProductsFromPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _isAddingProducts = true;
    });
    const String prompt =
        'Do no add any additional text or context. Detect grocery products in the image and return a list of them in format like this [product 1; product 2; product 3; product 4]';
    final List<Content> content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', await image.readAsBytes())])
    ];
    final String? response = (await _model.generateContent(content)).text;
    final products = response?.replaceAll(RegExp(r'[\[\]]'), '').split(';') ?? [];
    setState(() {
      _products.addAll(products);
      _isAddingProducts = false;
    });
    _fetchDishes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Fridge Example App'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProductsFromPhoto,
        child: const Icon(Icons.image),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
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
                            _fetchDishes();
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
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Dishes you can make:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(
                        height: 125,
                        width: double.infinity,
                        child: _isFetchingDishes
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 150,
                                    height: 125,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(_dishes[index]),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemCount: _dishes.length,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isAddingProducts)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
