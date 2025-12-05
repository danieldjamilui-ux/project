import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/karyawan.dart';
import '../../service/firestore_service.dart';
import '../../service/cloudinary_service.dart';

class DaftarKaryawanScreen extends StatefulWidget {
  const DaftarKaryawanScreen({super.key});

  @override
  State<DaftarKaryawanScreen> createState() => _DaftarKaryawanScreenState();
}

class _DaftarKaryawanScreenState extends State<DaftarKaryawanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  final CloudinaryService _cloudinary = CloudinaryService();

  List<Karyawan> _fullData = [];
  List<Karyawan> _filtered = [];

  bool _showAddForm = false;

  // Form controller
  final TextEditingController _namaC = TextEditingController();
  final TextEditingController _jabatanC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();

  File? _pickedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_runFilter);
  }

  void _runFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _fullData
          .where((k) => k.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleAddForm() {
    setState(() => _showAddForm = !_showAddForm);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      setState(() {
        _pickedImage = File(xFile.path);
      });

      // Upload ke Cloudinary
      try {
        final url = await _cloudinary.uploadImage(_pickedImage!);
        setState(() => _uploadedImageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload Gagal: $e")));
      }
    }
  }

  Future<void> _saveKaryawan() async {
    if (_namaC.text.isEmpty ||
        _jabatanC.text.isEmpty ||
        _emailC.text.isEmpty) {
      return;
    }

    final k = Karyawan(
      id: "",
      nama: _namaC.text,
      jabatan: _jabatanC.text,
      email: _emailC.text,
      avatar: _uploadedImageUrl ?? "assets/avatar.png",
      aktif: true,
    );

    await _service.addKaryawan(k);

    _namaC.clear();
    _jabatanC.clear();
    _emailC.clear();
    _pickedImage = null;
    _uploadedImageUrl = null;

    setState(() => _showAddForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<List<Karyawan>>(
                    stream: _service.getKaryawanStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text("Gagal memuat data"));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      _fullData = snapshot.data!;
                      if (_searchController.text.isEmpty) {
                        _filtered = _fullData;
                      }

                      return _buildList();
                    },
                  ),
                ),
              ],
            ),

            // Slide form
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: _showAddForm ? 0 : -450,
              left: 0,
              right: 0,
              child: _buildAddForm(),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= HEADER =========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0BA4E0), Color(0xff0065C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.white30,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Data Karyawan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _toggleAddForm,
                child: const CircleAvatar(
                  backgroundColor: Colors.white30,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Cari karyawan...",
              filled: true,
              fillColor: Colors.white,
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

  // ========================= LIST =========================
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final k = _filtered[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(k.avatar),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k.nama,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(k.jabatan,
                        style: const TextStyle(color: Colors.grey)),
                    Text(k.email,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await _service.updateKaryawanStatus(k.id, !k.aktif);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: k.aktif
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    k.aktif ? "Aktif" : "Nonaktif",
                    style: TextStyle(
                      color: k.aktif
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========================= FORM TAMBAH =========================
  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tambah Karyawan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Gambar Upload
            Center(
              child: InkWell(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _pickedImage != null ? FileImage(_pickedImage!) : null,
                  child: _pickedImage == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _inputField("Nama", _namaC),
            _inputField("Jabatan", _jabatanC),
            _inputField("Email", _emailC),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveKaryawan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0BA4E0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Simpan",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
