import 'package:cloud_firestore/cloud_firestore.dart';
class Gudang {
  final String id;
  final String nama;
  final String pengurus;
  final String lokasi;
  final String ukuran;
  final String imagePath;
  final DateTime? createdAt;

  Gudang({
    required this.id,
    required this.nama,
    required this.pengurus,
    required this.lokasi,
    required this.ukuran,
    required this.imagePath,
    this.createdAt,
  });

  factory Gudang.fromMap(String id, Map<String, dynamic> map) {
    return Gudang(
      id: id,
      nama: map['nama'] ?? '',
      pengurus: map['pengurus'] ?? '',
      lokasi: map['lokasi'] ?? '',
      ukuran: map['ukuran'] ?? '',
      imagePath: map['imagePath'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nama": nama,
      "pengurus": pengurus,
      "lokasi": lokasi,
      "ukuran": ukuran,
      "imagePath": imagePath,
      "createdAt": createdAt,
    };
  }
}
