import 'package:flutter/material.dart';

enum TipoBotao { primario, secundario, perigo, texto }

/// Botão customizado com suporte a indicador de carregamento e estilo elegante.
class BotaoPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback? aoPressionar;
  final bool carregando;
  final IconData? icone;
  final TipoBotao tipo;
  final double? largura;
  final double altura;

  const BotaoPersonalizado({
    super.key,
    required this.texto,
    this.aoPressionar,
    this.carregando = false,
    this.icone,
    this.tipo = TipoBotao.primario,
    this.largura,
    this.altura = 50,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (tipo == TipoBotao.secundario) {
      return SizedBox(
        width: largura ?? double.infinity,
        height: altura,
        child: OutlinedButton(
          onPressed: carregando ? null : aoPressionar,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: tema.colorScheme.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _construirConteudo(tema.colorScheme.primary),
        ),
      );
    }

    if (tipo == TipoBotao.perigo) {
      return SizedBox(
        width: largura ?? double.infinity,
        height: altura,
        child: ElevatedButton(
          onPressed: carregando ? null : aoPressionar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _construirConteudo(Colors.white),
        ),
      );
    }

    if (tipo == TipoBotao.texto) {
      return SizedBox(
        width: largura,
        height: altura,
        child: TextButton(
          onPressed: carregando ? null : aoPressionar,
          style: TextButton.styleFrom(
            foregroundColor: tema.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _construirConteudo(tema.colorScheme.primary),
        ),
      );
    }

    // Padrão: Primário
    return SizedBox(
      width: largura ?? double.infinity,
      height: altura,
      child: ElevatedButton(
        onPressed: carregando ? null : aoPressionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: tema.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _construirConteudo(Colors.white),
      ),
    );
  }

  Widget _construirConteudo(Color corTexto) {
    if (carregando) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(corTexto),
        ),
      );
    }

    if (icone != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 20, color: corTexto),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
        ],
      );
    }

    return Text(
      texto,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: corTexto,
      ),
    );
  }
}
