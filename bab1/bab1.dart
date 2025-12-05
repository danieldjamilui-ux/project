// ================================================
// SISTEM INFORMASI PETERNAKAN - VERSI SINGKAT
// Dinas Pertanian Maluku Utara
// ================================================
import 'dart:async';

class Peternak {
  String nama, alamat;
  int ternak, lama;
  Peternak(this.nama, this.alamat, this.ternak, this.lama);

  void info() => print("""
Nama: $nama
Alamat: $alamat
Jumlah ternak: $ternak ekor
Lama beternak: $lama tahun
Status: ${lama < 2 ? "Pemula" : lama < 5 ? "Menengah" : "Berpengalaman"}
""");
}

Future<void> ambilData() async {
  print("\n⏳ Mengambil data peternak...");
  await Future.delayed(Duration(seconds: 1));
  print("✓ Data berhasil diambil: [Ahmad, Siti, Budi]");
}

void main() async {
  print("=== SISTEM INFORMASI PETERNAKAN ===");

  var p = Peternak("Ahmad Hidayat", "Ternate", 25, 5);
  p.info();

  List<String> jenis = ["Sapi", "Kambing", "Ayam"];
  print("\nDaftar ternak: ${jenis.join(', ')}");

  print("\nTotal ternak wilayah: ${[25, 30, 45].reduce((a, b) => a + b)} ekor");

  await ambilData();

  print("\n=== NULL SAFETY ===");
  String? alamat;
  print("Alamat: ${alamat ?? 'Belum diatur'}");
  alamat = "Jl. Peternakan Ternate";
  print("Alamat baru: $alamat (${alamat.length} karakter)");

  print("\n=== PROGRAM SELESAI ===");
}
