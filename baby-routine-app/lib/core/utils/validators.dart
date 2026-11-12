class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }
    return null;
  }
}
