// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pyview/gemini/code_converter.dart';
import 'package:pyview/pyview/basic/operations.dart';
import 'package:pyview/pyview/enchanment/operations.dart';
import 'package:pyview/pyview/image_operation_i.dart';
import 'package:pyview/pyview/morphological/operations.dart';
import 'package:pyview/pyview/noise/operations.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;
import 'package:pyview/pyview/transformation/operations.dart';
import 'package:pyview/pyview/utility/operations.dart';
import 'package:pyview/ui/image_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:pyview/ui/matrix_input.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CodeConverter codeConverter =
      CodeConverter("AIzaSyBcuMK_su_aMuoCP8jjI-lAaNiykyappNU");

  FileImage? inputImage;
  MemoryImage? outputImage;
  Map<String, IImageOperation> operations = {};
  double angle = 0;
  Timer? _debounce;
  double whiteProbablity = 0.05;
  double blackProbablity = 0.05;
  String language = "";
  int zoom = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 17, 15, 26),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            //open menu
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Operations'),
                  content: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 2,
                    child: ListView.builder(
                      itemCount: operations.length,
                      itemBuilder: (context, index) {
                        final operationName = operations.keys.elementAt(index);
                        return ListTile(
                          title: Text(operationName),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                operations.remove(operationName);
                              });
                              Navigator.of(context).pop();
                              _applyOperations();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Clear All'),
                      onPressed: () {
                        setState(() {
                          operations.clear();
                        });
                        Navigator.of(context).pop();
                        _applyOperations();
                      },
                    ),
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 5, 1, 15),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: Container(
                    child: Row(
                      children: [
                        //input image
                        const Spacer(
                          flex: 1,
                        ),
                        InputImage(
                          inputImage: inputImage,
                          onPressed: () {
                            _selectImage(context);
                          },
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        //output image
                        OutputImage(
                          outputImage: outputImage,
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DefaultTabController(
                    length: 6,
                    initialIndex: 0,
                    child: Column(
                      children: [
                        Container(
                          color: Color.fromARGB(255, 17, 15, 26),
                          child: TabBar(
                            isScrollable: false,
                            indicatorColor: Colors.white70,
                            tabAlignment: TabAlignment.fill,
                            labelColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 18,
                            ),
                            unselectedLabelColor: Colors.white,
                            unselectedLabelStyle: TextStyle(
                              fontSize: 18,
                            ),
                            tabs: [
                              _buildTab('🔮'),
                              _buildTab('🔧'),
                              _buildTab('👩‍💻'),
                              _buildTab('✂️'),
                              _buildTab('🔊'),
                              _buildTab('⚙️')
                            ],
                          ),
                        ),
                        Container(
                          color: Color.fromARGB(255, 17, 15, 26),
                          height: MediaQuery.of(context).size.height / 1.15,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TabBarView(children: [
                              _basicOperationPanel(),
                              _enchantmentOperationPanel(),
                              _morphologicalOperationPanel(),
                              _noiseOperationPanel(),
                              _transformationOperationPanel(),
                              _utilityOperationPanel(),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectImage(BuildContext context) {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'Images (*.jpg, *.jpeg, *.png)': '*.jpg;*.jpeg;*.png',
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'jpg'
      ..title = 'Select an image';

    final result = file.getFile();
    if (result != null) {
      setState(() {
        inputImage = FileImage(File(result.path));
        _applyOperations();
      });
    }
  }

  Tab _buildTab(String text) {
    return Tab(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Column _slider(IconData icon, String text, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Slider(
              min: -360,
              max: 360,
              value: angle,
              onChanged: onChanged,
            ),
            Text("${angle.toInt()}",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Column _sliderZoom(IconData icon, String text, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Slider(
              min: 0,
              max: 10,
              value: zoom.toDouble(),
              onChanged: onChanged,
            ),
            Text("${zoom.toInt()}",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Row _operationButton(String icon, String text, Function() onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
        ElevatedButton(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(Size(275, 50)),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                side: BorderSide(
                  color: Color.fromARGB(255, 48, 47, 55),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(
              Color.fromARGB(255, 17, 15, 26),
            ),
          ),
          onPressed: onPressed,
          child: Container(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Column _basicOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _slider(
          Icons.rotate_left,
          "Rotate",
          (value) async {
            operations["rotate"] = RotateOperation(angle: value.ceilToDouble());
            setState(() {
              angle = value.ceilToDouble();
            });
            _debounce?.cancel();
            _debounce = Timer(Duration(milliseconds: 300), () {
              _applyOperations();
            });
          },
        ),
        _sliderZoom(
          Icons.zoom_in,
          "Zoom",
          (value) async {
            operations["zoom"] = ZoomOperation(scale: value.toInt());
            setState(() {
              zoom = value.toInt();
            });
            _debounce?.cancel();
            _debounce = Timer(Duration(milliseconds: 300), () {
              _applyOperations();
            });
          },
        ),
        _operationButton("🐘", "Gray Scale", () {
          _grayScaleOperation();
        }),
        _operationButton("🔲", "Binary Transformation", () {
          _binaryOperation();
        }),
        _operationButton("✂️", "Crop", () {
          _cropOperation();
        })
      ],
    );
  }

  _enchantmentOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: "Contrast",
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            try {
              _contrastOperation(double.parse(value));
            } catch (e) {
              print("Error: $e");
            }
          },
        ),
        _operationButton("📊", "Histogram Equalization", () {
          _histogramEqualizationOperation();
        }),
        _operationButton("🤸🏻‍♂️", "Histogram Stretching", () {
          _histogramStretchingOperation();
        })
      ],
    );
  }

  _morphologicalOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _operationButton("🔱", "Dilation Operation", () {
          _matrixOperation("dilation");
        }),
        _operationButton("🌊", "Erosion Operation", () {
          _matrixOperation("erosion");
        }),
        _operationButton("📖", "Openning Operation", () {
          _matrixOperation("opening");
        }),
        _operationButton("📕", "Closing Operation", () {
          _matrixOperation("closing");
        })
      ],
    );
  }

  _noiseOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 150,
              height: 200,
              child: _buildTextField(
                "White Probability 🧼",
                (value) {
                  setState(() {
                    try {
                      whiteProbablity = double.parse(value);
                    } catch (e) {
                      print("Error: $e");
                    }
                  });
                  operations["saltPepper"] = SaltPepperOperation(
                    whiteProbablity: whiteProbablity,
                    blackProbablity: blackProbablity,
                  );
                  _applyOperations();
                },
              ),
            ),
            SizedBox(
              width: 150,
              height: 200,
              child: _buildTextField("Black Probability 🧼", (value) {
                setState(() {
                  blackProbablity = double.parse(value);
                });
                operations["saltPepper"] = SaltPepperOperation(
                  whiteProbablity: whiteProbablity,
                  blackProbablity: blackProbablity,
                );
                _applyOperations();
              }),
            )
          ],
        ),
        _operationButton("💅", "Mean Filter", () {
          _meanFilterOperation();
        }),
        _operationButton("📈", "Median Filter", () {
          _medianFilterOperation();
        })
      ],
    );
  }

  _transformationOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _operationButton("🔢", "Convolution Operation", () {
          _convolutionMatrixOperation();
        }),
        _operationButton("📐", "Prewitt Operation", () {
          _prewittOperation();
        })
      ],
    );
  }

  _utilityOperationPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _operationButton("➕", "Add Image", () {
          _addImageOperation();
        }),
        _operationButton("➗", "Divide Image", () {
          _divideImageOperation();
        }),
        _operationButton("🔷", "HSV Color Transformation", () {
          operations["hsv"] = HSVOperation();
          _applyOperations();
        }),
        _operationButton("🚀", "YCbCr Color Transformation", () {
          operations["YCbCr"] = YCbCrOperation();
          _applyOperations();
        }),
        _operationButton("🇨", "CMYO Color Transformation", () {
          operations["CMYO"] = CMYOOperation();
          _applyOperations();
        }),
      ],
    );
  }

  Future<void> _applyOperations() async {
    if (inputImage != null) {
      final bytes = await inputImage!.file.readAsBytes();
      try {
        final processedImageData = await compute(
            processImage, {'operations': operations, 'imageData': bytes});
        setState(() {
          outputImage = MemoryImage(processedImageData);
        });
      } catch (e) {
        // Handle error if needed
        print(e.toString());
      }
    }
  }

  void _grayScaleOperation() {
    operations["grayScale"] = GrayScaleOperation();
    _applyOperations();
  }

  void _binaryOperation() {
    operations["binary"] = BinaryOperation();
    _applyOperations();
  }

  void _cropOperation() {
    int? x, y, width, height;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Crop"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 4,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "X",
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      x = int.parse(value);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Y",
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      y = int.parse(value);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Width",
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      width = int.parse(value);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Height",
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      height = int.parse(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                operations["crop"] = CropOperation(
                  x: x!,
                  y: y!,
                  width: width!,
                  height: height!,
                );
                _applyOperations();
                Navigator.of(context).pop();
              },
              child: Text("Crop"),
            ),
          ],
        );
      },
    );
  }

  void _contrastOperation(double contrast) {
    operations["contrast"] = ContrastOperation(contrast: contrast);
    _applyOperations();
  }

  void _histogramEqualizationOperation() {
    operations["histogramEqualization"] = HistogramEqualizationOperation();
    _applyOperations();
  }

  void _histogramStretchingOperation() {
    operations["histogramStretching"] = HistogramStretchingOperation();
    _applyOperations();
  }

  void _matrixOperation(String operation) {
    int? kernelSize;
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Kernel Size'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              kernelSize = int.tryParse(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(kernelSize);
              },
            ),
          ],
        );
      },
    ).then((size) {
      if (size != null) {
        showDialog<List<List<int>>>(
          context: context,
          builder: (BuildContext context) {
            return MatrixInput(
              size: size!,
              onSubmit: (matrix) {
                if (operation == "dilation")
                  operations[operation] = DilationOperation(kernel: matrix);
                else if (operation == "erosion")
                  operations[operation] = ErosionOperation(kernel: matrix);
                else if (operation == "opening")
                  operations[operation] = OpeningOperation(kernel: matrix);
                else if (operation == "closing")
                  operations[operation] = ClosingOperation(kernel: matrix);

                _applyOperations();
              },
            );
          },
        );
      }
    });
  }

  void _convolutionMatrixOperation() {
    int? kernelSize;
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Kernel Size'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              kernelSize = int.tryParse(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(kernelSize);
              },
            ),
          ],
        );
      },
    ).then((size) {
      if (size != null) {
        showDialog<List<List<double>>>(
          context: context,
          builder: (BuildContext context) {
            return DoubleMatrixInput(
              size: size!,
              onSubmit: (matrix) {
                operations["convolution"] =
                    ConvolutionOperation(kernel: matrix);
                _applyOperations();
              },
            );
          },
        );
      }
    });
  }

  void _prewittOperation() {
    operations["prewitt"] = PrewittOperation();
    _applyOperations();
  }

  TextFormField _buildTextField(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  void _meanFilterOperation() {
    operations["meanFilter"] = MeanFilter();
    _applyOperations();
  }

  void _medianFilterOperation() {
    operations["medianFilter"] = MedianFilter();
    _applyOperations();
  }

  void _addImageOperation() async {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'Images (*.jpg, *.jpeg, *.png)': '*.jpg;*.jpeg;*.png',
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'jpg'
      ..title = 'Select an image';

    final result = file.getFile();
    if (result != null) {
      final bytes = File(result.path).readAsBytesSync();
      PyImage? firstImage = await decodePyImageBytes(bytes);
      if (firstImage == null) return;
      setState(() {
        operations["addImage"] = AddOperation(
          firstImage: firstImage!,
        );
        _applyOperations();
      });
    }
  }

  void _divideImageOperation() async {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'Images (*.jpg, *.jpeg, *.png)': '*.jpg;*.jpeg;*.png',
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'jpg'
      ..title = 'Select an image';

    final result = file.getFile();
    if (result != null) {
      final bytes = File(result.path).readAsBytesSync();
      PyImage? firstImage = await decodePyImageBytes(bytes);
      if (firstImage == null) return;
      setState(() {
        operations["divideImage"] = DivideImage(
          firstImage: firstImage!,
        );
        _applyOperations();
      });
    }
  }
}

Future<Uint8List> processImage(Map<String, dynamic> params) async {
  Map<String, IImageOperation> operations = params['operations'];
  Uint8List imageData = params['imageData'];

  PyImage? pyImage = await decodePyImageBytes(imageData);
  if (pyImage != null) {
    operations.forEach((key, value) {
      pyImage = value.execute(pyImage!);
    });
    return Uint8List.fromList(img.encodePng(pyImage!));
  }
  throw Exception("Image processing failed");
}
