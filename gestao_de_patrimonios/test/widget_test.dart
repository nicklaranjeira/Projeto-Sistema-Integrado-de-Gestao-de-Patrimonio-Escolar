import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_patrimonios/main.dart';

void main() {
  testWidgets('Teste de inicialização da aplicação', (WidgetTester tester) async {
    await tester.pumpWidget(const Aplicativo());
    expect(find.byType(Aplicativo), findsOneWidget);
  });
}
