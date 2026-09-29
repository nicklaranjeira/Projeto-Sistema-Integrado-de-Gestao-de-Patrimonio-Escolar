import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/usuario_modelo.dart';

class ArmazenamentoServico extends GetxService {
  late final GetStorage _caixa;

  static const String _chaveToken = 'jwt_token';
  static const String _chaveRefreshToken = 'jwt_refresh_token';
  static const String _chaveUsuario = 'dados_usuario';

  Future<ArmazenamentoServico> inicializar() async {
    await GetStorage.init();
    _caixa = GetStorage();
    return this;
  }

  Future<void> salvarToken(String token) async {
    await _caixa.write(_chaveToken, token);
  }

  String? obterToken() {
    return _caixa.read<String>(_chaveToken);
  }

  bool temTokenValido() {
    final token = obterToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> salvarRefreshToken(String refreshToken) async {
    await _caixa.write(_chaveRefreshToken, refreshToken);
  }

  String? obterRefreshToken() {
    return _caixa.read<String>(_chaveRefreshToken);
  }

  Future<void> salvarUsuario(UsuarioModelo usuario) async {
    await _caixa.write(_chaveUsuario, usuario.toJson());
  }

  UsuarioModelo? obterUsuario() {
    final dados = _caixa.read<Map<String, dynamic>>(_chaveUsuario);
    if (dados == null) return null;
    return UsuarioModelo.fromJson(dados);
  }

  Future<void> limparTudo() async {
    await _caixa.erase();
  }
}
