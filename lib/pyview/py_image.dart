import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class PyImage extends img.Image {
  PyImage({required int width, required int height})
      : super(width: width, height: height);
}

Future<PyImage?> decodePyImageFile(String path) async {
  img.Image? image = img.decodeImage(await File(path).readAsBytes());
  return PyImage(width: image!.width, height: image.height)..data = image.data;
}

Future<PyImage?> decodePyImageBytes(Uint8List bytes) async {
  img.Image? image = img.decodeImage(bytes);
  return PyImage(width: image!.width, height: image.height)..data = image.data;
}
