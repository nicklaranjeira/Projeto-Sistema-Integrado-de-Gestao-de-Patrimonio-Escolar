import 'package:flutter/material.dart';

/// Widget de crachá visual para exibir o status de bens e usuários de maneira humanizada e intuitiva.
class CrachaStatus extends StatelessWidget {
  final String status;
  final bool formatoPequeno;

  const CrachaStatus({
    super.key,
    required this.status,
    this.formatoPequeno = false,
  });

  @override
  Widget build(BuildContext context) {
    final configuracao = _obterConfiguracaoPorStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: formatoPequeno ? 8 : 12,
        vertical: formatoPequeno ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: configuracao.corFundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: configuracao.corBorda,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            configuracao.icone,
            size: formatoPequeno ? 13 : 16,
            color: configuracao.corTexto,
          ),
          const SizedBox(width: 5),
          Text(
            configuracao.rotulo,
            style: TextStyle(
              color: configuracao.corTexto,
              fontSize: formatoPequeno ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _ConfiguracaoStatus _obterConfiguracaoPorStatus(String statusBruto) {
    final statusNormalizado = statusBruto.trim().toLowerCase();

    switch (statusNormalizado) {
      case 'disponivel':
        return const _ConfiguracaoStatus(
          rotulo: 'Disponível',
          icone: Icons.check_circle_outline_rounded,
          corTexto: Color(0xFF1B5E20),
          corFundo: Color(0xFFE8F5E9),
          corBorda: Color(0xFFA5D6A7),
        );
      case 'alocado':
      case 'em_uso':
        return const _ConfiguracaoStatus(
          rotulo: 'Em Uso',
          icone: Icons.person_pin_circle_outlined,
          corTexto: Color(0xFF0D47A1),
          corFundo: Color(0xFFE3F2FD),
          corBorda: Color(0xFF90CAF9),
        );
      case 'manutencao':
      case 'em_manutencao':
        return const _ConfiguracaoStatus(
          rotulo: 'Em Manutenção',
          icone: Icons.build_circle_outlined,
          corTexto: Color(0xFFE65100),
          corFundo: Color(0xFFFFF3E0),
          corBorda: Color(0xFFFFCC80),
        );
      case 'baixado':
        return const _ConfiguracaoStatus(
          rotulo: 'Baixado',
          icone: Icons.remove_circle_outline_rounded,
          corTexto: Color(0xFFB71C1C),
          corFundo: Color(0xFFFFEBEE),
          corBorda: Color(0xFFEF9A9A),
        );
      case 'ativo':
        return const _ConfiguracaoStatus(
          rotulo: 'Ativo',
          icone: Icons.check_circle_outline_rounded,
          corTexto: Color(0xFF2E7D32),
          corFundo: Color(0xFFE8F5E9),
          corBorda: Color(0xFFA5D6A7),
        );
      case 'inativo':
        return const _ConfiguracaoStatus(
          rotulo: 'Inativo',
          icone: Icons.highlight_off_rounded,
          corTexto: Color(0xFF616161),
          corFundo: Color(0xFFF5F5F5),
          corBorda: Color(0xFFE0E0E0),
        );
      default:
        return _ConfiguracaoStatus(
          rotulo: statusBruto.isNotEmpty ? statusBruto : 'Indefinido',
          icone: Icons.help_outline_rounded,
          corTexto: const Color(0xFF455A64),
          corFundo: const Color(0xFFECEFF1),
          corBorda: const Color(0xFFCFD8DC),
        );
    }
  }
}

class _ConfiguracaoStatus {
  final String rotulo;
  final IconData icone;
  final Color corTexto;
  final Color corFundo;
  final Color corBorda;

  const _ConfiguracaoStatus({
    required this.rotulo,
    required this.icone,
    required this.corTexto,
    required this.corFundo,
    required this.corBorda,
  });
}
