import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pyview/pyview/py_image.dart';
import 'package:image/image.dart' as img;
import 'package:crop_your_image/crop_your_image.dart';

class InputImage extends StatefulWidget {
  final FileImage? inputImage;
  final void Function() onPressed;
  const InputImage(
      {super.key, required this.inputImage, required this.onPressed});

  @override
  State<InputImage> createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.height / 1.1,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 48, 47, 55),
              width: 4,
            ),
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                widget.onPressed();
              },
              child: Image(
                  image: widget.inputImage ?? AssetImage("assets/1.jpg"),
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      )),
            ),
          ),
        ),
        Positioned(
            right: MediaQuery.of(context).size.height / 3.5,
            child: Text("Input",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: () {
              //open window to select image
              widget.onPressed();
            },
            icon: Icon(
              Icons.camera_alt,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}

class OutputImage extends StatefulWidget {
  final MemoryImage? outputImage;
  const OutputImage({super.key, required this.outputImage});

  @override
  State<OutputImage> createState() => _OutputImageState();
}

class _OutputImageState extends State<OutputImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.height / 1.1,
          decoration: BoxDecoration(
            border:
                Border.all(color: Color.fromARGB(255, 48, 47, 55), width: 4),
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: widget.outputImage != null
                ? Image(
                    image: widget.outputImage!,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                        ))
                : Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ),
        Positioned(
            right: MediaQuery.of(context).size.height / 4,
            child: Text("Output",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.download,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
