import 'package:conductor/native/bridge_generated.dart';
import 'package:conductor/native/native.dart';

// wrapper around raw ffi
class Speaker {
  RwLockRawSpeaker _x;
  String _ip;

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

  String get ip => _ip;

  Future<Info?> getInfo() async {
    return api.speakerGetInfo(x: _x);
  }
}
