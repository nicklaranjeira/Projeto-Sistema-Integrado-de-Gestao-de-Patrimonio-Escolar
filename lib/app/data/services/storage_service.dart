import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

/// Serviço responsável pelo armazenamento persistente local (Tokens e Sessão)
class StorageService extends GetxService {
  late final GetStorage _box;

  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyBaseUrl = 'custom_base_url';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Token JWT
  String? getToken() => _box.read<String>(_keyToken);
  Future<void> saveToken(String token) => _box.write(_keyToken, token);
  Future<void> removeToken() => _box.remove(_keyToken);

  // Refresh Token
  String? getRefreshToken() => _box.read<String>(_keyRefreshToken);
  Future<void> saveRefreshToken(String token) => _box.write(_keyRefreshToken, token);

  // Dados do Usuário
  UserModel? getUser() {
    final data = _box.read(_keyUser);
    if (data != null && data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  Future<void> saveUser(UserModel user) => _box.write(_keyUser, user.toJson());
  Future<void> removeUser() => _box.remove(_keyUser);

  // URL Base configurável (Emulador: 10.0.2.2:8081 / Web ou iOS: localhost:8081)
  String getBaseUrl() => _box.read<String>(_keyBaseUrl) ?? 'http://10.0.2.2:8081/api';
  Future<void> saveBaseUrl(String url) => _box.write(_keyBaseUrl, url);

  // Limpeza geral (Logout)
  Future<void> clearAll() async {
    await _box.remove(_keyToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUser);
  }

  bool get hasValidToken => getToken() != null && getToken()!.isNotEmpty;
}
