// =====================================================
// SISTEM INFORMASI PETERNAKAN MALUKU UTARA - VERSI RINGKAS
// =====================================================

enum JenisTernak { Sapi, Kambing, Ayam }
enum StatusKesehatan { Sehat, Sakit, Pemulihan }
enum KategoriPeternak { Pemula, Menengah, Profesional }
enum FaseProgram { Perencanaan, Pelaksanaan, Monitoring, Evaluasi }
enum JenisPakan { Konsentrat, Hijauan }

class Ternak {
  String id, nama; JenisTernak jenis; int umur; double berat; StatusKesehatan status;
  Ternak(this.id, this.nama, this.jenis, {required this.umur, required this.berat, this.status = StatusKesehatan.Sehat});
  void tampil() => print('[$id] $nama (${jenis.name}) - $berat kg, ${status.name}');
  double harga() => berat * (jenis == JenisTernak.Sapi ? 50000 : jenis == JenisTernak.Kambing ? 60000 : 40000);
}

class Peternak {
  String id, nama; int pengalaman; KategoriPeternak kategori;
  Peternak(this.id, this.nama, this.pengalaman)
      : kategori = (pengalaman < 2 ? KategoriPeternak.Pemula : pengalaman < 5 ? KategoriPeternak.Menengah : KategoriPeternak.Profesional);
  void tampil() => print('$nama (${kategori.name}) - $pengalaman thn');
}

class PetugasDinas {
  String id, nama, jabatan; int umur;
  PetugasDinas(this.id, this.nama, this.jabatan, this.umur);
  void tampil() => print('$nama ($jabatan)');
}

class DokterHewan extends PetugasDinas {
  String spesialis; DokterHewan(String id, String n, int u, this.spesialis) : super(id, n, 'Dokter Hewan', u);
  void periksa(Ternak t) => print('Dr.$nama memeriksa ${t.nama}: ${t.status.name}');
}

abstract class FasilitasPeternakan {
  String id, nama; double kapasitas;
  FasilitasPeternakan(this.id, this.nama, this.kapasitas);
  void tampil(); double biaya();
}

class Kandang extends FasilitasPeternakan {
  JenisTernak jenis; int isi = 0;
  Kandang(String id, String n, double k, this.jenis) : super(id, n, k);
  void tampil() => print('$nama ($jenis) isi:$isi/${kapasitas.toInt()}');
  double biaya() => 50000 + isi * 10000;
}

mixin Kinerja {
  int produktivitas = 80;
  String evaluasi() => produktivitas >= 85 ? 'Sangat Baik' : produktivitas >= 70 ? 'Baik' : 'Cukup';
}

class Koordinator extends PetugasDinas with Kinerja {
  Koordinator(String id, String n, int u) : super(id, n, 'Koordinator', u);
  void tampil() => print('$nama - Produktivitas: $produktivitas (${evaluasi()})');
}

class ProgramPeternakan {
  String id, nama; FaseProgram fase = FaseProgram.Perencanaan;
  ProgramPeternakan(this.id, this.nama);
  void lanjut() {
    if (fase == FaseProgram.Perencanaan) fase = FaseProgram.Pelaksanaan;
    else if (fase == FaseProgram.Pelaksanaan) fase = FaseProgram.Monitoring;
    else if (fase == FaseProgram.Monitoring) fase = FaseProgram.Evaluasi;
    print('Fase program: ${fase.name}');
  }
}

class Sistem {
  List<Ternak> ternak = []; List<PetugasDinas> petugas = [];
  void statistik() => print('Total ternak: ${ternak.length}, petugas: ${petugas.length}');
}

void main() {
  print('=== SISTEM PETERNAKAN MALUKU UTARA (Ringkas) ===');
  var sapi = Ternak('T1', 'Sapi Limosin', JenisTernak.Sapi, umur: 24, berat: 450);
  var peternak = Peternak('P1', 'Pak Joko', 4);
  var dokter = DokterHewan('D1', 'Dr. Maya', 35, 'Sapi');
  var kandang = Kandang('K1', 'Kandang Sapi', 10, JenisTernak.Sapi);
  var koordinator = Koordinator('K2', 'Pak Hasan', 40);
  var program = ProgramPeternakan('PR1', 'Sapi Sehat');
  var sistem = Sistem();

  sapi.tampil();
  print('Estimasi harga: Rp${sapi.harga()}');
  peternak.tampil();
  dokter.periksa(sapi);
  kandang.isi = 5; kandang.tampil();
  print('Biaya: Rp${kandang.biaya()}');
  koordinator.tampil();
  program.lanjut();
  sistem.ternak.add(sapi); sistem.petugas.add(dokter);
  sistem.statistik();
}
