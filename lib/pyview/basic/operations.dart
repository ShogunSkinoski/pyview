import 'package:pyview/pyview/image_operation_i.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class GrayScaleOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    PyImage? grayScale = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int avg = ((pixel.r + pixel.g + pixel.b) ~/ 3);
      grayScale.setPixel(pixel.x, pixel.y, img.ColorRgb8(avg, avg, avg));
    }
    return grayScale;
  }

  @override
  String toString() {
    return "Apply GrayScale";
  }
}

class BinaryOperation implements IImageOperation {
  late int threshold;
  BinaryOperation({this.threshold = 128});
  @override
  PyImage execute(PyImage image) {
    PyImage? binary = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int avg = ((pixel.r + pixel.g + pixel.b) ~/ 3);
      if (avg > threshold) {
        binary.setPixel(pixel.x, pixel.y, img.ColorRgb8(255, 255, 255));
      } else {
        binary.setPixel(pixel.x, pixel.y, img.ColorRgb8(0, 0, 0));
      }
    }
    return binary;
  }

  @override
  String toString() {
    return "Apply Binary";
  }
}

class CropOperation implements IImageOperation {
  late int x;
  late int y;
  late int width;
  late int height;
  CropOperation(
      {required this.x,
      required this.y,
      required this.width,
      required this.height});
  @override
  PyImage execute(PyImage image) {
    PyImage? cropped = PyImage(width: width, height: height);
    for (var pixel in image) {
      if (pixel.x >= x &&
          pixel.x < x + width &&
          pixel.y >= y &&
          pixel.y < y + height) {
        cropped.setPixel(pixel.x - x, pixel.y - y,
            img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
      }
    }
    return cropped;
  }

  @override
  String toString() {
    return "Apply Crop at x: $x, y: $y, width: $width, height: $height";
  }
}

class ZoomOperation implements IImageOperation {
  late int scale;
  int? centerX;
  int? centerY;
  ZoomOperation({required this.scale});
  @override
  PyImage execute(PyImage image) {
    if (scale <= 1) return image;
    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;
    PyImage? zoomed = PyImage(width: image.width, height: image.width);

    int cropX =
        (((centerX - image.width / 2) * scale) + image.width / 2).toInt();
    int cropY =
        (((centerY - image.width / 2) * scale) + image.height / 2).toInt();

    for (int y = 0; y < image.width; y++) {
      for (int x = 0; x < image.width; x++) {
        int srcX = (x + cropX) ~/ scale;
        int srcY = (y + cropY) ~/ scale;
        if (srcX >= 0 &&
            srcX < image.width &&
            srcY >= 0 &&
            srcY < image.height) {
          img.Pixel pixel = image.getPixel(srcX, srcY);
          zoomed.setPixel(x, y,
              img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
        }
      }
    }
    return zoomed;
  }

  @override
  String toString() {
    return """
        Zoom the image at the given point.

        Args:
            x: $centerX.
            y: $centerY.
            scale: $scale.
        """;
  }
}

class ResizeOperation implements IImageOperation {
  late double scale;
  ResizeOperation({this.scale = 2});
  @override
  PyImage execute(PyImage image) {
    int newWidth = ((image.width - 1) * scale + 1).toInt();
    int newHeight = ((image.height - 1) * scale + 1).toInt();
    PyImage? resized = PyImage(width: newWidth, height: newHeight);

    List<List<int>> mapping = List.generate(newHeight, (y) {
      return List.generate(newWidth, (x) {
        int srcX = (x / scale).floor();
        int srcY = (y / scale).floor();

        srcX = srcX.clamp(0, image.width - 1);
        srcY = srcY.clamp(0, image.height - 1);
        return srcY * image.width + srcX;
      });
    });

    for (int y = 0; y < newHeight; y++) {
      for (int x = 0; x < newWidth; x++) {
        img.Pixel pixel = image.getPixel(
            mapping[y][x] % image.width, mapping[y][x] ~/ image.height);
        resized.setPixel(x, y,
            img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
      }
    }
    return resized;
  }

  @override
  String toString() {
    return "Apply Resize with scale: $scale";
  }
}

class RotateOperation implements IImageOperation {
  late double angle;
  RotateOperation({this.angle = 90});
  @override
  PyImage execute(PyImage image) {
    double radian = angle * pi / 180;
    PyImage rotated = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      double x = pixel.x - image.width / 2;
      double y = pixel.y - image.height / 2;
      int newX = (x * cos(radian) - y * sin(radian) + image.width / 2).toInt();
      int newY = (x * sin(radian) + y * cos(radian) + image.height / 2).toInt();
      if (newX >= 0 && newX < image.width && newY >= 0 && newY < image.height) {
        rotated.setPixel(newX, newY,
            img.ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
      }
    }
    return rotated;
  }

  @override
  String toString() {
    return "Apply Rotate with angle: $angle";
  }
}
