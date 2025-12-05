import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/jadwal_pakan.dart';
import '../service/jadwal_pakan_service.dart';

class JadwalPakanScreen extends StatefulWidget {
  const JadwalPakanScreen({super.key});

  @override
  State<JadwalPakanScreen> createState() => _JadwalPakanScreenState();
}

class _JadwalPakanScreenState extends State<JadwalPakanScreen> {
  final JadwalPakanService _service = JadwalPakanService();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  // ==========================================================
  //            FUNGSI NOTIFIKASI (TETAP DIPAKAI)
  // ==========================================================
  Future<void> _jadwalkanNotifikasi(String jam, String kandang) async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final canScheduleExact =
        await androidPlugin?.areNotificationsEnabled() ?? false;

    if (!canScheduleExact) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Izin Exact Alarm belum diberikan. Aktifkan di Settings → Apps → Special App Access → Exact Alarm."),
        ),
      );
      return;
    }

    final parts = jam.split(':');
    final now = DateTime.now();

    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final tzTime = tz.TZDateTime.from(scheduled, tz.local);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Jadwal Pakan',
      'Saatnya memberi pakan di $kandang',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pakan_channel',
          'Pemberian Pakan',
          channelDescription: 'Notifikasi Jadwal Pakan Ternak',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ==========================================================
  //               TAMPILAN (STREAM FIREBASE)
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // <- stop munculkan tombol back
        title: const Text(
          "Jadwal Pemberian Pakan",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: StreamBuilder<List<JadwalPakan>>(
        stream: _service.streamData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) => _buildCard(data[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _tambahJadwal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ==========================================================
  //               CARD UI (Tetap seperti punyamu)
  // ==========================================================
  Widget _buildCard(JadwalPakan data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: Colors.lightBlueAccent, size: 30),
                const SizedBox(width: 10),
                Text(
                  data.jam,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _service.hapus(data.id),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            _detail("Kandang", data.kandang, Icons.home_filled),
            _detail("Pegawai", data.pegawai, Icons.person),
            _detail("Pakan", data.pakan, Icons.restaurant),
            _detail("Obat", data.obat, Icons.medical_services),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  //               BOTTOM SHEET TAMBAH JADWAL
  // ==========================================================
  void _tambahJadwal() {
    final jam = TextEditingController();
    final pegawai = TextEditingController();
    final pakan = TextEditingController();
    final obat = TextEditingController();
    String? selectedKandang;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        builder: (_, controller) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("kandang")
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snap.data!.docs
                    .map((e) => e["nama"]?.toString() ?? "Tanpa Nama")
                    .toList();

                return StatefulBuilder(
                  builder: (context, setStateBottom) => ListView(
                    controller: controller,
                    children: [
                      const SizedBox(height: 10),
                      const Text("Tambah Jadwal Baru",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      TextField(
                        controller: jam,
                        decoration: _noBorder("Jam (HH:MM)"),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: _noBorder("Pilih Kandang"),
                        items: list
                            .map((n) =>
                                DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: (v) =>
                            setStateBottom(() => selectedKandang = v),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                          controller: pegawai,
                          decoration: _noBorder("Pegawai")),
                      const SizedBox(height: 12),

                      TextField(
                          controller: pakan, decoration: _noBorder("Pakan")),
                      const SizedBox(height: 12),

                      TextField(
                          controller: obat, decoration: _noBorder("Obat")),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () async {
                          if (jam.text.isEmpty || selectedKandang == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Jam & kandang harus diisi")),
                            );
                            return;
                          }

                          final item = JadwalPakan(
                            id: "",
                            jam: jam.text,
                            kandang: selectedKandang!,
                            pegawai: pegawai.text,
                            pakan: pakan.text,
                            obat: obat.text,
                          );

                          await _service.tambah(item);
                          await _jadwalkanNotifikasi(jam.text, selectedKandang!);

                          Navigator.pop(context);
                        },
                        child: const Text("Simpan",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  InputDecoration _noBorder(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
