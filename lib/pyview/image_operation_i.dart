import 'package:image/image.dart' as img;
import 'package:pyview/pyview/py_image.dart';

abstract class IImageOperation {
  PyImage execute(PyImage image);
}