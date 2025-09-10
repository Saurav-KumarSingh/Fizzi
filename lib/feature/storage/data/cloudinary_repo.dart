import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fizzi/feature/storage/domain/storage_repo.dart';

class CloudinaryRepo implements StorageRepo {
  static final String cloudName = dotenv.env['CLOUDINARY_DB_NAME']!; // your Cloudinary cloud name
  static final String uploadPreset = dotenv.env['CLOUDINARY_DB_UPLOADPRESET']!; // unsigned preset
  static final String uploadUrl =
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

  //PROFILE PICTURE


  // 📱 mobile platform
  @override
  Future<String?> uploadProfileImgMobile(String path, String fileName) async {
    return await _uploadFile(path, fileName, "profile_images");
  }

  // 🌐 web platform
  @override
  Future<String?> uploadProfileImgWeb(Uint8List fileBytes, String fileName) async {
    return await _uploadBytes(fileBytes, fileName, "profile_images");
  }

  //POST PICTURE

  // 📱 mobile platform
  @override
  Future<String?> uploadPostImgMobile(String path, String fileName) async {
    return await _uploadFile(path, fileName, "post_images");
  }

  // 🌐 web platform
  @override
  Future<String?> uploadPostImgWeb(Uint8List fileBytes, String fileName) async {
    return await _uploadBytes(fileBytes, fileName, "post_images");
  }

  /*
   * HELPER METHODS – to upload files to Cloudinary
   */

  // 📱 mobile platforms (file)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      final file = File(path);

      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder // ✅ organize files like Firebase child()
        ..files.add(await http.MultipartFile.fromPath("file", file.path,
            filename: fileName));

      final response = await request.send();
      final resData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(resData.body);
        return data["secure_url"]; // ✅ similar to getDownloadURL()
      } else {
        print("Cloudinary upload failed: ${resData.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  // 🌐 web platforms (bytes)
  Future<String?> _uploadBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes("file", fileBytes,
            filename: fileName));

      final response = await request.send();
      final resData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(resData.body);
        return data["secure_url"];
      } else {
        print("Cloudinary upload failed: ${resData.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading file (web): $e");
      return null;
    }
  }
}
