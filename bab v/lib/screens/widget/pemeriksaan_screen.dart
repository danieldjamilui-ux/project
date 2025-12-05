import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pemeriksaan.dart';

class PemeriksaanScreen extends StatefulWidget {
  const PemeriksaanScreen({super.key});

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  final CollectionReference _pemeriksaanRef =
      FirebaseFirestore.instance.collection('pemeriksaan');

  final TextEditingController _searchC = TextEditingController();
  String searchQuery = "";

  final TextEditingController _namaC = TextEditingController();
  final TextEditingController _jenisC = TextEditingController();
  final TextEditingController _jumlahC = TextEditingController();
  String _status = "Sehat";

  // ===========================
  //   BOTTOM SHEET TAMBAH
  // ===========================
  void _tambahPemeriksaan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  "Tambah Pemeriksaan",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // FIELD BORDERLESS
                _inputField("Nama Pemilik", _namaC),
                _inputField("Jenis Ternak", _jenisC),
                _inputField("Jumlah Ternak", _jumlahC,
                    isNumber: true),

                const SizedBox(height: 12),

                DropdownButtonFormField(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: "Sehat", child: Text("Sehat")),
                    DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    labelText: "Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_namaC.text.isEmpty ||
                          _jenisC.text.isEmpty ||
                          _jumlahC.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lengkapi semua data!")),
                        );
                        return;
                      }

                      await _pemeriksaanRef.add({
                        "namaPemilik": _namaC.text,
                        "jenisTernak": _jenisC.text,
                        "jumlah": int.tryParse(_jumlahC.text) ?? 0,
                        "status": _status,
                        "tanggal":
                            "${DateTime.now().day} ${_namaBulan(DateTime.now().month)} ${DateTime.now().year}",
                      });

                      _namaC.clear();
                      _jenisC.clear();
                      _jumlahC.clear();
                      _status = "Sehat";

                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // INPUT BORDERLESS
  Widget _inputField(String label, TextEditingController c,
      {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ===========================
  //   BULAN
  // ===========================
  String _namaBulan(int b) {
    const bulan = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return bulan[b - 1];
  }

  void _ubahStatus(String id, String status) async {
    await _pemeriksaanRef
        .doc(id)
        .update({"status": status == "Sehat" ? "Sakit" : "Sehat"});
  }

  void _hapusData(String id) async {
    await _pemeriksaanRef.doc(id).delete();
  }

  // ===========================
  //   UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTambahButton(),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPemeriksaan,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B2FFF), Color(0xFF9A4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Data Pemeriksaan Ternak",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Monitor kesehatan ternak",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: TextField(
        controller: _searchC,
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Cari pemeriksaan...",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // BUTTON TAMBAH
  Widget _buildTambahButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _tambahPemeriksaan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B2FFF),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "+ Tambah Pemeriksaan Baru",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // LIST
  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pemeriksaanRef.orderBy("tanggal", descending: true).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!.docs.map((e) {
          return Pemeriksaan.fromMap(e.data() as Map<String, dynamic>, e.id);
        }).where((item) {
          return item.namaPemilik
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item.jenisTernak
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: data.length,
          itemBuilder: (_, i) => _buildCard(data[i]),
        );
      },
    );
  }

  // CARD
  Widget _buildCard(Pemeriksaan p) {
    final isSehat = p.status == "Sehat";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isSehat ? Colors.green : Colors.red,
                child: Icon(
                  isSehat ? Icons.check : Icons.warning,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${p.namaPemilik} - ${p.jenisTernak}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSehat
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  p.status,
                  style: TextStyle(
                    color: isSehat ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text("Jumlah: ${p.jumlah} ekor",
              style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text("Tanggal: ${p.tanggal}",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _ubahStatus(p.id, p.status),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe6ebff),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Ubah Status"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _hapusData(p.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffffe6e6),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Hapus"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
