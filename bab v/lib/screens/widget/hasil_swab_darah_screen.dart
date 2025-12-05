import 'package:flutter/material.dart';
import '../../service/pemeriksaan_sampel_service.dart';
import '../../models/sampel.dart';

class HasilSwabDarahScreen extends StatefulWidget {
  const HasilSwabDarahScreen({super.key});

  @override
  State<HasilSwabDarahScreen> createState() => _HasilSwabDarahScreenState();
}

class _HasilSwabDarahScreenState extends State<HasilSwabDarahScreen> {
  final PemeriksaanSampelService service = PemeriksaanSampelService();

  String search = "";
  String speciesFilter = "Semua";
  String statusFilter = "Semua";

  final List<String> speciesList = [
    "Semua", "Sapi", "Kambing", "Ayam", "Kucing", "Domba",
  ];

  final List<String> statusList = [
    "Semua", "Selesai", "Perlu Tindak Lanjut", "Belum Selesai",
  ];

  final List<String> outcomeOptions = ["Positif", "Negatif"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f7fc),

      appBar: _buildAppBar(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () => _openAddBottomSheet(context),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hasil Swab Darah",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Manajemen data hasil pemeriksaan laboratorium.",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 20),

            _buildFilterArea(),

            const SizedBox(height: 16),

            Expanded(child: _buildListCards()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APPBAR
  // ---------------------------------------------------------------------------
AppBar _buildAppBar() {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,

    // 🔥 Panah kembali
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),

    title: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Lab Keswan",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        Text("Monitoring Hasil Swab",
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    ),

    // 🔥 Pindahkan ikon lama ke kanan (opsional)
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffbb2121),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.show_chart, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}

  // ---------------------------------------------------------------------------
  // FILTER AREA
  // ---------------------------------------------------------------------------
  Widget _buildFilterArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _searchField(),

        const SizedBox(height: 14),

        _sectionLabel("SPESIES"),
        _horizontalChips(speciesList, true),

        const SizedBox(height: 14),

        _sectionLabel("STATUS"),
        _horizontalChips(statusList, false),
      ],
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 52,
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: "Cari ID Hewan atau Nama Pemilik...",
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => setState(() => search = v),
      ),
    );
  }

  Widget _horizontalChips(List<String> items, bool species) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items.map((label) {
          final active = species
              ? speciesFilter == label
              : statusFilter == label;

          return GestureDetector(
            onTap: () => setState(() {
              species
                  ? speciesFilter = label
                  : statusFilter = label;
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? (species ? const Color.fromARGB(255, 164, 27, 27) : Colors.blueGrey.shade900)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active
                      ? (species ? Colors.redAccent : Colors.blueGrey.shade900)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STREAM LIST / CARDS
  // ---------------------------------------------------------------------------
  Widget _buildListCards() {
    return StreamBuilder(
      stream: service.getAllSampel(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = snapshot.data!.docs.where((doc) {
          final d = doc.data();

          final matchSearch =
              d["animalId"].toLowerCase().contains(search.toLowerCase()) ||
                  d["animalName"].toLowerCase().contains(search.toLowerCase());

          final matchSpecies =
              speciesFilter == "Semua" || d["species"] == speciesFilter;

          final matchStatus =
              statusFilter == "Semua" || d["status"] == statusFilter;

          return matchSearch && matchSpecies && matchStatus;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("Tidak ada data yang cocok."));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final data = SwabDarah.fromMap(filtered[i].id, filtered[i].data());
            return _buildCard(data, filtered[i].id);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CARD UI
  // ---------------------------------------------------------------------------
  Widget _buildCard(SwabDarah d, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            width: 6,
            color: d.outcome == "Negatif" ? Colors.green : Colors.red,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(d),
            const SizedBox(height: 10),

            _cardOwner(d),
            const SizedBox(height: 12),

            _testTypeBadge(d.testType),
            const SizedBox(height: 16),

            _label("Hasil"),
            _dropdownOutcome(d, docId),
            const SizedBox(height: 14),

            _label("Status"),
            _dropdownStatus(d, docId),
            const SizedBox(height: 10),

            _statusSummaryChips(d)
          ],
        ),
      ),
    );
  }

  Row _cardHeader(SwabDarah d) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Text(d.id,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 8),
          _chipSmall(d.species),
        ]),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(d.testDate,
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _cardOwner(SwabDarah d) {
    return Row(
      children: [
        const Icon(Icons.person, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Text(d.name, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _testTypeBadge(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.biotech, size: 25, color: Colors.red),
          const SizedBox(width: 6),
          Text(t,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _label(String t) {
    return Text(t,
        style: const TextStyle(fontSize: 13, color: Colors.black54));
  }

  InputDecoration _dropdownDecor() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xfff4f7fc),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  DropdownButtonFormField<String> _dropdownOutcome(SwabDarah d, String docId) {
    return DropdownButtonFormField<String>(
      value: d.outcome,
      decoration: _dropdownDecor(),
      items: outcomeOptions.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(
            s,
            style: TextStyle(
              color: s == "Positif" ? Colors.red : Colors.green,
            ),
          ),
        );
      }).toList(),
      onChanged: (v) async {
        if (v != null) {
          await service.updateOutcome(docId, v);
          setState(() => d.outcome = v);
        }
      },
    );
  }

  DropdownButtonFormField<String> _dropdownStatus(SwabDarah d, String docId) {
    return DropdownButtonFormField<String>(
      value: d.status,
      decoration: _dropdownDecor(),
      items: statusList
          .where((e) => e != "Semua")
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) async {
        if (v != null) {
          await service.updateStatus(docId, v);
          setState(() => d.status = v);
        }
      },
    );
  }

  Widget _statusSummaryChips(SwabDarah d) {
    return Row(
      children: [
        _chipStatus(d.outcome == "Negatif" ? "Negatif" : "Positif",
            d.outcome == "Negatif" ? const Color.fromARGB(255, 0, 184, 40) : Colors.red),
        const SizedBox(width: 8),
        _chipStatus(d.status, const Color.fromARGB(255, 0, 103, 5)),
      ],
    );
  }

  Widget _chipStatus(String t, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: color, size: 16),
          const SizedBox(width: 6),
          Text(t, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _chipSmall(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xfff4f7fc),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(t,
          style: const TextStyle(fontSize: 12, color: Colors.black)),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM SHEET TAMBAH DATA
  // ---------------------------------------------------------------------------
  void _openAddBottomSheet(BuildContext context) {
    final id = TextEditingController();
    final name = TextEditingController();
    final species = TextEditingController();
    final date = TextEditingController();
    final type = TextEditingController();
    String outcome = "Negatif";
    String status = "Belum Selesai";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const Text(
                  "Tambah Data Swab Darah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _formBox("ID Ternak", id),
                _formBox("Nama Pemilik", name),
                _formBox("Spesies", species),
                _formBox("Tanggal (yyyy-mm-dd)", date),
                _formBox("Jenis Tes", type),

                const SizedBox(height: 10),

                _dropdownBox(
                  label: "Hasil",
                  value: outcome,
                  items: outcomeOptions,
                  onChanged: (v) => outcome = v!,
                ),

                const SizedBox(height: 10),

                _dropdownBox(
                  label: "Status",
                  value: status,
                  items: statusList.where((e) => e != "Semua").toList(),
                  onChanged: (v) => status = v!,
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await service.addSampel(
                        animalId: id.text,
                        animalName: name.text,
                        species: species.text,
                        testDate: date.text,
                        testType: type.text,
                        outcome: outcome,
                        status: status,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FORM COMPONENT TANPA GARIS
  // ---------------------------------------------------------------------------
  Widget _formBox(String label, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff4f7fc),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdownBox({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xfff4f7fc),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField(
        value: value,
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
