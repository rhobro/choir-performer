import 'dart:async';

import 'package:conductor/native/bridge_generated.dart';
import 'package:conductor/native/native.dart';
import 'package:conductor/util/stream.dart';

// wrapper around raw ffi
class Speaker {
  RwLockRawSpeaker _x;
  String _ip;
  get ip => _ip;

  Speaker(this._ip) : this._x = api.speakerNew(ip: _ip);

  void connect() {
    api.speakerConnect(x: _x).listen(_onUpdate);
  }

  bool isConnected() => api.speakerIsConnected(x: _x);

  Future<void> ping() async => await api.speakerPing(x: _x);

  // update callbacks
  Streamer<MachineInfo> _infos = Streamer();
  Streamer<MachineInfo> get infos => _infos;
  Streamer<int> _pings = Streamer();
  Streamer<int> get pings => _pings;

  void _onUpdate(Update u) {
    if (u.field0.runtimeType == MachineInfo) {
      _infos.next(u.field0 as MachineInfo);
    } else if (u.field0.runtimeType == Ping) {
      _pings.next((u.field0 as Ping).field0);
    }
  }
}
