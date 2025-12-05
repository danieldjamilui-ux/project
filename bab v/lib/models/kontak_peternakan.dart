class KontakPeternakan {
  String id; // ID dokumen Firestore
  String nama;
  String alamat;
  String noHp;

  KontakPeternakan({
    this.id = '',
    required this.nama,
    required this.alamat,
    required this.noHp,
  });

  // Convert object ke Map untuk Firestore
  Map<String, dynamic> toMap() => {
        'nama': nama,
        'alamat': alamat,
        'noHp': noHp,
      };

  // Convert snapshot Firestore ke object
  factory KontakPeternakan.fromMap(Map<String, dynamic> map, String docId) {
    return KontakPeternakan(
      id: docId,
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      noHp: map['noHp'] ?? '',
    );
  }
}
