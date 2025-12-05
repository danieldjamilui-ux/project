import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_seminar/users/pages/peternak_page.dart';
import 'package:project_seminar/users/pages/karyawan_page.dart';
import 'package:project_seminar/users/pages/kandang_page.dart';
import 'package:project_seminar/users/pages/gudang_page.dart';
import 'package:project_seminar/users/pages/medis_page.dart';
import 'package:project_seminar/users/pages/laboratorium_page.dart';
import 'package:project_seminar/users/profile_page.dart';
import 'package:project_seminar/users/notification_page.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// Definisi Konstanta Warna
const Color kPrimaryColor = Color.fromARGB(255, 41, 238, 241);
const Color kSecondaryColor = Color.fromARGB(255, 135, 227, 5);
const Color kBackgroundColor = Color.fromARGB(128, 3, 106, 224);

class HomeScreen extends StatelessWidget {
  final String username;

  HomeScreen({super.key, required this.username});

  Future<List<Map<String, dynamic>>> loadKontakLainnya() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('kontak_peternakan')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'nama': doc['nama'] ?? '-',
        'alamat': doc['alamat'] ?? '-',
        'noHp': doc['noHp'] ?? '-',
      };
    }).toList();
  }

  String getInitials(String fullName) {
    List<String> parts = fullName.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Peternak',
      'subtitle': 'Mitra & Anggota',
      'icon': Icons.people_alt,
      'color': Colors.pinkAccent,
      'bg': const Color(0xfffff1f2)
    },
    {
      'title': 'Karyawan',
      'subtitle': 'Tim Kerja',
      'icon': Icons.person_outline,
      'color': Colors.blueAccent,
      'bg': const Color(0xffeff6ff)
    },
    {
      'title': 'Kandang',
      'subtitle': 'Status Fasilitas',
      'icon': Icons.home_outlined,
      'color': Colors.orange,
      'bg': const Color(0xfffff7ed)
    },
    {
      'title': 'Gudang',
      'subtitle': 'Stok Pakan',
      'icon': Icons.inventory_2,
      'color': Colors.green,
      'bg': const Color(0xffecfdf5)
    },
    {
      'title': 'Medis',
      'subtitle': 'Kesehatan',
      'icon': Icons.medical_services_outlined,
      'color': Colors.purple,
      'bg': const Color(0xfff5f3ff)
    },
    {
      'title': 'Laboratorium',
      'subtitle': 'Hasil Uji Lab',
      'icon': Icons.science_outlined,
      'color': Colors.red,
      'bg': const Color(0xffeef2ff)
    },
  ];

  // ---------------- FIREBASE DATA ----------------
  Future<Map<String, dynamic>> loadStats() async {
    final peternakSnapshot =
        await FirebaseFirestore.instance.collection('peternak').get();
    final kandangSnapshot =
        await FirebaseFirestore.instance.collection('kandang').get();
    final pemeriksaanSnapshot =
        await FirebaseFirestore.instance.collection('pemeriksaan').get();
    final gudangSnapshot =
        await FirebaseFirestore.instance.collection('gudang').get();
    final labSnapshot =
        await FirebaseFirestore.instance.collection('pemeriksaan_sampel').get();

    int totalTernak = 0;
    for (var doc in peternakSnapshot.docs) {
      totalTernak += (doc['jumlahTernak'] ?? 0) as int;
    }

    double pertumbuhan = (totalTernak +
            kandangSnapshot.size +
            pemeriksaanSnapshot.size +
            gudangSnapshot.size +
            labSnapshot.size) /
        5;

    return {
      'peternak': totalTernak,
      'kandang': kandangSnapshot.size,
      'pemeriksaan': pemeriksaanSnapshot.size,
      'gudang': gudangSnapshot.size,
      'laboratorium': labSnapshot.size,
      'pertumbuhan': pertumbuhan.toStringAsFixed(1),
    };
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopNav(context),
              const SizedBox(height: 24),
              _buildHeroSection(username),
              const SizedBox(height: 32),

              _buildSectionHeader(title: "Layanan Cepat"),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                itemCount: menuItems.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) => MenuCard(item: menuItems[i]),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(title: "Ringkasan Data Harian"),
              const SizedBox(height: 18),

              FutureBuilder(
                future: loadStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data as Map<String, dynamic>;

                  final List<Map<String, dynamic>> stats = [
                    {
                      'label': 'Total Ternak',
                      'value': data['peternak'].toString(),
                      'trend': 'Aktif',
                      'up': true,
                      'icon': Icons.people_alt,
                      'color': Colors.pinkAccent
                    },
                    {
                      'label': 'Kandang Terisi',
                      'value': data['kandang'].toString(),
                      'trend': 'Fasilitas',
                      'up': true,
                      'icon': Icons.home_outlined,
                      'color': Colors.lightBlue
                    },
                    {
                      'label': 'Pemeriksaan',
                      'value': data['pemeriksaan'].toString(),
                      'trend': 'Data Medis',
                      'up': true,
                      'icon': Icons.monitor_heart,
                      'color': kPrimaryColor
                    },
                    {
                      'label': 'Gudang',
                      'value': data['gudang'].toString(),
                      'trend': 'Stok Masuk',
                      'up': true,
                      'icon': Icons.inventory_2,
                      'color': Colors.green
                    },
                    {
                      'label': 'Laboratorium',
                      'value': data['laboratorium'].toString(),
                      'trend': 'Sampel Masuk',
                      'up': true,
                      'icon': Icons.science_outlined,
                      'color': Colors.red
                    },
                    {
                      'label': 'Pertumbuhan',
                      'value': data['pertumbuhan'].toString(),
                      'trend': 'Rata-rata',
                      'up': true,
                      'icon': Icons.trending_up,
                      'color': Colors.green
                    },
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: stats.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.25,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (_, i) =>
                        StatCardAnimated(stats: stats[i]),
                  );
                },
              ),

              const SizedBox(height: 32),
              _buildChartCard(),

              const SizedBox(height: 32),
              _buildContactSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- COMPONENTS ----------------

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.energy_savings_leaf, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text("SmartFarm",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              )),
        ]),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationClientUI()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(username: username)),
                );
              },
              child: CircleAvatar(
                backgroundColor: kPrimaryColor.withValues(alpha: .15),
                child: Text(
                  getInitials(username),
                  style: const TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(String name) {
    final now = DateTime.now();
    final List<String> bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dateLabel =
        "${now.day} ${bulan[now.month]} ${now.year}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(60, 255, 0, 0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("User Dashboard",
                  style: TextStyle(fontSize: 11, color: Colors.black)),
            ),
            const SizedBox(width: 6),
            const Text("•",
                style: TextStyle(color: Color.fromARGB(137, 0, 0, 0))),
            const SizedBox(width: 6),
            Text(dateLabel,
                style: const TextStyle(
                    fontSize: 11, color: Color.fromARGB(137, 0, 0, 0))),
          ]),
          const SizedBox(height: 12),
          Text("Halo, $name 👋",
              style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text(
            "Pantau perkembangan ternak.",
            style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, String? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.bold)),
        if (action != null)
          Text(action, style: TextStyle(fontSize: 14, color: kPrimaryColor))
      ],
    );
  }

  // ------------------- CHART -----------------------

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Grafik Pertumbuhan",
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const SizedBox(height: 250, child: _LineChartWidget()),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Kontak Kami",
            style:
               GoogleFonts.inter(
            fontSize: 22,
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,   
          )
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            "Hubungi kami untuk informasi lebih lanjut",
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),

        const SizedBox(height: 20),

        _contactCard(
          icon: Icons.email_outlined,
          title: "Email",
          subtitle: "peternakan@example.com",
          iconColor: Colors.purple,
          bgColor: const Color(0xfff5f3ff),
        ),

        _contactCard(
          icon: Icons.location_on_outlined,
          title: "Alamat",
          subtitle: "Jl. Merdeka No. 123, Ternate",
          iconColor: Colors.orange,
          bgColor: const Color(0xfffff7ed),
        ),

        const SizedBox(height: 10),
        Center(
          child: Text("Kontak Lainnya",
              style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 12),

        FutureBuilder(
          future: loadKontakLainnya(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final kontak = snapshot.data as List<Map<String, dynamic>>;

            return Column(
              children: kontak.map((k) {
                return _contactCard(
                  icon: Icons.person_outline,
                  title: k['nama'],
                  subtitle: "${k['noHp']}\n${k['alamat']}",
                  iconColor: Colors.teal,
                  bgColor: const Color(0xffe0f7f4),
                );
              }).toList(),
            );
          },
        ),


        const SizedBox(height: 18),

        _buildJamOperasionalCard(),
      ],
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJamOperasionalCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 10, 69, 186), Color(0xff3b82f6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.access_time, color: Colors.white),
              SizedBox(width: 8),
              Text("Jam Operasional",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          _jamRow("Senin - Jumat", "08:00 - 16:00"),
          const SizedBox(height: 6),
          _jamRow("Sabtu", "08:00 - 12:00"),
          const SizedBox(height: 6),
          _jamRow("Minggu & Hari Libur", "Tutup"),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.lightbulb, color: Colors.yellowAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Kami melayani konsultasi di luar jam operasional melalui WhatsApp",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jamRow(String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(time,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
  
// -----------------------------------------------------------
// CHART WIDGET TERPISAH (PERBAIKAN)
// -----------------------------------------------------------

class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget();

  Future<Map<String, dynamic>> loadStats() async {
    // Fungsi ini tetap sama, hanya mengambil data count dari Firestore
    final peternakSnapshot =
        await FirebaseFirestore.instance.collection('peternak').get();
    final kandangSnapshot =
        await FirebaseFirestore.instance.collection('kandang').get();
    final pemeriksaanSnapshot =
        await FirebaseFirestore.instance.collection('pemeriksaan').get();
    final gudangSnapshot =
        await FirebaseFirestore.instance.collection('gudang').get();
    final labSnapshot =
        await FirebaseFirestore.instance.collection('pemeriksaan_sampel').get();

    int totalTernak = 0;
    for (var doc in peternakSnapshot.docs) {
      totalTernak += (doc['jumlahTernak'] ?? 0) as int;
    }

    return {
      'peternak': totalTernak,
      'kandang': kandangSnapshot.size,
      'pemeriksaan': pemeriksaanSnapshot.size,
      'gudang': gudangSnapshot.size,
      'laboratorium': labSnapshot.size,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as Map<String, dynamic>;

        // Titik data untuk grafik (X: 1-5, Y: Nilai dari Firestore)
        final spots = [
          FlSpot(1, (data['peternak'] ?? 0).toDouble()), // Ternak
          FlSpot(2, (data['kandang'] ?? 0).toDouble()), // Kandang
          FlSpot(3, (data['pemeriksaan'] ?? 0).toDouble()), // Medis (Pemeriksaan)
          FlSpot(4, (data['gudang'] ?? 0).toDouble()), // Gudang
          FlSpot(5, (data['laboratorium'] ?? 0).toDouble()), // Laboratorium
        ];
        
        // --- LOGIKA PERBAIKAN SKALA Y ---
        final maxYValue = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        
        // Menentukan batas atas (maxY) yang rapi
        double roundedMaxY;
        if (maxYValue == 0) {
          roundedMaxY = 10.0; // Default jika semua data 0
        } else if (maxYValue < 5) {
          roundedMaxY = 5.0; 
        } else if (maxYValue <= 25) {
          roundedMaxY = (maxYValue / 5).ceil() * 5.0; // Kelipatan 5
        } else {
          roundedMaxY = (maxYValue / 10).ceil() * 10.0; // Kelipatan 10
        }

        // Pastikan batas atas minimal 10% lebih besar dari nilai tertinggi
        if (roundedMaxY <= maxYValue) {
            if (maxYValue <= 25) {
              roundedMaxY += 5.0;
            } else {
              roundedMaxY += 10.0;
            }
        }
        
        final double finalMaxY = roundedMaxY;
        
        // Menghitung interval yang rapi untuk 4-5 garis grid horizontal
        final double finalInterval = (finalMaxY / 4).floorToDouble().clamp(1, double.infinity); 
        return LineChart(
          LineChartData(
            minY: 0,
            maxY: finalMaxY, // Menggunakan maxY yang sudah dibulatkan
            minX: 0.5, // Memberi sedikit padding di kiri dan kanan
            maxX: 5.5,

            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipColor: (_) => Colors.black.withValues(alpha: 0.8), // Warna tooltip gelap lebih kontras
                getTooltipItems: (items) {
                  return items
                      .map(
                        (e) => LineTooltipItem(
                          // Menampilkan nilai integer
                          "${e.y.toInt()}", 
                          const TextStyle(
                              color: Colors.white, // Teks tooltip putih
                              fontWeight: FontWeight.bold),
                        ),
                      )
                      .toList();
                },
              ),
            ),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: finalInterval, // Menggunakan interval yang sudah dihitung
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              ),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Colors.grey.shade400, width: 1.5),
                bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
                right: BorderSide.none,
                top: BorderSide.none,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                axisNameWidget: Text("Jumlah Data", style: TextStyle(fontSize: 10, color: Colors.grey)),
                axisNameSize: 18,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: finalInterval, 
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36, 
                  interval: 1, 
                  getTitlesWidget: (value, meta) {
                    const List<String> xAxisLabels = ["Ternak", "Kandang", "Medis", "Gudang", "Lab"];
                    
                    String label = "";
                    int index = value.toInt() - 1; 

                    if (index >= 0 && index < xAxisLabels.length) {
                        label = xAxisLabels[index];
                    } else {
                        return const SizedBox(); 
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: kPrimaryColor,
                dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: kPrimaryColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.2), // Opasitas lebih tinggi
                      kPrimaryColor.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------
// MENU CARD
// -----------------------------------------------------------

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          switch (item['title']) {
            case 'Peternak':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DataPeternakUser()));
              break;
            case 'Karyawan':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UserKaryawanPage()));
              break;
            case 'Kandang':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => KandangUserPage()));
              break;
            case 'Gudang':
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => GudangPage()));
              break;
            case 'Medis':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MedisUserPage()));
              break;
            case 'Laboratorium':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LaboratoriumUserPage()));
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item['bg'],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item['icon'], color: item['color'], size: 36),
              ),
              const SizedBox(height: 10),
              Text(item['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(item['subtitle'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// STAT CARD
// -----------------------------------------------------------

class StatCardAnimated extends StatefulWidget {
  final Map<String, dynamic> stats;

  const StatCardAnimated({super.key, required this.stats});

  @override
  State<StatCardAnimated> createState() => _StatCardAnimatedState();
}

class _StatCardAnimatedState extends State<StatCardAnimated> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovering ? kPrimaryColor : Colors.grey.shade200,
            width: _isHovering ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.stats['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.stats['icon'],
                      size: 20, color: widget.stats['color']),
                ),
                _buildTrendBadge(widget.stats),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.stats['label'],
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(widget.stats['value'],
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(Map<String, dynamic> s) {
    final bool up = s['up'] == true;

    Color trendTextColor =
        up ? const Color.fromARGB(255, 0, 0, 0) : Colors.red.shade700;
    Color trendBg = up ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: trendBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(
            up ? Icons.trending_up : Icons.trending_down,
            size: 10,
            color: trendTextColor,
          ),
          const SizedBox(width: 4),
          Text(
            s['trend'],
            style: TextStyle(
                fontSize: 10,
                color: trendTextColor,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}