import 'package:pyview/pyview/py_image.dart';
import 'package:pyview/pyview/image_operation_i.dart';
import 'package:image/image.dart' as img;

class ConcatImage implements IImageOperation {
  late PyImage firstImage;
  ConcatImage({required this.firstImage});

  @override
  PyImage execute(PyImage image) {
    int newWidt = firstImage.width + image.width;
    PyImage? addedImage = PyImage(width: newWidt, height: image.height);
    for (var pixel in firstImage) {
      addedImage.setPixel(pixel.x, pixel.y,
          img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
    }
    for (var pixel in image) {
      addedImage.setPixel(pixel.x + firstImage.width, pixel.y,
          img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
    }
    return addedImage;
  }

  @override
  String toString() {
    return "Concatenate Image with first image";
  }
}

class AddOperation implements IImageOperation {
  late PyImage firstImage;
  AddOperation({required this.firstImage});

  @override
  PyImage execute(PyImage image) {
    PyImage? addedImage = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int r =
          (pixel.r.toInt() + firstImage.getPixel(pixel.x, pixel.y).r.toInt())
              .clamp(0, 255);
      int g =
          (pixel.g.toInt() + firstImage.getPixel(pixel.x, pixel.y).g.toInt())
              .clamp(0, 255);
      int b =
          (pixel.b.toInt() + firstImage.getPixel(pixel.x, pixel.y).b.toInt())
              .clamp(0, 255);
      addedImage.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }
    return addedImage;
  }

  @override
  String toString() {
    return "Add Image with first image";
  }
}

class DivideImage implements IImageOperation {
  late PyImage firstImage;
  DivideImage({required this.firstImage});

  @override
  PyImage execute(PyImage image) {
    PyImage? addedImage = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      if (firstImage.getPixel(pixel.x, pixel.y).r.toInt() == 0) {
        addedImage.setPixel(pixel.x, pixel.y, img.ColorRgb8(0, 0, 0));
        continue;
      }
      int r =
          (pixel.r.toInt() ~/ firstImage.getPixel(pixel.x, pixel.y).r.toInt())
              .clamp(0, 255);
      int g =
          (pixel.g.toInt() ~/ firstImage.getPixel(pixel.x, pixel.y).g.toInt())
              .clamp(0, 255);
      int b =
          (pixel.b.toInt() ~/ firstImage.getPixel(pixel.x, pixel.y).b.toInt())
              .clamp(0, 255);
      addedImage.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }
    return addedImage;
  }

  @override
  String toString() {
    return "Divide Image with first image";
  }
}
