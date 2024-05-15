import 'dart:math';

import 'package:pyview/pyview/image_operation_i.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;

class DilationOperation implements IImageOperation{
  late List<List<int>> kernel;
  DilationOperation({required this.kernel});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;
    
    PyImage dilateImage = PyImage(width: width, height: height);
    
    for(int i = 0; i< image.height; i++){
      for(int j = 0; j < image.width; j++){
        int maxRedPixel = 0;
        int maxGreenPixel = 0;
        int maxBluePixel = 0;
        for(int k = 0; k < kernel.length; k++){
          for(int l = 0; l < kernel[k].length; l++){
            int x = i + k - kernel.length ~/ 2;
            int y = j + l - kernel[k].length ~/ 2;
            if(x >= 0 && x < height && y >= 0 && y < width){
              int redPixel = image.getPixel(x, y).r.toInt();
              int greenPixel = image.getPixel(x, y).g.toInt();
              int bluePixel = image.getPixel(x, y).b.toInt();
              maxRedPixel = max(maxRedPixel, redPixel);
              maxGreenPixel = max(maxGreenPixel, greenPixel);
              maxBluePixel = max(maxBluePixel, bluePixel);
            }
          }
        }
        dilateImage.setPixel(i, j, img.ColorRgb8(maxRedPixel, maxGreenPixel, maxBluePixel));
      }
    }
    return dilateImage;
  }
}

class ErosionOperation implements IImageOperation{
  late List<List<int>> kernel;
  ErosionOperation({this.kernel = const [
    [0, 1, 0],
    [1, 1, 1],
    [0, 1, 0]
  ]});
  @override
  PyImage execute(PyImage image) {
    int width = image.width;
    int height = image.height;
    
    PyImage erodeImage = PyImage(width: width, height: height);
    
    for(int i = 0; i< image.height; i++){
      for(int j = 0; j < image.width; j++){
        int minRedPixel = 255;
        int minGreenPixel = 255;
        int minBluePixel = 255;
        for(int k = 0; k < kernel.length; k++){
          for(int l = 0; l < kernel[k].length; l++){
            int x = i + k - kernel.length ~/ 2;
            int y = j + l - kernel[k].length ~/ 2;
            if(x >= 0 && x < height && y >= 0 && y < width){
              int redPixel = image.getPixel(x, y).r.toInt();
              int greenPixel = image.getPixel(x, y).g.toInt();
              int bluePixel = image.getPixel(x, y).b.toInt();
              minRedPixel = min(minRedPixel, redPixel);
              minGreenPixel = min(minGreenPixel, greenPixel);
              minBluePixel = min(minBluePixel, bluePixel);
            }
          }
        }
        erodeImage.setPixel(i, j, img.ColorRgb8(minRedPixel, minGreenPixel, minBluePixel));
      }
    }
    return erodeImage;
  }
}

class OpeningOperation implements IImageOperation{
  late List<List<int>> kernel;
  OpeningOperation({this.kernel = const [
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
}

class ClosingOperation implements IImageOperation{
  late List<List<int>> kernel;
  ClosingOperation({this.kernel = const [
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
}