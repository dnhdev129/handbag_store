import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> products;
  late Map<String, List<Product>> groupedProducts;

  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('https://api.jsonbin.io/v3/b/67314cf0ad19ca34f8c7b830'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Product> productList = (data['record'] as List)
          .map((json) => Product.fromJson(json))
          .toList();

      // Nhóm các sản phẩm theo thương hiệu (brand)
      groupedProducts = {};
      for (var product in productList) {
        if (!groupedProducts.containsKey(product.brand)) {
          groupedProducts[product.brand] = [];
        }
        groupedProducts[product.brand]!.add(product);
      }

      return productList; // Trả về danh sách sản phẩm để FutureBuilder sử dụng
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
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: groupedProducts.keys.length,
              itemBuilder: (context, index) {
                // Lấy tên thương hiệu (brand)
                String brand = groupedProducts.keys.elementAt(index);

                return ExpansionTile(
                  title: Text(
                    brand,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  children: groupedProducts[brand]!.map((product) {
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          '\$${product.price.toStringAsFixed(2)} ${product.currency}'),
                      leading: Image.network(product.images[0]),
                      onTap: () {
                        // Thực hiện hành động khi nhấn vào sản phẩm
                      },
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
