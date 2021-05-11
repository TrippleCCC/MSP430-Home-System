import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const int boundary_size = 7;
const int payload_size = 6;
const int max_size = boundary_size * 2 + payload_size;

class Msp430Data {
  String status;
  int temp;
  bool lightIsOn;

  String get msp430Status {
    return status;
  }

  Widget get dataWidget {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.lightBlue,
          boxShadow: []),
      child: DefaultTextStyle(
          style: TextStyle(fontSize: 15, color: Colors.white),
          child: Column(
            children: [
              this.status != null
                  ? Text("Controller Status: ${this.status}")
                  : Container(),
              this.temp != null
                  ? Text("Controller Temp: ${this.temp.toString()}")
                  : Container(),
              this.lightIsOn ? Text("Lights are on!") : Text("Lights are off!")
            ],
          )),
    );
  }

  static int _charsToInt(Uint8List chars) {
    if (chars.length != 4) return 0;
    var ret = 0;
    for (int i = 0; i < 4; i++) {
      int num = chars[i];
      ret += num << (i * 4);
    }
    return ret;
  }

  Msp430Data(Uint8List rawData) {
    var data = rawData.sublist(boundary_size, boundary_size + payload_size);
    // First determine the status of the msp430
    switch (data[0]) {
      case 1:
        this.status = "Normal";
        break;
    }

    this.temp = _charsToInt(data.sublist(1, 5));

    if (data[5] == 1) {
      print("HERERASDSaDADSDADSDADAS");
      this.lightIsOn = true;
    } else {
      this.lightIsOn = false;
    }
  }
}

class StaticSizeDataBuffer {
  Queue buffer = new Queue<int>();

  void add(int newData) {
    this.buffer.addLast(newData);
    if (this.buffer.length > max_size) {
      this.buffer.removeFirst();
    }
  }

  bool get isValid {
    // check if first boundary_size digits are zero
    if (this.buffer.length < max_size) return false;

    var begining = this.buffer.toList().sublist(0, boundary_size);
    var end = this.buffer.toList().sublist(boundary_size + payload_size);
    return listEquals(begining, List.generate(boundary_size, (index) => 0)) &&
        listEquals(end, List.generate(boundary_size, (index) => 0)) &&
        this.buffer.toList()[boundary_size] != 0;
  }

  Msp430Data get data {
    return this.isValid
        ? Msp430Data(Uint8List.fromList(this.buffer.toList()))
        : null;
  }
}
