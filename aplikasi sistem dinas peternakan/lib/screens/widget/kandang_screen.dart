import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/firestore_service.dart';
import '../../service/cloudinary_service.dart';
import '../../models/kandang.dart';
import 'package:permission_handler/permission_handler.dart';

class KandangScreen extends StatefulWidget {
  const KandangScreen({super.key});

  @override
  State<KandangScreen> createState() => _KandangScreenState();
}

class _KandangScreenState extends State<KandangScreen> {
  final _namaController = TextEditingController();
  final _searchController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();
  final CloudinaryService cloudinaryService = CloudinaryService();

  File? pickedImage;
  String searchQuery = "";

  final String fallbackUrl =
      "https://res.cloudinary.com/ddmlcj32g/image/upload/v1700000000/default_kandang.png";

  // ============================
  // FIXED: PERMISSION HANDLER
  // ============================
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      final photosStatus = await Permission.photos.request();

      return storageStatus.isGranted || photosStatus.isGranted;
    }
    return true;
  }

  Future<void> pickImageLocal(Function setStateDialog) async {
    bool allowed = await requestPermission();
    if (!allowed) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setStateDialog(() {
        pickedImage = File(file.path);
      });
    }
  }

  // ============================
  // BOTTOM SHEET TAMBAH DATA
  // ============================
  Future<void> _tambahKandang() async {
    pickedImage = null;
    _namaController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Tambah Kandang",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // FIELD NAMA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Kandang",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // SELECT GAMBAR
                    GestureDetector(
                      onTap: () => pickImageLocal(setStateDialog),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          image: pickedImage != null
                              ? DecorationImage(
                                  image: FileImage(pickedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: pickedImage == null
                            ? const Center(
                                child: Text(
                                  "Tap untuk pilih gambar",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTON SIMPAN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final nama = _namaController.text.trim();
                          if (nama.isEmpty) return;

                          String imageUrl = fallbackUrl;

                          if (pickedImage != null) {
                            imageUrl =
                                await cloudinaryService.uploadImage(pickedImage!);
                          }

                          await firestoreService.addKandang(
                            Kandang(id: '', nama: nama, imagePath: imageUrl),
                          );

                          pickedImage = null;
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      body: Column(
        children: [
          _buildHeader(),
          _buildTambahButton(),
          const SizedBox(height: 12),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffFF5B37), Color(0xffFF1E00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Data Kandang",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text("Monitor kondisi kandang",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: const InputDecoration(
                hintText: "Cari kandang...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _tambahKandang,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffFF7A00), Color(0xffFF0A0A)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 6),
                Text("Tambah Kandang Baru",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<Kandang>>(
      stream: firestoreService.getKandangStream(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!;
        final filtered = data
            .where((k) =>
                k.nama.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("Tidak ada kandang ditemukan."));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            return _buildKandangCard(filtered[i]);
          },
        );
      },
    );
  }

  Widget _buildKandangCard(Kandang k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: DecorationImage(
                image: NetworkImage(k.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Text(
              k.nama,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
