import 'package:conductor/native/bridge_generated.dart';
import 'package:conductor/native/speaker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

class Discovery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  List<Speaker> speakers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // list
            // ListView.builder(
            //   itemCount: speakers.length,
            //   itemBuilder: (ctx, i) =>,
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Isolate.spawn((message) async {
      for (var i = 0; i < 5; i++) {
        var s = await Speaker.create("192.168.0.4");
        while (!await s.isConnected()) {
          print("not connected");
          await s.connect();
        }
        print("connected");
      }
    }, null);
  }
}
