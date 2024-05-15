import 'dart:io';
import 'dart:typed_data';
import 'package:pyview/pyview/basic/operations.dart';
import 'package:image/image.dart' as img;
import 'package:pyview/pyview/enchanment/operations.dart';
import 'package:pyview/pyview/morphological/operations.dart';
import 'package:pyview/pyview/noise/operations.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:pyview/pyview/transformation/operations.dart';
import 'package:pyview/pyview/utility/operations.dart';

Future<void> main() async {
  PyImage? image = await  decodePyImageFile("assets/pf.jpg");
  List<List<double>> kernel = [[1/9, 1/9, 1/9],
                            [1/9, 1/9, 1/9],
                            [1/9, 1/9, 1/9]];
  PyImage? resized = PrewittOperation().execute(GrayScaleOperation().execute(image!));
  PyImage? saltPepperImage = SaltPepperOperation(whiteProbablity: 0.05, blackProbablity: 0.05).execute(resized!);
  PyImage? meanImage = MedianFilter(kernelSize: 3).execute(saltPepperImage!);
  PyImage? ctimg = ConcatImage(firstImage: saltPepperImage).execute(meanImage!);
  PyImage? addedImage = AddOperation(firstImage: saltPepperImage).execute(meanImage!);
  PyImage? divideImage = DivideImage(firstImage: resized).execute(meanImage!);
  
  await File("assets/pf_salt.png").writeAsBytes(Uint8List.fromList(img.encodePng(saltPepperImage!)));
  await File("assets/pf_mean.png").writeAsBytes(Uint8List.fromList(img.encodePng(meanImage!)));
  await File("assets/pf_gray.png").writeAsBytes(Uint8List.fromList(img.encodePng(resized!)));
  await File("assets/pf_concat.png").writeAsBytes(Uint8List.fromList(img.encodePng(ctimg!)));
  await File("assets/pf_add.png").writeAsBytes(Uint8List.fromList(img.encodePng(addedImage!)));
  await File("assets/pf_divide.png").writeAsBytes(Uint8List.fromList(img.encodePng(divideImage!)));
}