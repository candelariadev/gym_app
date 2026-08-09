import 'package:flutter/material.dart';

import '../atoms/gym_text_field.dart';
import '../theme/app_spacing.dart';

class CredentialsFields extends StatelessWidget {
  const CredentialsFields({
    super.key,
    required this.userController,
    required this.passwordController,
    required this.userLabel,
    required this.userHint,
    required this.passwordLabel,
    required this.passwordHint,
    required this.userValidator,
    required this.passwordValidator,
    required this.onPasswordSubmitted,
  });

  final TextEditingController userController;
  final TextEditingController passwordController;
  final String userLabel;
  final String userHint;
  final String passwordLabel;
  final String passwordHint;
  final FormFieldValidator<String> userValidator;
  final FormFieldValidator<String> passwordValidator;
  final VoidCallback onPasswordSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GymTextField(
          controller: userController,
          label: userLabel,
          hint: userHint,
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          validator: userValidator,
        ),
        const SizedBox(height: AppSpacing.large),
        GymTextField(
          controller: passwordController,
          label: passwordLabel,
          hint: passwordHint,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: passwordValidator,
          onFieldSubmitted: (_) => onPasswordSubmitted(),
        ),
      ],
    );
  }
}
