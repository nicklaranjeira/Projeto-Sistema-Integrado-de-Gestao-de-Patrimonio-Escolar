import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../modelos/usuario_modelo.dart';

class ArmazenamentoServico extends GetxService {
  late final GetStorage _caixa;

  static const String _chaveToken = 'jwt_token';
  static const String _chaveRefreshToken = 'refresh_token';
  static const String _chaveUsuario = 'dados_usuario';
  static const String _chaveUrlBase = 'url_base_personalizada';

  Future<ArmazenamentoServico> inicializar() async {
    await GetStorage.init();
    _caixa = GetStorage();
    return this;
  }

  String? obterToken() => _caixa.read<String>(_chaveToken);
  Future<void> salvarToken(String token) => _caixa.write(_chaveToken, token);
  Future<void> removerToken() => _caixa.remove(_chaveToken);

  String? obterRefreshToken() => _caixa.read<String>(_chaveRefreshToken);
  Future<void> salvarRefreshToken(String token) => _caixa.write(_chaveRefreshToken, token);

  UsuarioModelo? obterUsuario() {
    final dados = _caixa.read(_chaveUsuario);
    if (dados != null && dados is Map<String, dynamic>) {
      return UsuarioModelo.fromJson(dados);
    }
    return null;
  }

  Future<void> salvarUsuario(UsuarioModelo usuario) => _caixa.write(_chaveUsuario, usuario.toJson());
  Future<void> removerUsuario() => _caixa.remove(_chaveUsuario);

  String obterUrlBase() => _caixa.read<String>(_chaveUrlBase) ?? 'http://10.0.2.2:8081/api';
  Future<void> salvarUrlBase(String url) => _caixa.write(_chaveUrlBase, url);

  Future<void> limparTudo() async {
    await _caixa.remove(_chaveToken);
    await _caixa.remove(_chaveRefreshToken);
    await _caixa.remove(_chaveUsuario);
  }

  bool get possuiTokenValido => obterToken() != null && obterToken()!.isNotEmpty;
}
