import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jadwal_pakan.dart';

class JadwalPakanService {
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('jadwal_pakan');

  Future<void> tambah(JadwalPakan item) async {
    await _ref.add(item.toMap());
  }

  Future<void> hapus(String id) async {
    await _ref.doc(id).delete();
  }

  Stream<List<JadwalPakan>> streamData() {
    return _ref.orderBy('createdAt', descending: false).snapshots().map(
      (snap) => snap.docs
          .map((d) =>
              JadwalPakan.fromDoc(d.id, d.data() as Map<String, dynamic>))
          .toList(),
    );
  }
}
