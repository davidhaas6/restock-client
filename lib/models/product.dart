// Data model for a product to watch

enum ProductType { GPU, CPU, Console }

class Product {
  final String name, id;
  final ProductType type;
  Product(this.name, this.id, this.type);

  factory Product.fromJson(Map<String, dynamic> data, String firebaseID) {
    // Maps string product type from firebase to the enum
    Map typeConversion = <String, ProductType>{
      'cpu': ProductType.CPU,
      'gpu': ProductType.GPU,
      'console': ProductType.Console
    };

    ProductType productType = typeConversion[data['type']];

    return Product(data['name'], firebaseID, productType);
  }

  static getIcon(ProductType productType) {
    Map iconMap = <ProductType, String>{
      ProductType.CPU: 'assets/images/cpu.png',
      ProductType.GPU: 'assets/images/gpu.png',
      ProductType.Console: 'assets/images/console.png',
    };

    return iconMap[productType];
  }
}
