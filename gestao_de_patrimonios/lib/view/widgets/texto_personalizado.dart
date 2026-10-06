import 'package:flutter/material.dart';

/// Campo de texto humanizado e padronizado para os formulários do aplicativo.
class CampoTextoPersonalizado extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String? dica;
  final IconData? iconePrefixo;
  final Widget? sufixo;
  final bool ocultarTexto;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;
  final int maxLinhas;
  final bool somenteLeitura;
  final VoidCallback? aoTocar;
  final ValueChanged<String>? aoAlterar;

  const CampoTextoPersonalizado({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.dica,
    this.iconePrefixo,
    this.sufixo,
    this.ocultarTexto = false,
    this.tipoTeclado = TextInputType.text,
    this.validador,
    this.maxLinhas = 1,
    this.somenteLeitura = false,
    this.aoTocar,
    this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: tema.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controlador,
          obscureText: ocultarTexto,
          keyboardType: tipoTeclado,
          validator: validador,
          maxLines: maxLinhas,
          readOnly: somenteLeitura,
          onTap: aoTocar,
          onChanged: aoAlterar,
          style: TextStyle(
            fontSize: 15,
            color: somenteLeitura ? Colors.blueGrey.shade600 : Colors.blueGrey.shade900,
          ),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey.shade300,
            ),
            prefixIcon: iconePrefixo != null
                ? Icon(iconePrefixo, color: tema.colorScheme.primary, size: 20)
                : null,
            suffixIcon: sufixo,
            filled: true,
            fillColor: somenteLeitura ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tema.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
