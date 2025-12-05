import 'package:flutter/material.dart';
import '../../models/karyawan.dart';
import '../../service/firestore_service.dart';

class UserKaryawanPage extends StatefulWidget {
  const UserKaryawanPage({super.key});

  @override
  State<UserKaryawanPage> createState() => _UserKaryawanPageState();
}

class _UserKaryawanPageState extends State<UserKaryawanPage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<Karyawan> _data = [];
  List<Karyawan> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterData);
  }

  void _filterData() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _data
          .where((k) =>
              k.nama.toLowerCase().contains(q) ||
              k.jabatan.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE9F3F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderCard(),
            Expanded(
              child: StreamBuilder<List<Karyawan>>(
                stream: _service.getKaryawanStream(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  _data = snap.data!;
                  _filtered = _searchController.text.isEmpty
                      ? _data
                      : _filtered;

                  return _buildListView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== HEADER ============================
Widget _buildHeaderCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff0BA4E0), Color(0xff0065C8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Data Karyawan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Informasi karyawan perusahaan",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ===== SUMMARY CARDS =====
        StreamBuilder<List<Karyawan>>(
          stream: _service.getKaryawanStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _SummaryBox(label: "Total", value: "..."),
                  _SummaryBox(label: "Aktif", value: "..."),
                  _SummaryBox(label: "Nonaktif", value: "..."),
                ],
              );
            }

            final list = snap.data!;
            final aktif = list.where((k) => k.aktif).length;
            final non = list.length - aktif;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryBox(
                    label: "Total Karyawan", value: list.length.toString()),
                _SummaryBox(label: "Karyawan Aktif", value: aktif.toString()),
                _SummaryBox(label: "Nonaktif", value: non.toString()),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // ===== SEARCH FIELD =====
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari berdasarkan nama atau jabatan...",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ======================== LIST KARYAWAN ============================
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final k = _filtered[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ===== BADGE STATUS =====
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: k.aktif ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    k.aktif ? "Aktif" : "Nonaktif",
                    style: TextStyle(
                      color: k.aktif ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // FOTO
                    Center(
                      child: CircleAvatar(
                        radius: 34,
                        backgroundImage: _getAvatarImage(k.avatar),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // NAMA
                    Center(
                      child: Text(
                        k.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // JABATAN
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.business_center,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            k.jabatan,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // GARIS PEMBATAS
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),

                    const SizedBox(height: 12),

                    // EMAIL
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            k.email,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================== AVATAR HELPER ============================
  ImageProvider _getAvatarImage(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage("assets/default_avatar.png"); // fallback
    }
    if (url.startsWith("http")) {
      return NetworkImage(url);
    }
    return const AssetImage("assets/default_avatar.png"); // fallback
  }
}

// ====================== SUMMARY BOX ======================
class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
