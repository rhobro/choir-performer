import 'package:conductor/views/discovery.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  // initialise
  WidgetsFlutterBinding.ensureInitialized();

  // run app
  runApp(MaterialApp(
    home: Discovery(),
  ));
}
