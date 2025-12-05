import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationClientUI extends StatefulWidget {
  const NotificationClientUI({super.key});

  @override
  State<NotificationClientUI> createState() => _NotificationClientUIState();
}

class _NotificationClientUIState extends State<NotificationClientUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),

      // ============================
      //        APP BAR
      // ============================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.black),
            SizedBox(width: 8),
            Text(
              "Notification",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),

      // ============================
      //       BODY CONTENT
      // ============================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("jadwal_pakan")
              .orderBy("createdAt", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var docs = snapshot.data!.docs;

            return Column(
              children: docs.map((d) {
                return _tugasCard(
                  jam: d["jam"],
                  lokasi: d["kandang"],
                  pakan: d["pakan"],
                  obat: d["obat"],
                  petugas: d["pegawai"],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  //                CARD STYLE MODERN
  // =====================================================
  Widget _tugasCard({
    required String jam,
    required String lokasi,
    required String pakan,
    required String obat,
    required String petugas,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // ================= LEFT GREEN STRIP =================
          Container(
            width: 6,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // JAM & LABEL
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jam,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            "WAKTU PAKAN",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 18),

                  // KANDANG / LOKASI
                  _iconSection(
                    icon: Icons.location_on,
                    label: "Lokasi / Kandang",
                    value: lokasi,
                  ),

                  const SizedBox(height: 16),

                  // JENIS PAKAN
                  _iconSection(
                    icon: Icons.inventory_2,
                    label: "Jenis Pakan",
                    value: pakan,
                  ),

                  const SizedBox(height: 16),

                  // OBAT / VITAMIN
                  _iconSection(
                    icon: Icons.vaccines,
                    label: "Obat / Vitamin",
                    value: obat,
                  ),

                  const SizedBox(height: 20),

                  // PETUGAS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black54),
                        const SizedBox(width: 10),
                        Text(
                          petugas,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  //        ICON + LABEL + VALUE (REUSABLE SECTION)
  // =====================================================
  Widget _iconSection({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black45, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
