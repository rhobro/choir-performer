import 'package:conductor/native/speaker.dart';
import 'package:flutter/material.dart';
import 'package:conductor/native/bridge_generated.dart';

class Discovery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  Map<String, Speaker> speakers = {};

  @override
  Widget build(BuildContext context) {
    var ls = speakers.values.toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            // layout

            // list of devices
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                // border
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: ListView.builder(
                  itemCount: speakers.length,
                  itemBuilder: (ctx, i) => _Item(
                    ls[i],
                    onSelect: () => select(ls[i].ip),
                    isSelected: ls[i].ip == selectedIP,
                  ),
                ),
              ),
            ),

            // toolbar
            Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  selectedIP != null
                      ? _MoreDetails(speakers[selectedIP!]!)
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? selectedIP;

  void select(String ip) => setState(() {
        if (selectedIP != ip) {
          // new selection
          selectedIP = ip;
        } else {
          // deselecting
          selectedIP = null;
        }
      });

  @override
  void initState() {
    super.initState();

    // add sample data
    Future.delayed(Duration(microseconds: 1), () async {
      speakers = {};
      for (var i = 1; i <= 5; i++) {
        speakers["192.168.0.$i"] = await Speaker.create("192.168.0.$i");
        await speakers["192.168.0.$i"]!.connect().then((_) => setState(() {}));
      }
    });
  }
}

class _Item extends StatefulWidget {
  final Speaker x;
  final bool isSelected;
  final VoidCallback onSelect;

  _Item(
    this.x, {
    required this.onSelect,
    this.isSelected = false,
  });

  @override
  State<StatefulWidget> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        // border
        padding: EdgeInsets.only(
          top: 5,
          right: 15,
          bottom: 5,
          left: 5,
        ),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            // darken on selection
            color: widget.isSelected ? Colors.black : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        child: FutureBuilder(
          future: isConnected,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            var isConnected = snapshot.data as bool;

            // get info
            return FutureBuilder(
              future: info,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                var info = snapshot.data as MachineInfo?;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // summarised display

                    // name details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // hostname
                        Text(
                          isConnected ? info!.hostname : "Disconnected",
                          style: TextStyle(
                            color: isConnected ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          widget.x.ip,
                          style: TextStyle(
                            color: isConnected ? Colors.black : Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // status
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  late Future<bool> isConnected;
  late Future<MachineInfo?> info;

  @override
  void initState() {
    super.initState();
    isConnected = widget.x.isConnected();
    info = widget.x.getInfo();
  }
}

class _MoreDetails extends StatelessWidget {
  final Speaker x;
  late final Future<MachineInfo?> info;

  _MoreDetails(this.x) {
    info = x.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: info,
      builder: (ctx, snapshot) {
        // todo display placeholder when loading
        var loaded = snapshot.connectionState == ConnectionState.done;
        var info = snapshot.data as MachineInfo?;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // info col
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  label: "IP Address",
                  value: x.ip,
                ),
                _Field(
                  label: "Hostname",
                  value: loaded
                      ? info != null
                          ? info.hostname
                          : "Disconnected"
                      : "...",
                ),
              ],
            ),

            // status
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  _Field({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
