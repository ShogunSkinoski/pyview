import 'package:pyview/pyview/image_operation_i.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class SaltPepperOperation implements IImageOperation {
  late double whiteProbablity;
  late double blackProbablity;

  SaltPepperOperation(
      {this.whiteProbablity = 0.05, this.blackProbablity = 0.05});
  @override
  PyImage execute(PyImage image) {
    Random random = Random();
    PyImage? saltPepperImage =
        PyImage(width: image.width, height: image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (random.nextDouble() < blackProbablity) {
          saltPepperImage.setPixel(x, y, img.ColorRgb8(0, 0, 0));
        } else if (random.nextDouble() < whiteProbablity) {
          saltPepperImage.setPixel(x, y, img.ColorRgb8(255, 255, 255));
        } else {
          saltPepperImage.setPixel(
              x,
              y,
              img.ColorRgb8(
                  image.getPixel(x, y).r.toInt(),
                  image.getPixel(x, y).g.toInt(),
                  image.getPixel(x, y).b.toInt()));
        }
      }
    }
    return saltPepperImage;
  }

  @override
  String toString() {
    return """
        Apply salt and pepper noise to the image.

        Args:
            white_probability: $whiteProbablity.
            black_probability: $blackProbablity.
        """;
  }
}

class MeanFilter implements IImageOperation {
  late int kernelSize;
  MeanFilter({this.kernelSize = 3});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;
    PyImage meanImage = PyImage(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int redSum = 0;
        int greenSum = 0;
        int blueSum = 0;
        for (int i = 0; i < kernelSize; i++) {
          for (int j = 0; j < kernelSize; j++) {
            int x1 = x + i - kernelSize ~/ 2;
            int y1 = y + j - kernelSize ~/ 2;
            if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height) {
              redSum += image.getPixel(x1, y1).r.toInt();
              greenSum += image.getPixel(x1, y1).g.toInt();
              blueSum += image.getPixel(x1, y1).b.toInt();
            }
          }
        }
        meanImage.setPixel(
            x,
            y,
            img.ColorRgb8(
                (redSum / (kernelSize * kernelSize)).toInt(),
                (greenSum / (kernelSize * kernelSize)).toInt(),
                (blueSum / (kernelSize * kernelSize)).toInt()));
      }
    }
    return meanImage;
  }

  @override
  String toString() {
    return "Apply Mean Filter with {kernelSize: $kernelSize}";
  }
}

class MedianFilter implements IImageOperation {
  late int kernelSize;
  MedianFilter({this.kernelSize = 3});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;
    PyImage medianImage = PyImage(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        List<int> redValues = [];
        List<int> greenValues = [];
        List<int> blueValues = [];
        for (int i = 0; i < kernelSize; i++) {
          for (int j = 0; j < kernelSize; j++) {
            int x1 = x + i - kernelSize ~/ 2;
            int y1 = y + j - kernelSize ~/ 2;
            if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height) {
              redValues.add(image.getPixel(x1, y1).r.toInt());
              greenValues.add(image.getPixel(x1, y1).g.toInt());
              blueValues.add(image.getPixel(x1, y1).b.toInt());
            }
          }
        }
        redValues.sort();
        greenValues.sort();
        blueValues.sort();
        medianImage.setPixel(
            x,
            y,
            img.ColorRgb8(
                redValues[(redValues.length - 1) ~/ 2],
                greenValues[(greenValues.length - 1) ~/ 2],
                blueValues[(blueValues.length - 1) ~/ 2]));
      }
    }
    return medianImage;
  }

  @override
  String toString() {
    return """
        Apply a median filter to the image.

        Args:
            kernel_size: $kernelSize.
        """;
  }
}
