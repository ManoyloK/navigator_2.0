import 'package:flutter/material.dart';

import 'app.dart';
import 'navigation/index.dart';

void main() {
  final navigation = Navigation(rootPage: PageName.root, pageFactory: PageFactory());
  runApp(App(navigation));
}
