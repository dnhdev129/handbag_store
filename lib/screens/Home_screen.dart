import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_detail.dart';
import '../models/products.dart';
import 'cart_screen.dart'; // Import the CartScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> products;

  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('https://api.jsonbin.io/v3/b/67314cf0ad19ca34f8c7b830'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['record'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              itemCount: snapshot.data?.length ?? 0,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1, // Ensures a square shape
                            child: Image.network(
                              product.images[0],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : Center(
                                        child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: Text(
                              product.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
