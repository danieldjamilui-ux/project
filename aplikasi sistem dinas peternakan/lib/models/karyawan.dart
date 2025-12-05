class Karyawan {
  final String id;
  final String nama;
  final String jabatan;
  final String email;
  final String avatar;
  bool aktif;

  Karyawan({
    required this.id,
    required this.nama,
    required this.jabatan,
    required this.email,
    required this.avatar,
    required this.aktif,
  });

  // Convert Firestore → Model
  factory Karyawan.fromMap(String id, Map<String, dynamic> data) {
    return Karyawan(
      id: id,
      nama: data['nama'] ?? '',
      jabatan: data['jabatan'] ?? '',
      email: data['email'] ?? '',
      avatar: data['avatar'] ?? '',
      aktif: data['aktif'] ?? true,
    );
  }

  // Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'jabatan': jabatan,
      'email': email,
      'avatar': avatar,
      'aktif': aktif,
    };
  }
}
