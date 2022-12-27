import 'package:conductor/native/speaker.dart';
import 'package:flutter/material.dart';
import 'package:conductor/native/bridge_generated.dart';

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

        // create list with each speaker
        child: ListView.builder(
          itemCount: speakers.length,
          itemBuilder: (ctx, i) => _Item(
            speakers[i],
            onSelect: () => select(speakers[i].ip),
            isSelected: speakers[i].ip == selectedIP,
          ),
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
      speakers = [];
      for (var i = 1; i <= 5; i++) {
        speakers.add(await Speaker.create("192.168.0.$i"));
        await speakers.last.connect().then((_) => setState(() {}));
      }
    });
  }
}

class _Item extends StatelessWidget {
  final Speaker x;
  final bool isSelected;
  final VoidCallback onSelect;

  _Item(
    this.x, {
    required this.onSelect,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // get connection status
    return GestureDetector(
      onTap: onSelect,
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
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        child: FutureBuilder(
          future: x.isConnected(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            var isConnected = snapshot.data as bool;

            // get info
            return FutureBuilder(
              future: x.getInfo(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                var info = snapshot.data as Info?;

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
                          x.ip,
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
}
