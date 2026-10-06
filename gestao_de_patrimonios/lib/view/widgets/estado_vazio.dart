import 'package:flutter/material.dart';

/// Widget humanizado para exibição de estados vazios (Empty States).
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? textoAcao;
  final VoidCallback? aoPressionarAcao;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.textoAcao,
    this.aoPressionarAcao,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tema.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: 38,
                color: tema.colorScheme.primary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade500,
                height: 1.4,
              ),
            ),
            if (textoAcao != null && aoPressionarAcao != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: aoPressionarAcao,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(textoAcao!),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: tema.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
