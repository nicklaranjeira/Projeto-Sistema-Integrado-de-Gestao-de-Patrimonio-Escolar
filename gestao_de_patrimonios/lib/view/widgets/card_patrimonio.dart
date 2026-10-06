import 'package:flutter/material.dart';
import '../../model/patrimonio_modelo.dart';
import 'cracha_status.dart';

/// Card modular e reutilizável para representação de bens patrimoniais.
class CardPatrimonio extends StatelessWidget {
  final PatrimonioModelo patrimonio;
  final VoidCallback? aoTocar;
  final Widget? acaoExtra;

  const CardPatrimonio({
    super.key,
    required this.patrimonio,
    this.aoTocar,
    this.acaoExtra,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final iconeCategoria = _obterIconePorCategoria(patrimonio.categoria);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Tombamento + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tema.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: tema.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_rounded,
                          size: 14,
                          color: tema.colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          patrimonio.numeroTombo.isNotEmpty ? patrimonio.numeroTombo : 'S/ TOMBO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tema.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CrachaStatus(
                    status: patrimonio.status,
                    formatoPequeno: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nome e descrição principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconeCategoria,
                      color: Colors.blueGrey.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patrimonio.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        if (patrimonio.categoria != null && patrimonio.categoria!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            patrimonio.categoria!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (acaoExtra != null) acaoExtra!,
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),

              // Rodapé: Localização ou Responsável
              Row(
                children: [
                  if (patrimonio.localizacao != null && patrimonio.localizacao!.isNotEmpty) ...[
                    Icon(Icons.location_on_outlined, size: 15, color: Colors.blueGrey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        patrimonio.localizacao!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],
                  if (patrimonio.professorResponsavelNome != null &&
                      patrimonio.professorResponsavelNome!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 15, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            patrimonio.professorResponsavelNome!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _obterIconePorCategoria(String? categoria) {
    if (categoria == null) return Icons.inventory_2_outlined;

    final cat = categoria.toLowerCase();
    if (cat.contains('inform') || cat.contains('comput') || cat.contains('note')) {
      return Icons.laptop_mac_rounded;
    } else if (cat.contains('audio') || cat.contains('proj') || cat.contains('som')) {
      return Icons.videocam_outlined;
    } else if (cat.contains('lab') || cat.contains('ciênc')) {
      return Icons.biotech_outlined;
    } else if (cat.contains('mobil') || cat.contains('mesa') || cat.contains('cadeira')) {
      return Icons.chair_outlined;
    } else if (cat.contains('eletr')) {
      return Icons.devices_other_outlined;
    } else if (cat.contains('esport')) {
      return Icons.sports_basketball_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}
