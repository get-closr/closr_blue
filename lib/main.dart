import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:closr_blue/widgets.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  FlutterBlueApp({Key key, this.title}) : super(key: key);
  final String title;

  _FlutterBlueAppState createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  //Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = Map();
  bool isScanning = false;

  //State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  //Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  @override
  void initState() {
    super.initState();
    _flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        state = s;
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = List<Widget>();
    if (state != BluetoothState.on) {
      tiles.add(_buildAlertTile());
    }
    if (isConnected) {
      tiles.add(_buildDeviceStateTile());
      tiles.addAll(_buildServiceTiles());
    } else {
      tiles.addAll(_buildScanResultTiles());
    }
    return MaterialApp(
      home: Scaffold(
        appBar:
            AppBar(title: Text('Closr Blue'), actions: _buildActionButtons()),
        floatingActionButton: _buildScanningButton(),
        body: Stack(
          children: <Widget>[
            (isScanning) ? _buildProgressBarTile() : Container(),
            ListView(children: tiles),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile() {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }

  Widget _buildDeviceStateTile() {
    return ListTile(
        leading: (deviceState == BluetoothDeviceState.connected)
            ? Icon(Icons.bluetooth_connected)
            : Icon(Icons.bluetooth_disabled),
        title: Text('Device is ${deviceState.toString().split('.')[1]}.'),
        subtitle: Text('${device.id}'),
        trailing: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => _refreshDeviceState(device),
          color: Theme.of(context).iconTheme.color.withOpacity(0.5),
        ));
  }

  List<Widget> _buildServiceTiles() {
    return services.map((s)=> ServiceTile(
      service: s,
      characteristicTiles: s.characteristics.map((c) => CharacteristicTile(
        characteristic: c,
        onReadPressed: () => _readCharacteristic(c),
        onWritePressed: () => _writeCharacteristic(c),
        onNotificationPressed: () => _setNotification(c),
        descriptorTiles: c.descriptors.map((d) => DescriptorTile(
          descriptor:d,
          onReadPressed: () => _readDescriptor(d),
          onWritePressed: () => _writeDescriptor(d),
        ),
        ).toList(),
      ),
      ).toList();
    ));
  }

  Iterable<Widget> _buildScanResultTiles() {
    return scanResults.values.map((r)=> ScanResultTile(
      result: r,
      onTap: () => _connect(r.device),
    )).toList();
  }

  _buildActionButtons() {
    if (isConnected) {
      return <Widget>[
        IconButton(icon: Icon(Icons.cancel), onPressed: ()=> _disconnect(),)
      ];
    }
  }

  _buildScanningButton() {
    if (isConnected || state != BluetoothState.on){
      return null;
    }
    if (isScanning) {
      return FloatingActionButton(
        child: Icon(Icons.stop),
        onPressed: _stopScan,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
        child: Icon(Icons.search), onPressed: _startScan
      );
    }
  }

  _buildProgressBarTile() {
    return LinearProgressIndicator();
  }
}
