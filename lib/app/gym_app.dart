import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gymsas_offline/gymsas_offline.dart';
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
    widget.dependencies.offlineSyncController?.start();
    widget.dependencies.notificationsController?.start();
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
      builder: (context, child) {
        final notifications = widget.dependencies.notificationsController;
        if (notifications != null) {
          final content = child!;
          child = AnimatedBuilder(
            animation: notifications,
            builder: (context, _) {
              if (notifications.foregroundReference == null) return content;
              final l = AppLocalizations.of(context),
                  colors = Theme.of(context).colorScheme;
              return Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Material(
                      color: colors.secondaryContainer,
                      child: ListTile(
                        title: Text(l.pushReceived),
                        trailing: Wrap(
                          children: [
                            TextButton(
                              onPressed: notifications.openForeground,
                              child: Text(l.pushOpenRoutine),
                            ),
                            IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: notifications.dismissForeground,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: content),
                ],
              );
            },
          );
        }
        final sync = widget.dependencies.offlineSyncController;
        if (sync == null) return child!;
        return AnimatedBuilder(
          animation: sync,
          builder: (context, _) {
            final state = sync.state;
            final l10n = AppLocalizations.of(context);
            if (widget.dependencies.sessionController.session == null ||
                (state.phase == OfflineSyncPhase.ready && state.pending == 0)) {
              return child!;
            }
            final message = switch (state.phase) {
              OfflineSyncPhase.ready => l10n.offlinePending(state.pending),
              OfflineSyncPhase.syncing => l10n.offlineSyncing,
              OfflineSyncPhase.offline => l10n.offlineDisconnected,
              OfflineSyncPhase.authenticationRequired =>
                l10n.offlineAuthRequired,
              OfflineSyncPhase.conflict => l10n.offlineConflict,
              OfflineSyncPhase.storageError => l10n.offlineStorageError,
            };
            final auth = state.phase == OfflineSyncPhase.authenticationRequired;
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: GymSyncStatus(
                    message: message,
                    busy: state.phase == OfflineSyncPhase.syncing,
                    warning:
                        state.phase == OfflineSyncPhase.conflict ||
                        state.phase == OfflineSyncPhase.storageError,
                    actionLabel: auth ? l10n.offlineSignIn : l10n.offlineRetry,
                    onAction: () => unawaited(
                      () async {
                        if (auth) {
                          await widget.dependencies.sessionController.logout();
                        } else {
                          if (state.phase == OfflineSyncPhase.storageError) {
                            await widget.dependencies.workoutSessionStore
                                .flushPerformance();
                          }
                          await sync.retry();
                        }
                      }().catchError((Object _) {}),
                    ),
                  ),
                ),
                Expanded(child: child!),
              ],
            );
          },
        );
      },
      routerDelegate: _routerDelegate,
      routeInformationParser: const GymRouteInformationParser(),
    );
  }
}
