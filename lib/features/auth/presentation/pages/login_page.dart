import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/login_form_controller.dart';
import '../localization/auth_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.controller,
    required this.onAuthenticated,
  });

  final LoginFormController controller;
  final ValueChanged<AuthSession> onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = await widget.controller.submit(
      user: _userController.text,
      password: _passwordController.text,
    );
    if (session != null && mounted) widget.onAuthenticated(session);
  }

  String? _validateUser(String? value, AppLocalizations l10n) {
    final user = value?.trim() ?? '';
    if (user.isEmpty) return l10n.validationUserRequired;
    if (user.length < 3) return l10n.validationUserMinLength(3);
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    final password = value ?? '';
    if (password.isEmpty) return l10n.validationPasswordRequired;
    if (password.length < 6) return l10n.validationPasswordMinLength(6);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final errorCode = widget.controller.errorCode;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          l10n.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 40),
                        CredentialsFields(
                          userController: _userController,
                          passwordController: _passwordController,
                          userLabel: l10n.usernameLabel,
                          userHint: l10n.usernameHint,
                          passwordLabel: l10n.passwordLabel,
                          passwordHint: l10n.passwordHint,
                          userValidator: (value) => _validateUser(value, l10n),
                          passwordValidator: (value) =>
                              _validatePassword(value, l10n),
                          onPasswordSubmitted: _submit,
                        ),
                        if (errorCode != null) ...[
                          const SizedBox(height: AppSpacing.medium),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l10n.errorMessage(errorCode),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xLarge),
                        GymPrimaryButton(
                          label: l10n.loginButton,
                          isLoading: widget.controller.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        Text(
                          l10n.roleAutoDetected,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
