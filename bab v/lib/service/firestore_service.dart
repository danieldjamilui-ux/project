import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kandang.dart';
import '../models/kontak_peternakan.dart';
import '../models/gudang.dart';
import '../models/karyawan.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ============================================================
  // KANDANG SERVICE
  // ============================================================

  CollectionReference get _kandangCollection =>
      _db.collection('kandang');

  Stream<List<Kandang>> getKandangStream() {
    return _kandangCollection
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                Kandang.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addKandang(Kandang kandang) async {
    await _kandangCollection.add({
      "nama": kandang.nama,
      "imagePath": kandang.imagePath,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // KONTAK PETERNAKAN SERVICE
  // ============================================================

  CollectionReference get _kontakCollection =>
      _db.collection('kontak_peternakan');

  Stream<List<KontakPeternakan>> getKontakStream() {
    return _kontakCollection.snapshots().map((snap) => snap.docs
        .map((doc) => KontakPeternakan.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addKontak(KontakPeternakan kontak) async {
    await _kontakCollection.add(kontak.toMap());
  }

  Future<void> updateKontak(KontakPeternakan kontak) async {
    await _kontakCollection.doc(kontak.id).update(kontak.toMap());
  }

  Future<void> deleteKontak(String id) async {
    await _kontakCollection.doc(id).delete();
  }

  // ============================================================
  // GUDANG SERVICE
  // ============================================================

  CollectionReference get _gudangCollection =>
      _db.collection('gudang');

  Stream<List<Gudang>> getGudangStream() {
    return _gudangCollection
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                Gudang.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addGudang(Gudang gudang) async {
    await _gudangCollection.add({
      "nama": gudang.nama,
      "pengurus": gudang.pengurus,
      "lokasi": gudang.lokasi,
      "ukuran": gudang.ukuran,
      "imagePath": gudang.imagePath,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGudang(Gudang gudang) async {
    await _gudangCollection.doc(gudang.id).update(gudang.toMap());
  }

  Future<void> deleteGudang(String id) async {
    await _gudangCollection.doc(id).delete();
  }

  // ============================================================
  // KARYAWAN SERVICE (DITAMBAHKAN)
  // ============================================================

  CollectionReference get _karyawanCollection =>
      _db.collection('karyawan');

  /// Stream Realtime
  Stream<List<Karyawan>> getKaryawanStream() {
    return _karyawanCollection.snapshots().map(
      (snap) => snap.docs
          .map((doc) =>
              Karyawan.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Tambah karyawan
  Future<void> addKaryawan(Karyawan k) async {
    await _karyawanCollection.add({
      "nama": k.nama,
      "jabatan": k.jabatan,
      "email": k.email,
      "avatar": k.avatar,
      "aktif": k.aktif,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Update status aktif / nonaktif
  Future<void> updateKaryawanStatus(String id, bool status) async {
    await _karyawanCollection.doc(id).update({"aktif": status});
  }

  /// Delete karyawan
  Future<void> deleteKaryawan(String id) async {
    await _karyawanCollection.doc(id).delete();
  }
}
