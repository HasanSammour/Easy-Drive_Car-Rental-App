// models/car_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String id;
  final String model;
  final String type;
  final String brand;
  final double pricePerDay;
  final String description;
  final List<String> features;
  final List<String> imageUrls;
  final bool isAvailable;
  final String status; // Available, Booked, Maintenance
  final double? averageRating;
  final int totalReviews;

  CarModel({
    required this.id,
    required this.model,
    required this.type,
    required this.brand,
    required this.pricePerDay,
    required this.description,
    required this.features,
    required this.imageUrls,
    required this.isAvailable,
    required this.status,
    this.averageRating,
    this.totalReviews = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'type': type,
      'brand': brand,
      'pricePerDay': pricePerDay,
      'description': description,
      'features': features,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'status': status,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return CarModel(
      id: id,
      model: map['model'] ?? '', // Handle null values
      type: map['type'] ?? '',
      brand: map['brand'] ?? '',
      pricePerDay: (map['pricePerDay'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      status: map['status'] ?? 'Available',
      averageRating: map['averageRating']?.toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
    );
  }

  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    return CarModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }
}