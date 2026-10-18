import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/rotas_app.dart';

/// Barra de navegação inferior padrão para os módulos do sistema.
class MenuInferior extends StatelessWidget {
  final int indiceAtual;

  const MenuInferior({
    super.key,
    required this.indiceAtual,
  });

  void _navegarPara(int index) {
    if (index == indiceAtual) return;

    switch (index) {
      case 0:
        Get.offNamed(RotasApp.ADMIN_PAINEL);
        break;
      case 1:
        Get.offNamed(RotasApp.ADMIN_PATRIMONIOS);
        break;
      case 2:
        Get.offNamed(RotasApp.ADMIN_PROFESSORES);
        break;
      case 3:
        Get.offNamed(RotasApp.PERFIL);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final primaryColor = tema.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: indiceAtual,
        onTap: _navegarPara,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.blueGrey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Patrimônios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Professores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
