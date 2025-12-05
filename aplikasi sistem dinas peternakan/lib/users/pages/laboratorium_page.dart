import 'package:flutter/material.dart';
import '../../service/pemeriksaan_sampel_service.dart';
import '../../models/sampel.dart';

class LaboratoriumUserPage extends StatefulWidget {
  const LaboratoriumUserPage({super.key});

  @override
  State<LaboratoriumUserPage> createState() => _LaboratoriumUserPageState();
}

class _LaboratoriumUserPageState extends State<LaboratoriumUserPage> {
  final PemeriksaanSampelService service = PemeriksaanSampelService();

  String search = "";
  String speciesFilter = "Semua";
  String statusFilter = "Semua"; // untuk Negatif / Positif filter

  final List<String> speciesList = [
    "Semua", "Sapi", "Kambing", "Ayam", "Kucing", "Domba",
  ];

  final List<String> statusList = [
    "Semua", "Perlu Tindak Lanjut", "Belum Selesai", "Selesai"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  _filterBox(),
                  const SizedBox(height: 20),
                  _streamList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER (PERSIS REFERENSI)
  // ---------------------------------------------------------
  Widget _header() {
    return StreamBuilder(
      stream: service.getAllSampel(),
      builder: (context, snapshot) {
        int total = 0, negatif = 0, positif = 0, proses = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          total = docs.length;
          for (var d in docs) {
            final data = d.data();

            if (data["outcome"] == "Negatif") negatif++;
            if (data["outcome"] == "Positif") positif++;

            final status = data["status"];
            if (status == "Belum Selesai" || status == "Perlu Tindak Lanjut") {
              proses++;
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffd8006c), Color(0xffff4b4b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK BUTTON tepat seperti referensi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hasil Laboratorium",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Informasi Pemeriksaan Kesehatan Hewan",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
               SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _summaryCard(Icons.grid_view, "Total Tes", total)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryCard(Icons.check, "Negatif", negatif)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _summaryCard(Icons.warning, "Positif", positif)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryCard(Icons.timer, "Proses", proses)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(IconData icon, String label, int value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            "$value",
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FILTER BOX (SAMA PERSIS REFERENSI)
  // ---------------------------------------------------------
  Widget _filterBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchField(),
          const SizedBox(height: 20),

          const SizedBox(height: 20),
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      "STATUS",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: _statusFilterRow(),
      ),
    ),
  ],
),

        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff4f6fb),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Cari ID hewan, nama pemilik...",
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
  /// FILTER POSITIF / NEGATIF / SEMUA
/// FILTER STATUS (NEW UI)
Widget _statusFilterRow() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _statusButton("Semua"),
      const SizedBox(width: 8),
      _statusButton("Negatif"),
      const SizedBox(width: 8),
      _statusButton("Positif"),
    ],
  );
}


Widget _statusButton(String title) {
  final bool active = statusFilter == title;

  return GestureDetector(
    onTap: () => setState(() => statusFilter = title),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xffd8006c), Color(0xffff4b4b)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(25),

        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black12.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],

        border: Border.all(
          color: active ? Colors.transparent : const Color(0xffe4e6eb),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}

  // ---------------------------------------------------------
  // LIST STREAM + FILTER
  // ---------------------------------------------------------
  Widget _streamList() {
    return StreamBuilder(
      stream: service.getAllSampel(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data!.docs.where((doc) {
          final d = doc.data();

          final matchSearch =
              d["animalId"].toLowerCase().contains(search.toLowerCase()) ||
              d["animalName"].toLowerCase().contains(search.toLowerCase());

          final matchSpecies = speciesFilter == "Semua" || d["species"] == speciesFilter;

          final matchStatus =
              statusFilter == "Semua" || d["outcome"] == statusFilter;

          return matchSearch && matchSpecies && matchStatus;
        }).toList();

        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text("Tidak ada data ditemukan."),
          );
        }

        return Column(
          children: data.map((doc) {
            final item = SwabDarah.fromMap(doc.id, doc.data());
            return _cardUser(item);
          }).toList(),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // CARD (SAMA PERSIS REFERENSI)
  // ---------------------------------------------------------
  Widget _cardUser(SwabDarah d) {
    final bool negatif = d.outcome == "Negatif";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: negatif ? Colors.green : Colors.redAccent,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(12)),
                  child: _emoji(d.species),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      d.species,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    )
                  ],
                ),
                const Spacer(),

                Icon(
                  negatif ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 30,
                )
              ],
            ),
          ),

          // BODY
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail(Icons.biotech, "Jenis Pemeriksaan", d.testType),
                const SizedBox(height: 10),
                _detail(Icons.calendar_month, "Tanggal Pemeriksaan", d.testDate),

                const SizedBox(height: 20),
                _result(d.outcome),

                if (d.status != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _status(d.status),
                  ),

                const SizedBox(height: 10),
                Text("• Record: ${d.id}",
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emoji(String s) {
    switch (s) {
      case "Sapi":
        return const Text("🐮", style: TextStyle(fontSize: 40));
      case "Kambing":
        return const Text("🐐", style: TextStyle(fontSize: 40));
      case "Ayam":
        return const Text("🐔", style: TextStyle(fontSize: 40));
      case "Kucing":
        return const Text("🐱", style: TextStyle(fontSize: 40));
      case "Domba":
        return const Text("🐑", style: TextStyle(fontSize: 40));
      default:
        return const Icon(Icons.pets, size: 40, color: Colors.white);
    }
  }

  Widget _detail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _result(String t) {
    final neg = t == "Negatif";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: neg ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neg ? Colors.green : Colors.redAccent),
      ),
      child: Row(
        children: [
          Icon(neg ? Icons.check : Icons.error, color: neg ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Text(
            t,
            style: TextStyle(
              color: neg ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(String s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        s,
        style: TextStyle(
          color: Colors.orange[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
