import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/peternak.dart';
import '../home.dart';

class DaftarPeternakScreen extends StatefulWidget {
  const DaftarPeternakScreen({super.key});

  @override
  State<DaftarPeternakScreen> createState() => _DaftarPeternakScreenState();
}

class _DaftarPeternakScreenState extends State<DaftarPeternakScreen> {
  final CollectionReference peternakRef =
      FirebaseFirestore.instance.collection('peternak');

  String searchQuery = "";

  Future<void> _tambahPeternak(String nama, String lokasi, int jumlah) async {
    await peternakRef.add({
      'nama': nama,
      'lokasi': lokasi,
      'jumlahTernak': jumlah,
    });
  }

  Future<void> _hapusPeternak(String id) async {
    await peternakRef.doc(id).delete();
  }

  Future<void> _updateJumlah(String id, int jumlah) async {
    await peternakRef.doc(id).update({'jumlahTernak': jumlah});
  }

  // ============= BOTTOM SHEET TAMBAH PETERNAK ===============
void _showTambahPeternakSheet(BuildContext context) {
  final namaCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final jumlahCtrl = TextEditingController(text: "0");
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tambah Peternak Baru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // FIELD TANPA BORDER
                TextFormField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    labelText: "Nama",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: lokasiCtrl,
                  decoration: InputDecoration(
                    labelText: "Lokasi",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Lokasi wajib diisi" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah Ternak",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Masukkan jumlah ternak" : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _tambahPeternak(
                          namaCtrl.text,
                          lokasiCtrl.text,
                          int.parse(jumlahCtrl.text),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  // ===================== UI UTAMA ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(username: "Admin"),
                          ),
                        );
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Data Peternak",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Kelola informasi peternak",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari peternak...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Button Tambah Peternak → BOTTOM SHEET
                GestureDetector(
                  onTap: () => _showTambahPeternakSheet(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.black, Color(0xFFE91E63)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Tambah Peternak Baru",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================== LIST DATA ====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: peternakRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['nama']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("Data tidak ditemukan"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final peternak = Peternak.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                              ),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 28),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  peternak.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(peternak.lokasi),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFD9FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${peternak.jumlahTernak} ekor",
                                  style: const TextStyle(
                                    color: Color(0xFF8E24AA),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.orange),
                                    onPressed: () {
                                      if (peternak.jumlahTernak > 0) {
                                        _updateJumlah(
                                          peternak.id,
                                          peternak.jumlahTernak - 1,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.green),
                                    onPressed: () {
                                      _updateJumlah(
                                        peternak.id,
                                        peternak.jumlahTernak + 1,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _hapusPeternak(peternak.id),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
