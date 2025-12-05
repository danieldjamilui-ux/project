class Pemeriksaan {
  final String id;
  final String namaPemilik;
  final String jenisTernak;
  final int jumlah;
  final String status;
  final String tanggal;

  Pemeriksaan({
    required this.id,
    required this.namaPemilik,
    required this.jenisTernak,
    required this.jumlah,
    required this.status,
    required this.tanggal,
  });

  factory Pemeriksaan.fromMap(Map<String, dynamic> map, String docId) {
    return Pemeriksaan(
      id: docId,
      namaPemilik: map['namaPemilik'] ?? '',
      jenisTernak: map['jenisTernak'] ?? '',
      jumlah: map['jumlah'] ?? 0,
      status: map['status'] ?? 'Sehat',
      tanggal: map['tanggal'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaPemilik': namaPemilik,
      'jenisTernak': jenisTernak,
      'jumlah': jumlah,
      'status': status,
      'tanggal': tanggal,
    };
  }
}
