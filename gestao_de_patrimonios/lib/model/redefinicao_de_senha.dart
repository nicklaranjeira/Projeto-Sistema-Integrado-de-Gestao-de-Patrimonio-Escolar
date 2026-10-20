/// Etapa 1 da recuperação de senha: envio do e-mail para geração do código (RF03).
class ForgotPassword {
  final String email;

  ForgotPassword({required this.email});

  factory ForgotPassword.fromJson(Map<String, dynamic> json) {
    return ForgotPassword(email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {"email": email};
  }
}

/// Etapa 2 da recuperação de senha: verificação do código de 6 dígitos (RF03).
class VerifyCode {
  final String email;
  final String code;

  VerifyCode({required this.email, required this.code});

  factory VerifyCode.fromJson(Map<String, dynamic> json) {
    return VerifyCode(email: json['email'], code: json['code']);
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "code": code};
  }
}

/// Etapa 3 da recuperação de senha: envio do código com a nova senha (RF03).
class ResetPassword {
  final String email;
  final String code;
  final String newPassword;

  ResetPassword({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  factory ResetPassword.fromJson(Map<String, dynamic> json) {
    return ResetPassword(
      email: json['email'],
      code: json['code'],
      newPassword: json['newPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "code": code, "newPassword": newPassword};
  }
}
