class Login {
  final String email;
  final String password;

  Login({required this.email, required this.password});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(email: json['email'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}

class RenovarToken {
  final String refreshToken;

  RenovarToken({required this.refreshToken});

  factory RenovarToken.fromJson(Map<String, dynamic> json) {
    return RenovarToken(refreshToken: json['refreshToken']);
  }

  Map<String, dynamic> toJson() {
    return {"refreshToken": refreshToken};
  }
}

class EncerrarSessao {
  final String refreshToken;

  EncerrarSessao({required this.refreshToken});

  factory EncerrarSessao.fromJson(Map<String, dynamic> json) {
    return EncerrarSessao(refreshToken: json['refreshToken']);
  }

  Map<String, dynamic> toJson() {
    return {"refreshToken": refreshToken};
  }
}
