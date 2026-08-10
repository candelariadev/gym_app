import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/trainer_clients_controller.dart';
import '../localization/client_catalog_localizations.dart';
import 'coach_client_profile_page.dart';

class CoachClientsPage extends StatefulWidget {
  const CoachClientsPage({super.key, required this.getTrainerClients});

  static const routeName = '/coach/clients';

  final GetTrainerClientsUseCase getTrainerClients;

  @override
  State<CoachClientsPage> createState() => _CoachClientsPageState();
}

class _CoachClientsPageState extends State<CoachClientsPage> {
  late final TrainerClientsController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TrainerClientsController(getTrainerClients: widget.getTrainerClients)
          ..addListener(_refresh)
          ..load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainerClientsAction)),
      body: RefreshIndicator(onRefresh: _controller.load, child: _body(l10n)),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_controller.isLoading && _controller.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _controller.errorCode;
    if (error != null && _controller.clients.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          const SizedBox(height: 96),
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(l10n.clientCatalogError(error), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.medium),
          Center(
            child: GymPrimaryButton(
              label: l10n.exerciseRetry,
              onPressed: _controller.retry,
            ),
          ),
        ],
      );
    }
    if (_controller.clients.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          const SizedBox(height: 96),
          const Icon(Icons.people_outline_rounded, size: 48),
          const SizedBox(height: AppSpacing.medium),
          Text(l10n.clientsEmptyTitle, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.small),
          Text(l10n.clientsEmptyDescription, textAlign: TextAlign.center),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: _controller.clients.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
      itemBuilder: (context, index) {
        final client = _controller.clients[index];
        return GymClientListCard(
          name: client.name,
          subtitle: l10n.assignedWorkoutCount(client.assignedWorkouts.length),
          initials: client.initials,
          statusLabel: l10n.clientStatusLabel(client.status),
          onTap: () => Navigator.of(
            context,
          ).pushNamed(CoachClientProfilePage.routeName, arguments: client),
        );
      },
    );
  }
}
