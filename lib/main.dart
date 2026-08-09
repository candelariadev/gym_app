import 'package:flutter/material.dart';

import 'app/app_dependencies.dart';
import 'app/gym_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GymApp(dependencies: AppDependencies.production()));
}
