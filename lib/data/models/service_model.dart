/// Service model representing a service offered by the salon
class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final String? description;
  final double price;
  final int duration; // in minutes
  final String? category;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    this.category,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      salonId: json['salonId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: _parsePrice(json['price']),
      duration: json['duration'] as int,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? salonId,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? category,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
