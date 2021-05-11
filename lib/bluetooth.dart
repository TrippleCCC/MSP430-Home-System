import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

Future<BluetoothConnection> startBluetooth(
    Function(Uint8List) onReveive, Function() onDisconnect) async {
  try {
    BluetoothConnection connection =
        await BluetoothConnection.toAddress("98:D3:C1:FD:BF:22");
    print('Connected to the device');

    connection.input.listen((Uint8List data) {
      print('Data incoming: ${data.length}' + data.toString());
      // connection.output.add(data); // Sending data
      if (data != null) onReveive(data);
    }).onDone(() {
      print('Disconnected by remote request');
      onDisconnect();
    });

    return connection;
  } catch (exception) {
    print('Cannot connect, exception occured');
    return null;
  }
}
