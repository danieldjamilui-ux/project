import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widget/peternak_screen.dart';
import 'widget/karyawan_screen.dart';
import 'widget/kandang_screen.dart';
import 'widget/gudang_screen.dart';
import 'widget/pemeriksaan_screen.dart';
import 'widget/hasil_swab_darah_screen.dart';

import '../Bottomnavigation/bottom_nav_bar.dart';
import '../Bottomnavigation/profile_bottom.dart';
import '../Bottomnavigation/kontak_screen.dart';
import '../Bottomnavigation/jadwal_pakan_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  Map<int, bool> hoverStates = {};

  final List<Map<String, String>> newsList = [
    {'image': 'assets/images/dinaspertanian.jpg', 'title': 'Dinas Pertanian Kota Ternate'},
    {'image': 'assets/images/baganorganisasi.jpg', 'title': 'Struktur Organisasi Dinas Pertanian Kota Ternate'},
    {'image': 'assets/images/RPH.jpg', 'title': 'Fasilitas penyembelihan hewan ternak secara higienis.'},
  ];

  final List<Map<String, dynamic>> menuList = [
    {'title': 'Peternak', 'image': 'assets/images/peternak.jpg', 'color': Color(0xFFE44EFF)},
    {'title': 'Karyawan', 'image': 'assets/images/karyawan.jpg', 'color': Color(0xFF5EB6FF)},
    {'title': 'Kandang', 'image': 'assets/images/diskon.jpg', 'color': Color(0xFFFF8223)},
    {'title': 'Gudang', 'image': 'assets/images/gudang.jpg', 'color': Color(0xFF73FE77)},
    {'title': 'Pemeriksaan', 'image': 'assets/images/pemeriksaan.jpeg', 'color': Color(0xFF6A37B0)},
    {'title': 'Swab Darah', 'image': 'assets/images/RPH.jpg', 'color': Color.fromARGB(255, 255, 0, 0)},
  ];

  final Map<String, Widget> routes = {
    "Peternak": DaftarPeternakScreen(),
    "Karyawan": DaftarKaryawanScreen(),
    "Kandang": KandangScreen(),
    "Gudang": GudangScreen(),
    "Pemeriksaan": PemeriksaanScreen(),
    "Swab Darah": HasilSwabDarahScreen(),
  };

  List<bool> statVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    // Trigger staggered stat animation
    for (int i = 0; i < statVisible.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) setState(() => statVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return JadwalPakanScreen();
      case 2:
        return KontakScreen();
      case 3:
        return ProfilePage();
      default:
        return const Center(child: Text("Belum tersedia"));
    }
  }

  // ======================================================
  // HOME CONTENT
  // ======================================================
  Widget _homeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(),
          SizedBox(height: 22),
          _statSection(),
          SizedBox(height: 20),
          _carousel(),
          SizedBox(height: 20),
          Text("Layanan Utama", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          _menuGrid(),
        ],
      ),
    );
  }

  // ======================================================
  // HEADER WELCOME
  // ======================================================
  Widget _headerCard() {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0)),
      duration: Duration(milliseconds: 600),
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: Offset(0, offset.dy * 100),
          child: AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 600),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBB5BFF), Color(0xFF8A46FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("✨ WELCOME BACK", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            SizedBox(height: 12),
            Text("Hello, ${widget.username.split('@').first} 👋",
                style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Selamat Datang di Aplikasi Peternakan", style: TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // STATISTIK SECTION
  // ======================================================
  Widget _statSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("peternak").snapshots(),
      builder: (_, peternakSnap) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection("kandang").snapshots(),
          builder: (_, kandangSnap) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance.collection("pemeriksaan").snapshots(),
              builder: (_, periksaSnap) {
                if (!peternakSnap.hasData || !kandangSnap.hasData || !periksaSnap.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                int peternak = peternakSnap.data!.docs.length;
                int kandang = kandangSnap.data!.docs.length;
                int periksa = periksaSnap.data!.docs.length;

                final statData = [
                  {"icon": Icons.person, "label": "Peternak", "value": "$peternak", "color": Colors.purple},
                  {"icon": Icons.home, "label": "Kandang", "value": "$kandang", "color": Colors.blue},
                  {"icon": Icons.health_and_safety, "label": "Pemeriksaan", "value": "$periksa", "color": Colors.green},
                  {"icon": Icons.trending_up, "label": "Pertumbuhan", "value": "+12%", "color": Colors.orange},
                ];

                return Column(
                  children: [
                    Row(
                      children: [
                        _animatedStatCard(statData[0], 0),
                        SizedBox(width: 14),
                        _animatedStatCard(statData[1], 1),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        _animatedStatCard(statData[2], 2),
                        SizedBox(width: 14),
                        _animatedStatCard(statData[3], 3),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _animatedStatCard(Map<String, dynamic> data, int index) {
    return Expanded(
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: statVisible[index] ? 1 : 0,
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: data['color'].withOpacity(0.15),
                child: Icon(data['icon'], color: data['color']),
              ),
              SizedBox(height: 18),
              Text(data['label'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(data['value'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // CAROUSEL
  // ======================================================
  Widget _carousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Informasi Terbaru", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Container(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: newsList.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (_, i) => Image.asset(newsList[i]['image']!, fit: BoxFit.cover),
                ),
                _carouselButton(left: true),
                _carouselButton(left: false),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(newsList[_currentIndex]['title']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _carouselButton({required bool left}) {
    return Positioned(
      left: left ? 10 : null,
      right: left ? null : 10,
      top: 80,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 18,
        child: IconButton(
          icon: Icon(left ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios),
          onPressed: () {
            left
                ? _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut)
                : _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
        ),
      ),
    );
  }

  // ======================================================
  // GRID MENU
  // ======================================================
  Widget _menuGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: menuList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        hoverStates.putIfAbsent(i, () => false);
        final item = menuList[i];

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => routes[item['title']]!)),
          child: AnimatedScale(
            scale: hoverStates[i]! ? 1.07 : 1.0,
            duration: Duration(milliseconds: 160),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400),
              builder: (context, value, child) => Opacity(opacity: value, child: child),
              child: MouseRegion(
                onEnter: (_) => setState(() => hoverStates[i] = true),
                onExit: (_) => setState(() => hoverStates[i] = false),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(item['image'], fit: BoxFit.cover),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [item['color'].withOpacity(0.9), item['color'].withOpacity(0.6)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Text(
                            item['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          right: 14,
                          child: Container(
                            padding: EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
