class Product {
  final String name;
  final int id;
  final int price;
  final String sellUser;
  final String region;
  final String content;
  final String imagePath;

  Product(
      {required this.name,
      required this.id,
      required this.price,
      required this.sellUser,
      required this.region,
      required this.content,
      required this.imagePath});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      id: json['id'],
      price: json['price'],
      sellUser: json['sellUser'],
      region: json['region'],
      content: json['content'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'price': price,
      'sellUser': sellUser,
      'region': region,
      'content': content,
      'imagePath': imagePath,
    };
  }
}
