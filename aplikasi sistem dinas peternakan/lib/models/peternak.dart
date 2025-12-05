class Peternak {
  final String id;
  final String nama;
  final String lokasi;
  int jumlahTernak;

  Peternak(this.id, this.nama, this.lokasi, this.jumlahTernak);

  // 🔹 Buat dari dokumen Firestore
  factory Peternak.fromFirestore(Map<String, dynamic> data, String id) {
    return Peternak(
      id,
      data['nama'] ?? '',
      data['lokasi'] ?? '',
      (data['jumlahTernak'] ?? 0) as int,
    );
  }

  // 🔹 Simpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      'jumlahTernak': jumlahTernak,
    };
  }

  String tampil() => '$nama ($lokasi) - $jumlahTernak ternak';
}
