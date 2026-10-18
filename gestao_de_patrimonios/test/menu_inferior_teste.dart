import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gestao_de_patrimonios/view/widgets/menu_inferior.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('MenuInferior Widget Tests', () {
    testWidgets('Deve renderizar os 4 itens do menu inferior', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: MenuInferior(indiceAtual: 2),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Patrimônios'), findsOneWidget);
      expect(find.text('Professores'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 2);
    });

    testWidgets('Deve marcar o item correspondente ao índice atual', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            bottomNavigationBar: MenuInferior(indiceAtual: 0),
          ),
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 0);
    });
  });
}
