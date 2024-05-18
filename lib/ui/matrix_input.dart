import 'dart:async';

import 'package:flutter/material.dart';

class MatrixInput extends StatefulWidget {
  final int size;
  final void Function(List<List<int>> matrix) onSubmit;

  const MatrixInput({required this.size, required this.onSubmit});

  @override
  _MatrixInputState createState() => _MatrixInputState();
}

class _MatrixInputState extends State<MatrixInput> {
  late List<List<TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.size,
      (_) => List.generate(
        widget.size,
        (_) => TextEditingController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Kernel'),
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 2,
        child: ListView.builder(
          itemCount: widget.size,
          itemBuilder: (context, row) {
            return Row(
              children: List.generate(widget.size, (col) {
                return Expanded(
                  child: TextFormField(
                    controller: controllers[row][col],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            List<List<int>> matrix = [];
            for (int i = 0; i < widget.size; i++) {
              matrix.add([]);
              for (int j = 0; j < widget.size; j++) {
                matrix[i].add(int.tryParse(controllers[i][j].text) ?? 0);
              }
            }
            widget.onSubmit(matrix);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DoubleMatrixInput extends StatefulWidget {
  final int size;
  final void Function(List<List<double>> matrix) onSubmit;

  const DoubleMatrixInput({required this.size, required this.onSubmit});

  @override
  _DoubleMatrixInputState createState() => _DoubleMatrixInputState();
}

class _DoubleMatrixInputState extends State<DoubleMatrixInput> {
  late List<List<TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.size,
      (_) => List.generate(
        widget.size,
        (_) => TextEditingController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Kernel'),
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 2,
        child: ListView.builder(
          itemCount: widget.size,
          itemBuilder: (context, row) {
            return Row(
              children: List.generate(widget.size, (col) {
                return Expanded(
                  child: TextFormField(
                    controller: controllers[row][col],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            List<List<double>> matrix = [];
            for (int i = 0; i < widget.size; i++) {
              matrix.add([]);
              for (int j = 0; j < widget.size; j++) {
                matrix[i].add(double.tryParse(controllers[i][j].text) ?? 0);
              }
            }
            widget.onSubmit(matrix);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
