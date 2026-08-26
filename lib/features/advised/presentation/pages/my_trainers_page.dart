import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../coach/presentation/localization/client_catalog_localizations.dart';
import '../controllers/my_trainers_controller.dart';
import 'my_trainer_detail_page.dart';

class MyTrainersPage extends StatefulWidget {
  const MyTrainersPage({super.key, required this.getMyTrainers});

  static const routeName = '/advised/trainers';

  final GetMyTrainersUseCase getMyTrainers;

  @override
  State<MyTrainersPage> createState() => _MyTrainersPageState();
}

class _MyTrainersPageState extends State<MyTrainersPage> {
  late final MyTrainersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MyTrainersController(getMyTrainers: widget.getMyTrainers)
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTrainerAction)),
      body: RefreshIndicator(onRefresh: _controller.load, child: _body(l10n)),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_controller.isLoading && _controller.trainers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _controller.errorCode;
    if (error != null && _controller.trainers.isEmpty) {
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

    if (_controller.trainers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          const SizedBox(height: 96),
          const Icon(Icons.fitness_center_rounded, size: 48),
          const SizedBox(height: AppSpacing.medium),
          Text(l10n.myTrainersEmpty, textAlign: TextAlign.center),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: _controller.trainers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
      itemBuilder: (context, index) {
        final trainer = _controller.trainers[index];
        return GymClientListCard(
          name: trainer.name,
          subtitle: trainer.email.isNotEmpty
              ? trainer.email
              : l10n.valueNotAvailable,
          initials: trainer.initials,
          statusLabel: l10n.trainerRole,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(MyTrainerDetailPage.routeName, arguments: trainer),
        );
      },
    );
  }
}
