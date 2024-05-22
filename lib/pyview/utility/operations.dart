import 'dart:math';

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

class HSVOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    PyImage? hsvImage = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      double r = pixel.r / 255;
      double g = pixel.g / 255;
      double b = pixel.b / 255;
      double cmax = [r, g, b].reduce((value, element) => max(value, element));
      double cmin = [r, g, b].reduce((value, element) => min(value, element));
      double delta = cmax - cmin;
      double h = 0;
      if (delta == 0) {
        h = 0;
      } else if (cmax == r) {
        h = 60 * (((g - b) / delta) % 6);
      } else if (cmax == g) {
        h = 60 * ((b - r) / delta + 2);
      } else if (cmax == b) {
        h = 60 * ((r - g) / delta + 4);
      }
      h = h.isNaN ? 0 : h; // Handle NaN case
      double s = cmax == 0 ? 0 : delta / cmax;
      double v = cmax;
      int hue = (h * 255 / 360).round().clamp(0, 255).toInt();
      int saturation = (s * 255).round().clamp(0, 255).toInt();
      int value = (v * 255).round().clamp(0, 255).toInt();
      hsvImage.setPixel(
          pixel.x, pixel.y, img.ColorRgb8(hue, saturation, value));
    }
    return hsvImage;
  }

  @override
  String toString() {
    return "Convert to HSV";
  }
}

class YCbCrOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    PyImage? ycbcrImage = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      double r = pixel.r / 255;
      double g = pixel.g / 255;
      double b = pixel.b / 255;

      // Convert to YCbCr
      double y = 0.299 * r + 0.587 * g + 0.114 * b;
      double cb = -0.168736 * r - 0.331264 * g + 0.5 * b; // Range [-0.5, 0.5]
      double cr = 0.5 * r - 0.418688 * g - 0.081312 * b; // Range [-0.5, 0.5]

      // Scale to [0, 255]
      int yValue = (y * 255).round().clamp(0, 255).toInt();
      int cbValue = ((cb + 0.5) * 255).round().clamp(0, 255).toInt();
      int crValue = ((cr + 0.5) * 255).round().clamp(0, 255).toInt();

      ycbcrImage.setPixel(
          pixel.x, pixel.y, img.ColorRgb8(yValue, cbValue, crValue));
    }
    return ycbcrImage;
  }

  @override
  String toString() {
    return "Convert to YCbCr";
  }
}

class CMYOOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    PyImage? cmyoImage = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      double r = pixel.r / 255;
      double g = pixel.g / 255;
      double b = pixel.b / 255;

      // Convert to CMYO
      double c = 1 - r;
      double m = 1 - g;
      double y = 1 - b;
      double o = min(c, min(m, y)); // Calculate the O (black) component

      // Scale to [0, 255]
      int cValue = (c * 255).round().clamp(0, 255).toInt();
      int mValue = (m * 255).round().clamp(0, 255).toInt();
      int yValue = (y * 255).round().clamp(0, 255).toInt();
      int oValue = (o * 255).round().clamp(0, 255).toInt();

      cmyoImage.setPixel(
          pixel.x, pixel.y, img.ColorRgba8(cValue, mValue, yValue, oValue));
    }
    return cmyoImage;
  }

  @override
  String toString() {
    return "Convert to CMYO";
  }
}
