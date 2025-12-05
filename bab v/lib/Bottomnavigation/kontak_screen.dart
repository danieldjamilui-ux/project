import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import '../models/kontak_peternakan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KontakScreen extends StatelessWidget {
  const KontakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Kontak Kami",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<List<KontakPeternakan>>(
        stream: firestoreService.getKontakStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }

          final kontakList = snapshot.data ?? [];
          final emailPengguna = user?.email ?? "Email tidak tersedia";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // =========================
                //      EMAIL DARI AUTH
                // =========================
                _iconCard(
                  icon: Icons.email,
                  color: Colors.purple,
                  title: "Email",
                  subtitle: emailPengguna,
                ),

                const SizedBox(height: 16),

                // =========================
                //       ALAMAT MANUAL
                // =========================
                _iconCard(
                  icon: Icons.location_on,
                  color: Colors.orange,
                  title: "Alamat",
                  subtitle: "Jl. Merdeka No. 123, Ternate",
                ),

                const SizedBox(height: 16),

                // =========================
                //  TEKS DIPINDAHKAN KE SINI
                // =========================
                const Text(
                  "Hubungi kami untuk informasi lebih lanjut",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // =========================
                // KONTAK FIRESTORE (LAINNYA)
                // =========================
                ...kontakList.map((kontak) {
                  if (kontak.nama == "Email" || kontak.nama == "Alamat") {
                    return const SizedBox();
                  }
                  return _styledKontakCard(kontak, firestoreService, context);
                }).toList(),

                const SizedBox(height: 20),

                // JAM OPERASIONAL
                _jamOperasionalCard(),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddEditSheet(context, firestoreService);
        },
      ),
    );
  }

  // =======================================================
  //                    CARD EMAIL & ALAMAT
  // =======================================================
  Widget _iconCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  //                CARD KONTAK FIRESTORE
  //     HANYA WHATSAPP MENGGUNAKAN GAMBAR PNG
  // =======================================================
  Widget _styledKontakCard(
    KontakPeternakan kontak,
    FirestoreService firestoreService,
    BuildContext context,
  ) {
    final Map<String, Color> iconColor = {
      "Telepon": Colors.blue,
      "WhatsApp": Colors.green,
      "Kontak Karyawan": Colors.teal,
    };

    final Color color = iconColor[kontak.nama] ?? Colors.blue;

    bool useImage = kontak.nama == "WhatsApp" || kontak.nama == "Kontak Karyawan";
    final Map<String, String> imageAssets = {
  "WhatsApp": "assets/images/google_logo.png",
  "Kontak Karyawan": "assets/images/google_logo.png",
};


    IconData iconData =
        kontak.nama == "Telepon"
            ? Icons.call
            : kontak.nama == "Kontak Karyawan"
                ? Icons.person
                : Icons.chat_bubble;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),

 child: useImage
    ? Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          imageAssets[kontak.nama] ?? "assets/images/google_logo.png",
          fit: BoxFit.contain,
        ),
      )
    : Icon(iconData, color: color, size: 30),

          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kontak.nama,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(kontak.alamat,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 4),
                Text(kontak.noHp,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  //                     CARD JAM OPERASIONAL
  // =======================================================
  Widget _jamOperasionalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B2CFF), Color(0xFF6C00FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jam Operasional",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Senin - Jumat", style: TextStyle(color: Colors.white)),
              Text("08:00 - 16:00", style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sabtu", style: TextStyle(color: Colors.white)),
              Text("08:00 - 12:00", style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Minggu & Hari Libur", style: TextStyle(color: Colors.white)),
              Text("Tutup", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // =======================================================
  //                BOTTOM SHEET TAMBAH / EDIT
  // =======================================================
  void _showAddEditSheet(
    BuildContext context,
    FirestoreService firestoreService, {
    KontakPeternakan? kontak,
  }) {
    final namaController = TextEditingController(text: kontak?.nama ?? '');
    final alamatController = TextEditingController(text: kontak?.alamat ?? '');
    final noHpController = TextEditingController(text: kontak?.noHp ?? '');

    InputDecoration borderless(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  Text(
                    kontak == null ? "Tambah Kontak" : "Edit Kontak",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                      controller: namaController,
                      decoration: borderless("Nama")),
                  const SizedBox(height: 12),

                  TextField(
                      controller: alamatController,
                      decoration: borderless("Alamat")),
                  const SizedBox(height: 12),

                  TextField(
                    controller: noHpController,
                    decoration: borderless("No. HP"),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final newKontak = KontakPeternakan(
                        id: kontak?.id ?? '',
                        nama: namaController.text,
                        alamat: alamatController.text,
                        noHp: noHpController.text,
                      );

                      if (kontak == null) {
                        firestoreService.addKontak(newKontak);
                      } else {
                        firestoreService.updateKontak(newKontak);
                      }

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
