import 'package:flutter/material.dart';

import '../models/roupa.dart';

/// Cartão que exibe os dados de uma [Roupa] na listagem, com ações de
/// editar e excluir.
class RoupaCard extends StatelessWidget {
  const RoupaCard({
    super.key,
    required this.roupa,
    required this.onEditar,
    required this.onExcluir,
  });

  final Roupa roupa;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEditar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cores.primaryContainer,
                foregroundColor: cores.onPrimaryContainer,
                child: const Icon(Icons.checkroom),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roupa.nome,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Etiqueta(texto: roupa.categoria.rotulo),
                        if (roupa.tamanho.isNotEmpty)
                          _Etiqueta(texto: 'Tam: ${roupa.tamanho}'),
                        _Etiqueta(texto: roupa.condicao.rotulo),
                        _Etiqueta(texto: 'Qtd: ${roupa.quantidade}'),
                      ],
                    ),
                    if (roupa.descricao.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        roupa.descricao,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (valor) {
                  if (valor == 'editar') onEditar();
                  if (valor == 'excluir') onExcluir();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cores.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cores.onSecondaryContainer,
            ),
      ),
    );
  }
}
