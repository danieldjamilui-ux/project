import 'package:cloud_firestore/cloud_firestore.dart';

class PemeriksaanSampelService {
  final CollectionReference<Map<String, dynamic>> collection =
      FirebaseFirestore.instance.collection("pemeriksaan_sampel");

  // Ambil semua data realtime, urut dari terbaru
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllSampel() {
    return collection.orderBy("createdAt", descending: true).snapshots();
  }

  // Tambah data baru
  Future<void> addSampel({
    required String animalId,
    required String animalName,
    required String species,
    required String testDate,
    required String testType,
    required String outcome,
    required String status,
  }) async {
    await collection.add({
      "animalId": animalId,
      "animalName": animalName,
      "species": species,
      "testDate": testDate,
      "testType": testType,
      "outcome": outcome,
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // Update status dokumen
  Future<void> updateStatus(String docId, String newStatus) async {
    final docRef = collection.doc(docId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.update({
        "status": newStatus,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // Update outcome dokumen
  Future<void> updateOutcome(String docId, String newOutcome) async {
    final docRef = collection.doc(docId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.update({
        "outcome": newOutcome,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // Hapus dokumen
  Future<void> deleteSampel(String docId) async {
    final docRef = collection.doc(docId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.delete();
    }
  }
}
