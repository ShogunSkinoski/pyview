import 'dart:io';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:pyview/pyview/image_operation_i.dart';
import 'package:flutter_gemini/src/models/candidates/candidates.dart';

class CodeConverter {
  Map<String, String> codeMap = {
    "python": "```python",
    "dart": "```dart",
    "java": "```java",
    "c": "```c",
    "cpp": "```cpp",
  };
  late final geminiInstance;
  CodeConverter(String apiKey) {
    Gemini.init(apiKey: apiKey);
    geminiInstance = Gemini.instance;
  }

  void convertCode(
      String language, String path, List<IImageOperation> operations) async {
    String code = "";
    String operationString = "Write me a $language code to ";
    String languageExt = "py";

    for (var operation in operations) {
      operationString += operation.toString();
    }
    operationString += " with given path of image as '$path'";
    operationString +=
        " Use the OOP and Clean code principles write a ImageProcessing class";
    operationString +=
        "and save the result image in the same path with the name of output.jpg.";
    Candidates? candidates = await geminiInstance.text(operationString);

    Content content = candidates!.content!;

    for (var item in content.parts!) {
      code += item.text!;
    }

    switch (language) {
      case "python":
        code = convertToPython(code);
        languageExt = "py";
        break;
      case "dart":
        code = convertToDart(code);
        languageExt = "dart";
        break;
      case "java":
        code = convertToJava(code);
        languageExt = "java";
        break;
      case "c":
        code = convertToC(code);
        languageExt = "c";
        break;
      case "cpp":
        code = convertToCpp(code);
        languageExt = "cpp";
        break;
      default:
        code = convertToPython(code);
        break;
    }
    await File("$path/code.$languageExt").writeAsString(code);
  }

  static String convertToPython(String code) {
    code = code.replaceAll("```python", "");
    code = code.replaceAll("```", "");
    return code;
  }

  static String convertToDart(String code) {
    code = code.replaceAll("```dart", "");
    code = code.replaceAll("```", "");
    return code;
  }

  static String convertToJava(String code) {
    code = code.replaceAll("```java", "");
    code = code.replaceAll("```", "");
    return code;
  }

  static String convertToC(String code) {
    code = code.replaceAll("```c", "");
    code = code.replaceAll("```", "");
    return code;
  }

  static String convertToCpp(String code) {
    code = code.replaceAll("```cpp", "");
    code = code.replaceAll("```", "");
    return code;
  }
}
