import 'package:flutter/material.dart';
import 'package:gymsas_payments/gymsas_payments.dart';
import '../../application/checkout_controller.dart';

class PlansCheckoutPage extends StatefulWidget {
  const PlansCheckoutPage({super.key, required this.controller});
  static const routeName = '/plans';
  final CheckoutController controller;
  @override
  State<PlansCheckoutPage> createState() => _PlansCheckoutPageState();
}

class _PlansCheckoutPageState extends State<PlansCheckoutPage> {
  late final Future<List<PlanOffer>> _plans;
  final _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _plans = widget.controller.loadPlans();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Planes y suscripción')),
    body: FutureBuilder<List<PlanOffer>>(
      future: _plans,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('No se pudieron cargar los planes: ${snapshot.error}'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Correo del pagador',
                helperText: 'En sandbox usa el correo del usuario de prueba.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            for (final plan in snapshot.data ?? const <PlanOffer>[])
              _PlanCard(
                plan: plan,
                busy: widget.controller.isPaying,
                onPay: plan.isCurrent ? null : () => _pay(plan),
              ),
            if (widget.controller.message case final message?)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(message),
                ),
              ),
          ],
        );
      },
    ),
  );

  void _pay(PlanOffer plan) {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo válido.')),
      );
      return;
    }
    widget.controller.pay(plan, email);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.busy,
    required this.onPay,
  });
  final PlanOffer plan;
  final bool busy;
  final VoidCallback? onPay;
  @override
  Widget build(BuildContext context) {
    final amount = (plan.amountMinor / 100).toStringAsFixed(2);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(plan.description),
            const SizedBox(height: 14),
            Text(
              '\$$amount ${plan.currency} / mes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (plan.taxIncluded) const Text('Impuestos incluidos'),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: busy || plan.isCurrent ? null : onPay,
              icon: busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      plan.isCurrent
                          ? Icons.check_circle_outline
                          : Icons.credit_card,
                    ),
              label: Text(
                plan.isCurrent ? 'Plan actual' : 'Pagar con Mercado Pago',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
