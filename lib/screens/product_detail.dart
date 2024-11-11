import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:handbag_store/models/item.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/products.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentPage = 0;
  static const int _itemsPerPage = 5;
  List<Product> _relatedProducts = [];
  PageController _pageController = PageController();

  Future<void> fetchRelatedProducts(String brand) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.jsonbin.io/v3/b/67314cf0ad19ca34f8c7b830'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _relatedProducts = (data['record'] as List)
              .map((json) => Product.fromJson(json))
              .where((item) =>
                  item.brand == widget.product.brand &&
                  item.name != widget.product.name)
              .toList();
        });
      } else {
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRelatedProducts(widget.product.brand);
  }

  List<Product> getCurrentPageProducts() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _relatedProducts.sublist(
        start, end < _relatedProducts.length ? end : _relatedProducts.length);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.product.images[0],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (widget.product.discountPercentage > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.product.discountPercentage}% OFF',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            // Product Name and Price
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)} ${widget.product.currency}',
              style: TextStyle(fontSize: 22, color: Colors.green),
            ),
            SizedBox(height: 10),
            // Rating
            Row(
              children: [
                buildStarRating(widget.product.ratingAverage),
                SizedBox(width: 8),
                Text(
                  '${widget.product.ratingAverage} / 5.0 (${widget.product.totalReviews} reviews)',
                  style: TextStyle(fontSize: 16, color: Colors.amber),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Product Details
            Text(
              'Availability: ${widget.product.availability}',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            SizedBox(height: 8),
            Text(
              'Category: ${widget.product.category}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Brand: ${widget.product.brand}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // Description
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.product.description),
            SizedBox(height: 16),
            // Color Options
            if (widget.product.colorOptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Colors:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: widget.product.colorOptions
                        .map((color) => Chip(label: Text(color)))
                        .toList(),
                  ),
                ],
              ),
            SizedBox(height: 16),
            // Size and Material
            Text(
              'Size (L x W x H): ${widget.product.size['length']} x ${widget.product.size['width']} x ${widget.product.size['height']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Material: ${widget.product.material}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // Features
            if (widget.product.features.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mô Tả:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...widget.product.features.map(
                    (feature) => Text('- $feature'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            // Add to Cart Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Tạo một đối tượng Item với sản phẩm và số lượng mặc định (1)
                  Item item = Item(product: widget.product, quantity: 1);

                  // Thêm item vào giỏ hàng
                  cart.addItem(item);

                  // Hiển thị thông báo SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} added to cart'),
                    ),
                  );
                },
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Thêm vào giỏ'),
              ),
            ),
            SizedBox(height: 20),
            // Related Products Section (Carousel)
            Text(
              'Sản Phẩm Liên Quan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _relatedProducts.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Navigation buttons for carousel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: _currentPage <
                                    (_relatedProducts.length / _itemsPerPage)
                                            .ceil() -
                                        1
                                ? () {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                      // Carousel (PageView)
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount:
                              (_relatedProducts.length / _itemsPerPage).ceil(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, pageIndex) {
                            int start = pageIndex * _itemsPerPage;
                            int end = start + _itemsPerPage;
                            List<Product> productsOnPage =
                                _relatedProducts.sublist(
                                    start,
                                    end < _relatedProducts.length
                                        ? end
                                        : _relatedProducts.length);

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productsOnPage.length,
                              itemBuilder: (context, index) {
                                var relatedProduct = productsOnPage[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                          product: relatedProduct),
                                    ),
                                  ),
                                  child: Container(
                                    width: 130,
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            relatedProduct.images[0],
                                            height: 100,
                                            width: 130,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          relatedProduct.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          '\$${relatedProduct.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.toInt();
    double halfStar = rating - fullStars;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber));
      } else if (halfStar > 0 && i == fullStars) {
        stars.add(Icon(Icons.star_half, color: Colors.amber));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber));
      }
    }
    return Row(children: stars);
  }
}
