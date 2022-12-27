import 'dart:ffi';
import 'dart:io';

import 'package:conductor/native/bridge_generated.dart';

const _base = 'native';
final _path = Platform.isWindows ? '$_base.dll' : 'lib$_base.so';
final _dylib =
    Platform.isMacOS ? DynamicLibrary.executable() : DynamicLibrary.open(_path);

final api = NativeImpl(_dylib);
