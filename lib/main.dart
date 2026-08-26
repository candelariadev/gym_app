import 'package:flutter/material.dart';

import 'app/app_dependencies.dart';
import 'app/gym_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GymApp(dependencies: await AppDependencies.production()));
}
