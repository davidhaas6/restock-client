// Data model for a product to watch

enum ProductType { GPU, CPU, Console }

Map iconMap = <ProductType, String>{
  ProductType.CPU: 'assets/images/cpu.png',
  ProductType.GPU: 'assets/images/gpu.png',
  ProductType.Console: 'assets/images/console.png',
};

class Product {
  final String name, channel;
  final ProductType type;
  Product(this.name, this.channel, this.type);

  factory Product.fromJson(Map<String, dynamic> data, String firebaseID) {
    // Maps string product type from firebase to the enum
    ProductType productType = {
      'cpu': ProductType.CPU,
      'gpu': ProductType.GPU,
      'console': ProductType.Console
    }[data['type']];

    return Product(data['name'], firebaseID, productType);
  }
}
