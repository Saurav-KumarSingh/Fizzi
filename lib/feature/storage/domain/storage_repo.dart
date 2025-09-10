import 'dart:typed_data';

abstract class StorageRepo{

  //upload profile images on mobile
  Future<String?> uploadProfileImgMobile(String path, String fileName);

  //upload post images on web
  Future<String?> uploadProfileImgWeb(Uint8List fileBytes, String fileName);


  //upload post images on mobile
  Future<String?> uploadPostImgMobile(String path, String fileName);

  //upload post images on web
  Future<String?> uploadPostImgWeb(Uint8List fileBytes, String fileName);
}
