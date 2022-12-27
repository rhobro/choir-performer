import 'package:conductor/views/discovery.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  // initialise
  WidgetsFlutterBinding.ensureInitialized();
  // window size
  setWindowMinSize(Size(350, 500));
  setWindowMaxSize(Size(450, 800));

  // run app
  runApp(MaterialApp(
    home: Discovery(),
  ));
}
