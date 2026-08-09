import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../l10n/app_localizations.dart';
import 'app_dependencies.dart';
import 'navigation/gym_router.dart';

class GymApp extends StatefulWidget {
  const GymApp({super.key, required this.dependencies, this.locale});

  final AppDependencies dependencies;
  final Locale? locale;

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  late final GymRouterDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();
    _routerDelegate = GymRouterDelegate(dependencies: widget.dependencies);
    widget.dependencies.sessionController.restore();
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerDelegate: _routerDelegate,
      routeInformationParser: const GymRouteInformationParser(),
    );
  }
}
