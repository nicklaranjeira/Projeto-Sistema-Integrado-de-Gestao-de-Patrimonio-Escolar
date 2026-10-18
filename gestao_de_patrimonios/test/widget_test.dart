import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_patrimonios/main.dart';
import 'package:gestao_de_patrimonios/service/armazenamento_servico.dart';
import 'package:gestao_de_patrimonios/model/usuario_modelo.dart';
import 'package:get/get.dart';

class ArmazenamentoServicoMock extends ArmazenamentoServico {
  final Map<String, dynamic> _dados = {};

  @override
  String? obterToken() => _dados['jwt_token'];

  @override
  bool temTokenValido() => _dados['jwt_token'] != null && (_dados['jwt_token'] as String).isNotEmpty;

  @override
  Future<void> salvarToken(String token) async => _dados['jwt_token'] = token;

  @override
  UsuarioModelo? obterUsuario() => null;

  @override
  Future<void> limparTudo() async => _dados.clear();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ArmazenamentoServico>(ArmazenamentoServicoMock(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Teste de inicialização da aplicação', (WidgetTester tester) async {
    await tester.pumpWidget(const Aplicativo());
    expect(find.byType(Aplicativo), findsOneWidget);
  });
}


