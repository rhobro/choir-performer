import 'package:conductor/native/bridge_generated.dart';
import 'package:conductor/native/native.dart';

// wrapper around raw ffi
class Speaker {
  RwLockRawSpeaker x;

  Speaker._(this.x);

  static Future<Speaker> create(String ip) async {
    return Speaker._(await api.speakerNew(ip: ip));
  }

  Future<void> connect() async {
    api.speakerConnect(x: x);
  }

  Future<bool> isConnected() async {
    return api.speakerIsConnected(x: x);
  }
}
