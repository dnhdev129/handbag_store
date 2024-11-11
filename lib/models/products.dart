class Product {
  final String productId;
  final String name;
  final String category;
  final String brand;
  final String description;
  final double price;
  final String currency;
  final String availability;
  final List<String> colorOptions;
  final Map<String, String> size;
  final String material;
  final List<String> features;
  final List<String> images;
  final double ratingAverage;
  final int totalReviews;
  final Map<String, dynamic> shipping;
  final int discountPercentage;
  final String discountValidUntil;

  Product({
    required this.productId,
    required this.name,
    required this.category,
    required this.brand,
    required this.description,
    required this.price,
    required this.currency,
    required this.availability,
    required this.colorOptions,
    required this.size,
    required this.material,
    required this.features,
    required this.images,
    required this.ratingAverage,
    required this.totalReviews,
    required this.shipping,
    required this.discountPercentage,
    required this.discountValidUntil,
  });

  // Hàm factory để tạo đối tượng Product từ JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
      brand: json['brand'] ?? 'No brand',
      description: json['description'] ?? 'No description available',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      availability: json['availability'] ?? 'Unavailable',
      colorOptions: List<String>.from(json['color_options'] ?? []),
      size: {
        'length': json['size']?['length'] ?? 'N/A',
        'width': json['size']?['width'] ?? 'N/A',
        'height': json['size']?['height'] ?? 'N/A',
      },
      material: json['material'] ?? 'Unknown',
      features: List<String>.from(json['features'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      ratingAverage: (json['ratings']?['average'] ?? 0).toDouble(),
      totalReviews: json['ratings']?['total_reviews'] ?? 0,
      shipping: json['shipping'] ?? {},
      discountPercentage: json['discount']?['percentage'] ?? 0,
      discountValidUntil: json['discount']?['valid_until'] ?? '',
    );
  }
}
