// PocketBase models for data handling
import 'package:pocketbase/pocketbase.dart';

// Type alias for PocketBase record to maintain compatibility
typedef PBRecord = RecordModel;

// Base model for PocketBase entities
abstract class PocketBaseModel {
  final String id;
  final DateTime created;
  final DateTime updated;

  PocketBaseModel({
    required this.id,
    required this.created,
    required this.updated,
  });

  Map<String, dynamic> toJson();

  static DateTime parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}