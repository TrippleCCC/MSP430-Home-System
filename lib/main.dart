import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/decode_data.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetooth.dart';

void main() => runApp(MyApp());

StaticSizeDataBuffer dataBuffer = new StaticSizeDataBuffer();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Home Security',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Home Security'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  BluetoothConnection msp430Connection;
  Timer _timer;
  int remainingTime = 5;
  Msp430Data msp430data;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _attemptAgain() {
    const one_second = const Duration(seconds: 1);
    widget._timer = new Timer.periodic(one_second, (Timer timer) async {
      if (widget.remainingTime == 0 && widget.msp430Connection == null) {
        // Attempt to connect again
        BluetoothConnection new_connection =
            await startBluetooth(onReceive, onDisconnect);
        if (new_connection == null) {
          // Reset Remaining timer
          setState(() {
            widget.remainingTime = 5;
          });
        } else {
          // we got a successfull connection
          timer.cancel();
          setState(() {
            widget.remainingTime = 0;
            widget.msp430Connection = new_connection;
          });
        }
      } else if (widget.remainingTime > 0) {
        setState(() {
          widget.remainingTime--;
        });
      }
    });
  }

  void _onReciveRoutine(Uint8List data) {
    // Check if the current buffer is valid
    var newData = widget.msp430data;
    for (int i = 0; i < data.length; i++) {
      dataBuffer.add(data[i]);
      var completeData = dataBuffer.data;
      if (completeData == null) {
        continue;
      }
      newData = completeData;
    }

    if (newData != widget.msp430data) {
      setState(() {
        widget.msp430data = newData;
      });
    }
  }

  void onReceive(Uint8List data) {
    setState(() {
      _onReciveRoutine(data);
    });
  }

  void sendData(String data) {
    widget.msp430Connection.output.add(Uint8List.fromList([1]));
  }

  void onDisconnect() {
    setState(() {
      widget.msp430Connection = null;
      widget.remainingTime = 5;
      _attemptAgain();
    });
  }

  @override
  void dispose() {
    widget._timer.cancel();
    if (widget.msp430Connection != null) {
      widget.msp430Connection.finish();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    startBluetooth(onReceive, onDisconnect).then((value) {
      if (value == null) {
        // start a timer to connect again
        _attemptAgain();
      } else {
        setState(() {
          widget.msp430Connection = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: widget.msp430Connection == null
            ? Center(
                child: Text(
                    "Reconnecting with MSP430 in ${widget.remainingTime} second(s)..."))
            : ListView(
                children: [
                  Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                          boxShadow: []),
                      child: Column(children: [
                        Text(
                          "Connected to MSP430!",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        Text("Bluetooth Module addr: 98:D3:C1:FD:BF:22",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ])),
                  widget.msp430data != null
                      ? widget.msp430data.dataWidget
                      : Container(),
                  TextButton(
                      onPressed: () {
                        sendData('data');
                      },
                      child: Text("Toggle Onboard Light"))
                ],
              ));
  }
}
