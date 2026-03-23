import '../domain/user_role.dart';

class LoginFormController {
  LoginFormController({this.selectedRole = UserRole.trainee});

  UserRole selectedRole;

  void changeRole(UserRole role) {
    selectedRole = role;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ingresa tu correo';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo valido';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Ingresa tu contrasena';
    }

    if (password.length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }

    return null;
  }
}
