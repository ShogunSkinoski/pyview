import 'dart:math';

import 'package:pyview/pyview/image_operation_i.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;

class DilationOperation implements IImageOperation {
  late List<List<int>> kernel;
  DilationOperation(
      {this.kernel = const [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
      ]});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;

    PyImage dilateImage = PyImage(width: width, height: height);

    for (int i = 0; i < image.width; i++) {
      for (int j = 0; j < image.height; j++) {
        int maxRedPixel = 0;
        int maxGreenPixel = 0;
        int maxBluePixel = 0;
        for (int k = 0; k < kernel.length; k++) {
          for (int l = 0; l < kernel[k].length; l++) {
            int x = i + l - kernel.length ~/ 2;
            int y = j + k - kernel[k].length ~/ 2;
            if (x >= 0 && x < width && y >= 0 && y < height) {
              int redPixel = image.getPixel(x, y).r.toInt();
              int greenPixel = image.getPixel(x, y).g.toInt();
              int bluePixel = image.getPixel(x, y).b.toInt();
              maxRedPixel = max(maxRedPixel, redPixel);
              maxGreenPixel = max(maxGreenPixel, greenPixel);
              maxBluePixel = max(maxBluePixel, bluePixel);
            }
          }
        }
        dilateImage.setPixel(
            i, j, img.ColorRgb8(maxRedPixel, maxGreenPixel, maxBluePixel));
      }
    }
    return dilateImage;
  }

  @override
  String toString() {
    return 'Apply Dilation with {kernel: $kernel}';
  }
}

class ErosionOperation implements IImageOperation {
  late List<List<int>> kernel;
  ErosionOperation(
      {this.kernel = const [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
      ]});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;

    PyImage erodeImage = PyImage(width: width, height: height);

    for (int i = 0; i < image.width; i++) {
      for (int j = 0; j < image.height; j++) {
        int minRedPixel = 255;
        int minGreenPixel = 255;
        int minBluePixel = 255;
        for (int k = 0; k < kernel.length; k++) {
          for (int l = 0; l < kernel[k].length; l++) {
            int x = i + k - kernel.length ~/ 2;
            int y = j + l - kernel[k].length ~/ 2;
            if (x >= 0 && x < width && y >= 0 && y < height) {
              int redPixel = image.getPixel(x, y).r.toInt();
              int greenPixel = image.getPixel(x, y).g.toInt();
              int bluePixel = image.getPixel(x, y).b.toInt();
              minRedPixel = min(minRedPixel, redPixel);
              minGreenPixel = min(minGreenPixel, greenPixel);
              minBluePixel = min(minBluePixel, bluePixel);
            }
          }
        }
        erodeImage.setPixel(
            i, j, img.ColorRgb8(minRedPixel, minGreenPixel, minBluePixel));
      }
    }
    return erodeImage;
  }

  @override
  String toString() {
    return 'Apply Erosion with {kernel: $kernel}';
  }
}

class OpeningOperation implements IImageOperation {
  late List<List<int>> kernel;
  OpeningOperation(
      {this.kernel = const [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
      ]});
  @override
  PyImage execute(PyImage image) {
    PyImage erodeImage = ErosionOperation(kernel: kernel).execute(image);
    PyImage openImage = DilationOperation(kernel: kernel).execute(erodeImage);
    return openImage;
  }

  @override
  String toString() {
    return 'Apply Opening with {kernel: $kernel}';
  }
}

class ClosingOperation implements IImageOperation {
  late List<List<int>> kernel;
  ClosingOperation(
      {this.kernel = const [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
      ]});
  @override
  PyImage execute(PyImage image) {
    PyImage dilateImage = DilationOperation(kernel: kernel).execute(image);
    PyImage closeImage = ErosionOperation(kernel: kernel).execute(dilateImage);
    return closeImage;
  }

  @override
  String toString() {
    return 'Apply Closing with {kernel: $kernel}';
  }
}
