import 'package:pyview/pyview/py_image.dart';
import 'package:pyview/pyview/image_operation_i.dart';
import 'package:image/image.dart' as img;

class ConvolutionOperation implements IImageOperation {
  late List<List<double>> kernel;
  ConvolutionOperation(
      {this.kernel = const [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1]
      ]});

  @override
  PyImage execute(PyImage image) {
    PyImage? convoluted = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int r = 0;
      int g = 0;
      int b = 0;
      for (int i = 0; i < kernel.length; i++) {
        for (int j = 0; j < kernel[i].length; j++) {
          int x = pixel.x + i - kernel.length ~/ 2;
          int y = pixel.y + j - kernel[i].length ~/ 2;
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            r += (image.getPixel(x, y).r.toInt() * kernel[i][j]).toInt();
            g += (image.getPixel(x, y).g.toInt() * kernel[i][j]).toInt();
            b += (image.getPixel(x, y).b.toInt() * kernel[i][j]).toInt();
          }
        }
      }
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);
      convoluted.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }
    return convoluted;
  }

  @override
  String toString() {
    return "Apply Convolution with {kernel: $kernel}";
  }
}

class PrewittOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    List<List<double>> kernelX = [
      [-1, 0, 1],
      [-1, 0, 1],
      [-1, 0, 1]
    ];
    List<List<double>> kernelY = [
      [-1, -1, -1],
      [0, 0, 0],
      [1, 1, 1]
    ];
    PyImage? convoluted = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int rX = 0;
      int gX = 0;
      int bX = 0;
      int rY = 0;
      int gY = 0;
      int bY = 0;
      for (int i = 0; i < kernelX.length; i++) {
        for (int j = 0; j < kernelX[i].length; j++) {
          int x = pixel.x + i - kernelX.length ~/ 2;
          int y = pixel.y + j - kernelX[i].length ~/ 2;
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            rX += (image.getPixel(x, y).r.toInt() * kernelX[i][j]).toInt();
            gX += (image.getPixel(x, y).g.toInt() * kernelX[i][j]).toInt();
            bX += (image.getPixel(x, y).b.toInt() * kernelX[i][j]).toInt();
            rY += (image.getPixel(x, y).r.toInt() * kernelY[i][j]).toInt();
            gY += (image.getPixel(x, y).g.toInt() * kernelY[i][j]).toInt();
            bY += (image.getPixel(x, y).b.toInt() * kernelY[i][j]).toInt();
          }
        }
      }
      int r = (rX.abs() + rY.abs()).clamp(0, 255);
      int g = (gX.abs() + gY.abs()).clamp(0, 255);
      int b = (bX.abs() + bY.abs()).clamp(0, 255);
      convoluted.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }
    return convoluted;
  }

  @override
  String toString() {
    return "Apply Prewitt Operation";
  }
}
