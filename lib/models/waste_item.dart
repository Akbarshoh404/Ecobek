class WasteItem {
  final String id;
  final String img;
  final String name;
  final String price;
  final String unit;
  final String type;

  WasteItem({
    required this.id,
    required this.img,
    required this.name,
    required this.price,
    required this.unit,
    required this.type,
  });

  factory WasteItem.fromMap(Map<dynamic, dynamic> data, String id) {
    return WasteItem(
      id: id,
      img: data['img'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      price: data['price']?.toString() ?? '0',
      unit: data['unit'] as String? ?? 'Kg',
      type: data['type'] as String? ?? 'other',
    );
  }
}