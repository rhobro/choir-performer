import 'package:conductor/native/speaker.dart';
import 'package:conductor/views/app.dart';
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),

                // list
                child: ListView.builder(
                  itemCount: speakers.length,
                  itemBuilder: (ctx, i) => Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: _Item(
                      ls[i],
                      onSelect: () => select(ls[i].ip),
                      isSelected: ls[i].ip == selectedIP,
                    ),
                  ),
                ),
              ),
            ),

            // toolbar
            Column(
              children: [
                selectedIP != null
                    ? _MoreDetails(speakers[selectedIP!]!)
                    : Container(),
                TextButton(
                  onPressed: enter,
                  child: Text("Enter"),
                ),
              ],
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

  void enter() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => App(),
        ),
      );

  @override
  void initState() {
    super.initState();
    speakers["127.0.0.1"] = Speaker("127.0.0.1");
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
    var isConnected = widget.x.isConnected();

    return GestureDetector(
      onTap: () {
        widget.x.connect();
        widget.onSelect();
      },
      child: Container(
        // border
        padding: EdgeInsets.only(
          top: 5,
          right: 15,
          bottom: 5,
          left: 5,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            // darken on selection
            color: widget.isSelected ? Colors.black : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // summarised display

            // name details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // hostname
                Text(
                  isConnected
                      ? info != null
                          ? info!.hostname
                          : "---"
                      : "Disconnected",
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
            _Status(
              colour: isConnected ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  MachineInfo? info;
  void onInfo(MachineInfo? v) => setState(() {
        info = v;
      });

  @override
  void initState() {
    super.initState();
    widget.x.infos.subscribe(onInfo);
  }

  @override
  void dispose() {
    widget.x.infos.unsubscribe(onInfo);
    super.dispose();
  }
}

class _MoreDetails extends StatefulWidget {
  final Speaker x;

  _MoreDetails(this.x);

  @override
  State<StatefulWidget> createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<_MoreDetails> {
  @override
  Widget build(BuildContext context) {
    var isConnected = widget.x.isConnected();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // info col
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(
              label: "Hostname",
              value: isConnected
                  ? info != null
                      ? info!.hostname
                      : "..."
                  : "Disconnected",
            ),
            _Field(
              label: "IP Address",
              value: widget.x.ip,
            ),
            _Field(
              label: "Mac Address",
              value: isConnected
                  ? info != null
                      ? info!.mac
                      : "..."
                  : "---",
            ),
          ],
        ),

        // status
        _Status(
          colour: isConnected ? Colors.green : Colors.red,
          child: Text(ping != null ? "$ping ms" : "---"),
        )
      ],
    );
  }

  MachineInfo? info;
  void onInfo(MachineInfo? v) => setState(() {
        info = v;
      });
  int? ping;
  void onPing(int? v) => setState(() {
        ping = v;
      });

  @override
  void initState() {
    super.initState();
    widget.x.infos.subscribe(onInfo);
    widget.x.pings.subscribe(onPing);
  }

  @override
  void dispose() {
    widget.x.infos.unsubscribe(onInfo);
    widget.x.pings.unsubscribe(onPing);
    super.dispose();
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

class _Status extends StatelessWidget {
  final Color colour;
  final Widget? child;

  _Status({
    required this.colour,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    double? width, height;
    EdgeInsets? padding;
    var background = colour;
    if (child != null) {
      // some child
      padding = EdgeInsets.all(3);
      background = background.withAlpha(16);
    } else {
      // no child
      width = height = 12;
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: colour,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
