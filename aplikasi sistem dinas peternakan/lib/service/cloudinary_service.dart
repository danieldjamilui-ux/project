import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "ddmlcj32g";
  final String preset = "flutter_upload";

  Future<String> uploadImage(File image) async {
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final req = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = preset
      ..files.add(await http.MultipartFile.fromPath("file", image.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Upload gagal: $body");
    }

    return jsonDecode(body)["secure_url"];
  }
}
