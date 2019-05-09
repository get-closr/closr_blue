import 'package:flutter/material.dart';
import 'widgets.dart';

void main() => runApp(ClosrBlue());

class ClosrBlue extends StatefulWidget {
  ClosrBlue({Key key}) : super(key: key);

  _ClosrBlueState createState() => _ClosrBlueState();
}

class _ClosrBlueState extends State<ClosrBlue> {
  double _slider2Val = 0.5;
  bool isConnected = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: false,
        snap: true,
        floating: true,
        expandedHeight: 160,
        flexibleSpace: FlexibleSpaceBar(
          title: Text("Closr Ble Setup"),
        ),
        backgroundColor: Colors.pinkAccent,
        actions: _buildActionsButtons(),
      ),
      SliverFillRemaining(
        child: Column(
          children: <Widget>[
            Text("Checkpoints #1"),
            Text("Checkpoints #2"),
            Text("Checkpoints #3"),
          ExpansionTile(
          title: Text("Closr Body Jewelley 001"),
          leading: Text("-45"),
          trailing: RaisedButton(
            child: Text("Connect"),
            color: Colors.black,
            textColor: Colors.white,
            onPressed: () {
              print("After connecting make tile disappear?");
            },
          ),
          children: <Widget>[
            _buildAdvRow(context, 'Name of value we are interested in!', '45'),
            Divider(height: 20,),
            Slider(
              value: _slider2Val, //use this value as placement for intensity
              min: 0.0,
              max: 100.0,
              divisions: 5,
              label: '${_slider2Val.round()}',
              onChanged: (double value) {
                setState(() => _slider2Val = value);
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.explicit),
              onPressed: (){
                print("TOUCH!!!");
              },
            ),
            Divider(height: 20,)
          ],
        ),
        ExpansionTile(title: Text("Setup pair relationship"),)
      ]),
      ),
    ])));
  }

  _buildActionsButtons() {
    if (isConnected) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.bluetooth),
          onPressed: _disconnect,
        )
      ];
    } else if (!isConnected) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.bluetooth_disabled),
          onPressed: _connect,
        )
      ];
    }
  }

  _connect() {
    print("click to connect to bluetooth device");
  }

  _disconnect() {
    print("click to disconnect bluetooth device");
  }

  _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
              child: Text(
            value,
            style:
                Theme.of(context).textTheme.caption.apply(color: Colors.black),
            softWrap: true,
          ))
        ],
      ),
    );
  }
}
