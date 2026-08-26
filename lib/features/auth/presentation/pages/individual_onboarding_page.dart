import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/federated_auth_controller.dart';
import '../localization/auth_localizations.dart';

class IndividualOnboardingPage extends StatefulWidget {
  const IndividualOnboardingPage({
    super.key,
    required this.controller,
    required this.onAuthenticated,
  });
  final FederatedAuthController controller;
  final ValueChanged<AuthSession> onAuthenticated;

  @override
  State<IndividualOnboardingPage> createState() =>
      _IndividualOnboardingPageState();
}

class _IndividualOnboardingPageState extends State<IndividualOnboardingPage> {
  final _form = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  final _password = TextEditingController();
  final _birthdate = TextEditingController();
  final _weight = TextEditingController();
  final _goals = TextEditingController();
  final _notes = TextEditingController();
  final _bio = TextEditingController();
  final _certifications = TextEditingController();
  final _experience = TextEditingController();
  UserRole _role = UserRole.advised;
  UserGender? _gender;
  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    _nickname.text =
        widget.controller.flow?.identity.name.split(' ').first ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      _nickname,
      _password,
      _birthdate,
      _weight,
      _goals,
      _notes,
      _bio,
      _certifications,
      _experience,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value?.trim().isEmpty != false ? 'Campo requerido' : null;

  Future<void> _selectBirthdate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthdate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedBirthdate = DateUtils.dateOnly(selected);
      _birthdate.text = MaterialLocalizations.of(
        context,
      ).formatCompactDate(selected);
    });
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final advised = _role == UserRole.advised
        ? AdvisedOnboarding(
            birthdate: _selectedBirthdate!,
            gender: _gender!,
            weight: double.parse(_weight.text.trim()),
            goals: _goals.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          )
        : null;
    final trainer = _role == UserRole.trainer
        ? TrainerOnboarding(
            bio: _bio.text.trim(),
            certifications: _certifications.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(),
            experience: int.parse(_experience.text.trim()),
          )
        : null;
    final session = await widget.controller.complete(
      IndividualOnboarding(
        idToken: '',
        nickname: _nickname.text.trim(),
        password: _password.text,
        role: _role,
        advised: advised,
        trainer: trainer,
      ),
    );
    if (session != null && mounted) widget.onAuthenticated(session);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu cuenta individual')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _form,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.controller.flow?.identity.email ?? '',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<UserRole>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Rol'),
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.advised,
                            child: Text('Usuario asesorado'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.trainer,
                            child: Text('Entrenador'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _role = value!),
                      ),
                      TextFormField(
                        controller: _nickname,
                        decoration: const InputDecoration(
                          labelText: 'Nickname',
                        ),
                        validator: _required,
                      ),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña local de respaldo',
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 8) {
                            return 'Usa al menos 8 caracteres';
                          }
                          if (!RegExp(r'\d').hasMatch(value!)) {
                            return 'Agrega al menos un número';
                          }
                          if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
                            return 'Agrega al menos un símbolo';
                          }
                          return null;
                        },
                      ),
                      if (_role == UserRole.advised) ...[
                        TextFormField(
                          controller: _birthdate,
                          readOnly: true,
                          onTap: _selectBirthdate,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingBirthdateLabel,
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          validator: (_) => _selectedBirthdate == null
                              ? l10n.onboardingBirthdateRequired
                              : null,
                        ),
                        DropdownButtonFormField<UserGender>(
                          initialValue: _gender,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingGenderLabel,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: UserGender.male,
                              child: Text(l10n.onboardingGenderMale),
                            ),
                            DropdownMenuItem(
                              value: UserGender.female,
                              child: Text(l10n.onboardingGenderFemale),
                            ),
                            DropdownMenuItem(
                              value: UserGender.other,
                              child: Text(l10n.onboardingGenderOther),
                            ),
                          ],
                          onChanged: (value) => setState(() => _gender = value),
                          validator: (value) => value == null
                              ? l10n.onboardingGenderRequired
                              : null,
                        ),
                        TextFormField(
                          controller: _weight,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                          ),
                          validator: (value) =>
                              double.tryParse(value ?? '') == null
                              ? 'Número inválido'
                              : null,
                        ),
                        TextFormField(
                          controller: _goals,
                          decoration: const InputDecoration(
                            labelText: 'Objetivos separados por coma',
                          ),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _notes,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _bio,
                          decoration: const InputDecoration(
                            labelText: 'Biografía',
                          ),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _certifications,
                          decoration: const InputDecoration(
                            labelText: 'Certificaciones separadas por coma',
                          ),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _experience,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Años de experiencia',
                          ),
                          validator: (value) =>
                              int.tryParse(value ?? '') == null
                              ? 'Número inválido'
                              : null,
                        ),
                      ],
                      if (widget.controller.errorCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            l10n.errorMessage(widget.controller.errorCode!),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: widget.controller.isLoading ? null : _submit,
                        child: Text(
                          widget.controller.isLoading
                              ? 'Guardando…'
                              : 'Crear cuenta individual',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
