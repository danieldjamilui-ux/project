    import 'dart:io';
    import 'package:flutter/material.dart';
    import 'package:image_picker/image_picker.dart';
    import 'package:permission_handler/permission_handler.dart';
    import '../../models/gudang.dart';
    import '../../service/firestore_service.dart';
    import '../../service/cloudinary_service.dart';

    class GudangScreen extends StatefulWidget {
      const GudangScreen({super.key});

      @override
      State<GudangScreen> createState() => _GudangScreenState();
    }

    class _GudangScreenState extends State<GudangScreen> {
      final firestore = FirestoreService();
      final CloudinaryService cloudinaryService = CloudinaryService();

      final TextEditingController _search = TextEditingController();
      final namaC = TextEditingController();
      final pengurusC = TextEditingController();
      final lokasiC = TextEditingController();
      final ukuranC = TextEditingController();

      String searchQuery = "";
      File? selectedImage;

      Future<bool> _requestPermission() async {
        var photo = await Permission.photos.request();
        var storage = await Permission.storage.request();
        return photo.isGranted || storage.isGranted;
      }

      Future<void> _pickImage() async {
        bool ok = await _requestPermission();
        if (!ok) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Izin diperlukan")));
          return;
        }

        final XFile? img =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        if (img != null) {
          setState(() => selectedImage = File(img.path));
        }
      }

      Future<void> _addGudang() async {
        if (selectedImage == null ||
            namaC.text.isEmpty ||
            pengurusC.text.isEmpty ||
            lokasiC.text.isEmpty ||
            ukuranC.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Semua data wajib diisi")));
          return;
        }

        final imageUrl = await cloudinaryService.uploadImage(selectedImage!);

        final g = Gudang(
          id: "",
          nama: namaC.text,
          pengurus: pengurusC.text,
          lokasi: lokasiC.text,
          ukuran: ukuranC.text,
          imagePath: imageUrl,
          createdAt: DateTime.now(),
        );

        await firestore.addGudang(g);

        Navigator.pop(context);
        _clearForm();
      }

      void _clearForm() {
        selectedImage = null;
        namaC.clear();
        pengurusC.clear();
        lokasiC.clear();
        ukuranC.clear();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: const Color(0xfff6f6f6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E8B57),
            title: const Text("Inventori Gudang",
                style: TextStyle(color: Colors.white)),
          ),

          body: Column(
            children: [
              _header(),
              _searchBar(),
              _addButton(),
              Expanded(child: _listViewGudang()),
            ],
          ),
        );
      }

      Widget _header() => Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2E8B57),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
            ),
            child: const Text("Kelola stok barang",
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          );

      Widget _searchBar() => Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Cari barang...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );

      Widget _addButton() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _openAddModal,
              icon: const Icon(Icons.add),
              label: const Text("Tambah Barang Baru"),
            ),
          );

      Widget _listViewGudang() {
        return StreamBuilder<List<Gudang>>(
          stream: firestore.getGudangStream(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());

            final list = snap.data!
                .where((g) =>
                    g.nama.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            if (list.isEmpty) {
              return const Center(child: Text("Tidak ada data gudang"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) => _itemGudang(list[i]),
            );
          },
        );
      }

      Widget _itemGudang(Gudang g) => Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                        image: NetworkImage(g.imagePath), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.nama,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Text("Pengurus: ${g.pengurus}",
                          style: const TextStyle(color: Colors.grey)),
                      Text("Lokasi: ${g.lokasi}",
                          style: const TextStyle(color: Colors.grey)),
                      Text("Ukuran: ${g.ukuran}",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );

      void _openAddModal() {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Tambah Gudang",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: selectedImage == null
                          ? const Icon(Icons.add_a_photo, size: 35)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _field("Nama", namaC),
                  _field("Pengurus", pengurusC),
                  _field("Lokasi", lokasiC),
                  _field("Ukuran", ukuranC),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: _addGudang,
                    child: const Text("Simpan",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        );
      }

      Widget _field(String label, TextEditingController c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: c,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      }
    }
