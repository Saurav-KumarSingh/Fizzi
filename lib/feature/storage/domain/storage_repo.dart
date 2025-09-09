import 'dart:typed_data';

abstract class StorageRepo{

  //upload profile images on mobile
  Future<String?> uploadProfileImgMobile(String path, String fileName);

  //upload profile images on mobile
  Future<String?> uploadProfileImgWeb(Uint8List fileBytes, String fileName);
}
