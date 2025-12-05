import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pemeriksaan.dart';

class MedisUserPage extends StatefulWidget {
  const MedisUserPage({super.key});

  @override
  State<MedisUserPage> createState() => _MedisUserPageState();
}

class _MedisUserPageState extends State<MedisUserPage> {
  final CollectionReference pemeriksaanRef =
      FirebaseFirestore.instance.collection('pemeriksaan');

  String searchQuery = "";
  String filterStatus = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildResultCount(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // HEADER dengan Gradient Ungu
  // ===========================================================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 73, 32, 255), Color.fromARGB(255, 163, 66, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title dengan icon
          Row(
  children: [
    // TOMBOL BACK
    GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 22,
        ),
      ),
    ),

    const SizedBox(width: 12),

    // ICON ORANG
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.people_alt,
        color: Colors.white,
        size: 28,
      ),
    ),

    const SizedBox(width: 12),

    // TEKS JUDUL
    const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data Pemeriksaan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Text(
          "Ternak",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ],
    ),
  ],
),

          const SizedBox(height: 6),
          const Text(
            "Informasi Kesehatan Hewan Ternak",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 30),
          _buildStats(),
        ],
      ),
    );
  }

  // ===========================================================
  // STATISTIK Cards
  // ===========================================================
  Widget _buildStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: pemeriksaanRef.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final total = snap.data!.docs.length;
        final sehat = snap.data!.docs.where((e) => e['status'] == "Sehat").length;
        final sakit = snap.data!.docs.where((e) => e['status'] == "Sakit").length;

        return Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.people_alt,
              title: "Total\nTernak",
              value: "$total",
              subtitle: "Ekor",
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.check_circle_outline,
              title: "Sehat",
              value: "$sehat",
              subtitle: "Pemeriksaan",
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.error_outline,
              title: "Sakit",
              value: "$sakit",
              subtitle: "Pemeriksaan",
            )),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // SEARCH BAR dan FILTER
  // ===========================================================
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Cari nama pemilik atau jenis ternak...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Buttons
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              _buildFilterChip("Semua"),
              const SizedBox(width: 8),
              _buildFilterChip("Sehat"),
              const SizedBox(width: 8),
              _buildFilterChip("Sakit"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = filterStatus == label;
    return GestureDetector(
      onTap: () => setState(() => filterStatus = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black87 : const Color.fromARGB(255, 255, 255, 255),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // RESULT COUNT
  // ===========================================================
  Widget _buildResultCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: pemeriksaanRef.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();

        List<Pemeriksaan> list = snap.data!.docs.map((e) {
          return Pemeriksaan.fromMap(e.data() as Map<String, dynamic>, e.id);
        }).toList();

        // Apply filters
        list = list.where((item) {
          return item.namaPemilik
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item.jenisTernak
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();

        if (filterStatus != "Semua") {
          list = list.where((e) => e.status == filterStatus).toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Menampilkan ${list.length} hasil pemeriksaan",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // LIST
  // ===========================================================
  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: pemeriksaanRef.orderBy("tanggal", descending: true).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Pemeriksaan> list = snap.data!.docs.map((e) {
          return Pemeriksaan.fromMap(e.data() as Map<String, dynamic>, e.id);
        }).toList();

        // Apply search filter
        list = list.where((item) {
          return item.namaPemilik
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item.jenisTernak
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();

        // Apply status filter
        if (filterStatus != "Semua") {
          list = list.where((e) => e.status == filterStatus).toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: const Color.fromARGB(255, 255, 255, 255)),
                const SizedBox(height: 16),
                Text(
                  "Tidak ada data ditemukan",
                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          itemCount: list.length,
          itemBuilder: (_, i) => _buildCard(list[i]),
        );
      },
    );
  }

  // ===========================================================
  // CARD - Desain sesuai gambar
  // ===========================================================
  Widget _buildCard(Pemeriksaan p) {
    final bool sehat = p.status == "Sehat";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Status Badge
          Row(
            children: [
              // Avatar dengan icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sehat
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFECDD3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  sehat ? Icons.check_circle : Icons.error_outline,
                  color: sehat ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Name & Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.namaPemilik,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.jenisTernak,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sehat
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFECDD3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.status,
                  style: TextStyle(
                    color: sehat ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jumlah
          Row(
            children: [
              Icon(Icons.people_alt, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "Jumlah: ${p.jumlah} ekor",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tanggal
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                p.tanggal,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),

          // ID dan Status Kondisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID: ${p.id.length > 10 ? p.id.substring(0, 10) : p.id}...",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: sehat ? const Color(0xFF10B981) : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sehat ? "Kondisi Baik" : "Perlu Perhatian",
                    style: TextStyle(
                      fontSize: 12,
                      color: sehat ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}