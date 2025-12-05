import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Kandang {
  final String id;
  final String nama;
  final String imagePath;
  final Timestamp? createdAt; // optional, karena bisa null

  Kandang({
    required this.id,
    required this.nama,
    required this.imagePath,
    this.createdAt,
  });

  // Method untuk menampilkan tanggal dengan format
  String get formattedDate {
    if (createdAt != null) {
      return "Dibuat: ${DateFormat('dd MMMM yyyy').format(createdAt!.toDate())}";
    } else {
      return "Dibuat: -";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  factory Kandang.fromMap(String id, Map<String, dynamic> map) {
    return Kandang(
      id: id,
      nama: map['nama'] ?? '',
      imagePath: map['imagePath'] ?? '',
      createdAt: map['createdAt'], // asumsikan Timestamp dari Firestore
    );
  }
}
