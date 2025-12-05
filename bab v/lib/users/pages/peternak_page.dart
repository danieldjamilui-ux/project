import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataPeternakUser extends StatefulWidget {
  const DataPeternakUser({super.key});

  @override
  State<DataPeternakUser> createState() => _DataPeternakUserState();
}

class _DataPeternakUserState extends State<DataPeternakUser> {
  String selectedLokasi = "Semua";
  String searchQuery = "";

Map<String, int> lokasiCounts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("peternak").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var allDocs = snapshot.data!.docs;
          final totalPeternak = allDocs.length;
          final totalTernak = allDocs.fold<int>(
            0,
            (prev, doc) => prev + (doc["jumlahTernak"] ?? 0) as int,
          );

          // Update count lokasi realtime
          lokasiCounts["Semua"] = totalPeternak;
          lokasiCounts["Ternate"] =
              allDocs.where((d) => d["lokasi"] == "Ternate").length;
          lokasiCounts["Tidore"] =
              allDocs.where((d) => d["lokasi"] == "Tidore").length;
          lokasiCounts["Sofifi"] =
              allDocs.where((d) => d["lokasi"] == "Sofifi").length;
          lokasiCounts["Tobelo"] =
              allDocs.where((d) => d["lokasi"] == "Tobelo").length;

          return Column(
            children: [
              _buildHeader(totalPeternak, totalTernak),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: _buildSearchBar(),
                      ),

                      _buildFilterLokasi(),

                      const SizedBox(height: 20),
                      _buildFirestoreList(allDocs),

                      const SizedBox(height: 20),
                      _buildInfoCard(),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // 🔵 HEADER
  // ============================================================
  Widget _buildHeader(int totalPeternak, int totalTernak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data Peternak",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Informasi peternak di wilayah Anda",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildInfoBox(
              icon: Icons.people,
              title: "Total Peternak",
              value: totalPeternak.toString()),

          const SizedBox(height: 14),
          _buildInfoBox(
            icon: Icons.pets,
            title: "Total Ternak",
            value: "$totalTernak ekor",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔍 SEARCH BAR — diperbaiki
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: "Cari peternak..."),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🟣 FILTER LOKASI
  // ============================================================
Widget _buildFilterLokasi() {
  List<String> lokasi = ["Semua", "Ternate", "Tidore", "Sofifi", "Tobelo"];

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: lokasi.map((l) {
        bool active = selectedLokasi == l;

        int count = lokasiCounts[l] ?? 0;

        String buttonText;

        if (l == "Semua") {
          buttonText = "Semua Lokasi";
        } else if (count == 0) {
          buttonText = l; // 🔥 Tidak tampilkan (0)
        } else {
          buttonText = "$l ($count)";
        }

        return GestureDetector(
          onTap: () => setState(() => selectedLokasi = l),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)])
                  : null,
              color: active ? null : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: Colors.black12, width: active ? 0 : 1),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
        );
      }).toList(),
    ),
  );
}


  // ============================================================
  // LIST PETERNak
  // ============================================================
  Widget _buildFirestoreList(List<DocumentSnapshot> allDocs) {
    var docs = allDocs;

    if (selectedLokasi != "Semua") {
      docs = docs
          .where((d) =>
              d["lokasi"].toString().toLowerCase() ==
              selectedLokasi.toLowerCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      docs = docs
          .where((d) =>
              d["nama"].toString().toLowerCase().contains(searchQuery) ||
              d["lokasi"].toString().toLowerCase().contains(searchQuery))
          .toList();
    }

    const int kapasitasMaks = 25;

    return Column(
      children: docs.map((d) {
        final data = d.data() as Map<String, dynamic>;

        return _buildPeternakCard(
          nama: data["nama"] ?? "-",
          lokasi: data["lokasi"] ?? "-",
          jumlah: data["jumlahTernak"] ?? 0,
          kapasitasPersen:
              (((data["jumlahTernak"] ?? 0) / kapasitasMaks) * 100).toInt(),
          kapasitasMaks: kapasitasMaks,
        );
      }).toList(),
    );
  }

  // ============================================================
  // CARD PETERNak
  // ============================================================
  Widget _buildPeternakCard({
    required String nama,
    required String lokasi,
    required int jumlah,
    required int kapasitasPersen,
    required int kapasitasMaks,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff9b83ff).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person,
                    color: Color(0xFF9C27B0), size: 24),
              ),
              const SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.black54),
                      Text(lokasi,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jumlah Ternak",
                        style:
                            TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text("$jumlah",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        )),
                  ]),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xffe8f7f0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("ekor",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text("Kapasitas",
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: kapasitasPersen / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("$kapasitasPersen%",
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),

      child: Row(
        children: [
          const Icon(Icons.people, color: Color(0xFF9C27B0), size: 28),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Informasi",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text(
                  "Data ini diperbarui secara real-time. Anda dapat melihat informasi tentang peternak dan jumlah ternak di wilayah Anda.",
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
