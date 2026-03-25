import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/coach_dashboard_data.dart';

class CoachRoutineHistoryPage extends StatelessWidget {
  const CoachRoutineHistoryPage({super.key});

  static const routeName = '/coach/routine-history';

  @override
  Widget build(BuildContext context) {
    final client = ModalRoute.of(context)?.settings.arguments as CoachClient?;
    final title = client == null
        ? 'Historial de rutinas'
        : 'Historial de ${client.name}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.large),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A1A1B4B),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pantalla base creada',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    'Aqui luego veremos historial de rutinas, cambios de plan y progreso acumulado del asesorado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (client != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Asesorado seleccionado: ${client.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
