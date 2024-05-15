import 'package:pyview/pyview/py_image.dart';
import 'package:pyview/pyview/basic/operations.dart';
import 'package:pyview/pyview/image_operation_i.dart';
import 'package:image/image.dart' as img;

class ContrastOperation implements IImageOperation {
  late double contrast;
  ContrastOperation({required this.contrast});
  @override
  PyImage execute(PyImage image) {
    PyImage? contrasted = PyImage(width: image.width, height: image.height);
    for (var pixel in image) {
      int r = (pixel.r.toDouble() * contrast).toInt();
      int g = (pixel.g.toDouble() * contrast).toInt();
      int b = (pixel.b.toDouble() * contrast).toInt();
      contrasted.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }
    return contrasted;
  }
}

class HistogramEqualizationOperation implements IImageOperation {
  @override
  PyImage execute(PyImage image) {
    PyImage? equalized = PyImage(width: image.width, height: image.height);
    List<int> redHistogram = List.filled(256, 0);
    List<int> greenHistogram = List.filled(256, 0);
    List<int> blueHistogram = List.filled(256, 0);

    for (var pixel in image) {
      redHistogram[pixel.r.toInt()]++;
      greenHistogram[pixel.g.toInt()]++;
      blueHistogram[pixel.b.toInt()]++;
    }    

    List<int> redCumulative = List.filled(256, 0);
    List<int> greenCumulative = List.filled(256, 0);
    List<int> blueCumulative = List.filled(256, 0);

    redCumulative[0] = redHistogram[0];
    greenCumulative[0] = greenHistogram[0];
    blueCumulative[0] = blueHistogram[0];


    for (int i = 1; i < 256; i++) {
      redCumulative[i] = redCumulative[i - 1] + redHistogram[i];
      greenCumulative[i] = greenCumulative[i - 1] + greenHistogram[i];
      blueCumulative[i] = blueCumulative[i - 1] + blueHistogram[i];
    }

    List<int> normalizedRed = List.filled(256, 0);
    List<int> normalizedGreen = List.filled(256, 0);
    List<int> normalizedBlue = List.filled(256, 0);

    for (int i = 0; i < 256; i++) {
      normalizedRed[i] = (redCumulative[i] * 255 / (image.width * image.height)).toInt();
      normalizedGreen[i] = (greenCumulative[i] * 255 / (image.width * image.height)).toInt();
      normalizedBlue[i] = (blueCumulative[i] * 255 / (image.width * image.height)).toInt();
    }

    for (var pixel in image) {
      int r = normalizedRed[pixel.r.toInt()];
      int g = normalizedGreen[pixel.g.toInt()];
      int b = normalizedBlue[pixel.b.toInt()];
      equalized.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }

    return equalized;
  }
}

class HistogramStretchingOperation implements IImageOperation{

  @override
  PyImage execute(PyImage image) {
    PyImage? stretched = PyImage(width: image.width, height: image.height);
    int minR = 255;
    int maxR = 0;
    int minG = 255;
    int maxG = 0;
    int minB = 255;
    int maxB = 0;

    for (var pixel in image) {
      if (pixel.r < minR) minR = pixel.r.toInt();
      if (pixel.r > maxR) maxR = pixel.r.toInt();
      if (pixel.g < minG) minG = pixel.g.toInt();
      if (pixel.g > maxG) maxG = pixel.g.toInt();
      if (pixel.b < minB) minB = pixel.b.toInt();
      if (pixel.b > maxB) maxB = pixel.b.toInt();
    }

    for (var pixel in image) {
      int r = ((pixel.r - minR) * 255 / (maxR - minR)).toInt();
      int g = ((pixel.g - minG) * 255 / (maxG - minG)).toInt();
      int b = ((pixel.b - minB) * 255 / (maxB - minB)).toInt();
      stretched.setPixel(pixel.x, pixel.y, img.ColorRgb8(r, g, b));
    }

    return stretched;
  }
}