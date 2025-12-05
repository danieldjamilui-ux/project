class JadwalPakan {
  final String id;
  final String jam;
  final String kandang;
  final String pegawai;
  final String pakan;
  final String obat;

  JadwalPakan({
    required this.id,
    required this.jam,
    required this.kandang,
    required this.pegawai,
    required this.pakan,
    required this.obat,
  });

  Map<String, dynamic> toMap() {
    return {
      "jam": jam,
      "kandang": kandang,
      "pegawai": pegawai,
      "pakan": pakan,
      "obat": obat,
      "createdAt": DateTime.now(),
    };
  }

  factory JadwalPakan.fromDoc(String id, Map<String, dynamic> map) {
    return JadwalPakan(
      id: id,
      jam: map["jam"] ?? "",
      kandang: map["kandang"] ?? "",
      pegawai: map["pegawai"] ?? "",
      pakan: map["pakan"] ?? "",
      obat: map["obat"] ?? "",
    );
  }
}
