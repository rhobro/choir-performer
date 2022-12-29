import 'package:conductor/native/bridge_generated.dart';
import 'package:conductor/native/native.dart';

// wrapper around raw ffi
class Speaker {
  RwLockRawSpeaker _x;
  String _ip;
  String get ip => _ip;

  Speaker._(this._x, this._ip);

  static Future<Speaker> create(String ip) async {
    return Speaker._(await api.speakerNew(ip: ip), ip);
  }

  Future<void> connect() async {
    api.speakerConnect(x: _x);
  }

  Future<bool> isConnected() async {
    return api.speakerIsConnected(x: _x);
  }

  Future<MachineInfo?> getInfo() async {
    return api.speakerGetInfo(x: _x);
  }

  Future<double> ping() async {
    return api.speakerPing(x: _x);
  }
}
