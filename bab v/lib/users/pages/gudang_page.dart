import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/gudang.dart';
import '../../service/firestore_service.dart';

class GudangPage extends StatefulWidget {
  const GudangPage({super.key});

  @override
  State<GudangPage> createState() => _GudangPageState();
}

class _GudangPageState extends State<GudangPage> {
  final firestore = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
child: Column(
  children: [
    _buildHeader(),
    _buildSearchBar(),

    // BAGIAN LIST SCROLL
    Expanded(child: _buildListSection()),

    // FOOTER DI BAWAH
    _buildFooter(),
  ],
),

      ),
    );
  }

  // HEADER
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      children: [
        // ← Tombol Panah Kembali
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
        ),
        const SizedBox(width: 8),

        // Icon Gudang
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),

        // Title
        const Text(
          "Gudang",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}


  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "Data\n",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Gudang",
                  style: TextStyle(
                    color: Color(0xFF2E8B57),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Cari gudang berdasarkan nama, lokasi, atau pengurus",
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LIST
  Widget _buildListSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<List<Gudang>>(
          stream: firestore.getGudangStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
              );
            }

            final allGudang = snapshot.data!;
            final filtered = allGudang.where((g) {
              final q = searchQuery.toLowerCase();
              return g.nama.toLowerCase().contains(q) ||
                  g.lokasi.toLowerCase().contains(q) ||
                  g.pengurus.toLowerCase().contains(q);
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada gudang ditemukan',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                return _buildGudangCard(filtered[i]);
              },
            );
          },
        ),
      ),
    );
  }

  // CARD
  Widget _buildGudangCard(Gudang gudang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: gudang.imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 48),
                  memCacheHeight: 400,
                  memCacheWidth: 800,
                ),
                Container(
                  height: 200,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    gudang.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),

          // INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _info(Icons.location_on, "LOKASI", gudang.lokasi),
                const SizedBox(height: 12),
                _info(Icons.square_foot, "UKURAN", gudang.ukuran),
                const SizedBox(height: 12),
                _info(Icons.person, "PENGURUS", gudang.pengurus),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(gudang.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E8B57)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Tanggal tidak tersedia";
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

Widget _buildFooter() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20, top: 10),
    child: Text(
      "© 2025 GudangView System. All rights reserved.",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    ),
  );
}
