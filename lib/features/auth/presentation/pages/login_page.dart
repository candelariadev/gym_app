import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gym_text_field.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../application/login_form_controller.dart';
import '../../domain/user_role.dart';
import '../widgets/role_selector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginFormController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.of(context).pushNamed(
      DashboardPage.routeName,
      arguments: _loginController.selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.large * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.xLarge),
                          _BrandHeader(colorScheme: colorScheme, theme: theme),
                          const SizedBox(height: 44),
                          RoleSelector(
                            selectedRole: _loginController.selectedRole,
                            onRoleSelected: (role) {
                              setState(() {
                                _loginController.changeRole(role);
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          GymTextField(
                            controller: _emailController,
                            label: 'Correo',
                            hint: 'tu@correo.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _loginController.validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.large),
                          GymTextField(
                            controller: _passwordController,
                            label: 'Contrasena',
                            hint: '..........',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _loginController.validatePassword,
                          ),
                          const SizedBox(height: 34),
                          ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Entrar'),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _helperMessage(_loginController.selectedRole),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 28),
                          const _SocialDivider(),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  label: 'Google',
                                  icon: 'G',
                                  iconColor: Color(0xFFDB4437),
                                ),
                              ),
                              SizedBox(width: AppSpacing.large),
                              Expanded(
                                child: _SocialButton(
                                  label: 'Facebook',
                                  icon: 'f',
                                  iconColor: Color(0xFF1877F2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _helperMessage(UserRole role) {
    switch (role) {
      case UserRole.coach:
        return 'Tu equipo te proporciono este acceso';
      case UserRole.trainee:
        return 'Tu entrenador te proporciono este acceso';
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.colorScheme,
    required this.theme,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 46,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          'FitCoach',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Gestion de entrenamiento',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            'O continua con',
            style: textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(
              color: iconColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
