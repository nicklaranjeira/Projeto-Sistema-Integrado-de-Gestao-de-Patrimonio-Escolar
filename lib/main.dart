import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/dados/servicos/armazenamento_servico.dart';
import 'app/rotas/paginas_app.dart';
import 'app/rotas/rotas_app.dart';
import 'app/vinculacoes/inicial_vinculacao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final armazenamentoServico = await ArmazenamentoServico().inicializar();
  Get.put<ArmazenamentoServico>(armazenamentoServico, permanent: true);

  runApp(const Aplicativo());
}

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sistema de Gestão de Patrimônio Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF26A69A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialBinding: InicialVinculacao(),
      initialRoute: RotasApp.LOGIN,
      getPages: PaginasApp.rotas,
      defaultTransition: Transition.cupertino,
    );
  }
}
