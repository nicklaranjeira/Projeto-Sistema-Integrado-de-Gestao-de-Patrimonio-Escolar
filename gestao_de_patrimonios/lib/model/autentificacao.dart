// Login

class Login {
  final String email;
  final String password;

  Login({required this.email, required this.password});

  /// Converte o JSON recebido da API em uma instância de Login
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(email: json['email'], password: json['password']);
  }

  /// Converte os dados para o formato esperado pelo backends
  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}

// renovar token
class RenovarToken {
  final String refreshToken;

  RenovarToken({required this.refreshToken});

  /// Converte o JSON recebido da API em uma instância de RenovarToken
  factory RenovarToken.fromJson(Map<String, dynamic> json) {
    return RenovarToken(refreshToken: json['refreshToken']);
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {"refreshToken": refreshToken};
  }
}

//encerrar token
class EncerrarSessao {
  final String refreshToken;

  EncerrarSessao({required this.refreshToken});

  /// Converte o JSON recebido da API em uma instância de EncerrarSessao
  factory EncerrarSessao.fromJson(Map<String, dynamic> json) {
    return EncerrarSessao(refreshToken: json['refreshToken']);
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {"refreshToken": refreshToken};
  }
}
