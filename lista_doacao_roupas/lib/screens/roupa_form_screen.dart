import 'package:flutter/material.dart';

import '../data/roupa_repository.dart';
import '../models/roupa.dart';

/// Formulário de cadastro (RF01) e edição (RF02) de roupas.
///
/// Quando [roupa] é nulo, cria uma nova peça; caso contrário, edita a peça
/// informada.
class RoupaFormScreen extends StatefulWidget {
  const RoupaFormScreen({super.key, this.roupa});

  final Roupa? roupa;

  bool get isEdicao => roupa != null;

  @override
  State<RoupaFormScreen> createState() => _RoupaFormScreenState();
}

class _RoupaFormScreenState extends State<RoupaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = RoupaRepository();

  late final TextEditingController _nomeController;
  late final TextEditingController _tamanhoController;
  late final TextEditingController _quantidadeController;
  late final TextEditingController _descricaoController;

  late CategoriaRoupa _categoria;
  late CondicaoRoupa _condicao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final roupa = widget.roupa;
    _nomeController = TextEditingController(text: roupa?.nome ?? '');
    _tamanhoController = TextEditingController(text: roupa?.tamanho ?? '');
    _quantidadeController =
        TextEditingController(text: (roupa?.quantidade ?? 1).toString());
    _descricaoController = TextEditingController(text: roupa?.descricao ?? '');
    _categoria = roupa?.categoria ?? CategoriaRoupa.camisetas;
    _condicao = roupa?.condicao ?? CondicaoRoupa.usada;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tamanhoController.dispose();
    _quantidadeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final quantidade = int.tryParse(_quantidadeController.text.trim()) ?? 1;

    try {
      if (widget.isEdicao) {
        final atualizada = widget.roupa!.copyWith(
          nome: _nomeController.text.trim(),
          categoria: _categoria,
          tamanho: _tamanhoController.text.trim(),
          quantidade: quantidade,
          condicao: _condicao,
          descricao: _descricaoController.text.trim(),
        );
        await _repositorio.atualizar(atualizada);
      } else {
        final nova = Roupa(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          nome: _nomeController.text.trim(),
          categoria: _categoria,
          tamanho: _tamanhoController.text.trim(),
          quantidade: quantidade,
          condicao: _condicao,
          descricao: _descricaoController.text.trim(),
        );
        await _repositorio.adicionar(nova);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdicao
                ? 'Roupa atualizada com sucesso.'
                : 'Roupa cadastrada com sucesso.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdicao ? 'Editar roupa' : 'Cadastrar roupa'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome da peça *',
                    hintText: 'Ex.: Camiseta branca',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome da peça.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoriaRoupa>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoria *'),
                  items: [
                    for (final c in CategoriaRoupa.values)
                      DropdownMenuItem(value: c, child: Text(c.rotulo)),
                  ],
                  onChanged: (valor) {
                    if (valor != null) setState(() => _categoria = valor);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tamanhoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Tamanho',
                          hintText: 'P, M, G, 42...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade *',
                        ),
                        validator: (valor) {
                          final n = int.tryParse(valor?.trim() ?? '');
                          if (n == null || n < 1) {
                            return 'Informe um número válido (>= 1).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CondicaoRoupa>(
                  initialValue: _condicao,
                  decoration: const InputDecoration(labelText: 'Condição *'),
                  items: [
                    for (final c in CondicaoRoupa.values)
                      DropdownMenuItem(value: c, child: Text(c.rotulo)),
                  ],
                  onChanged: (valor) {
                    if (valor != null) setState(() => _condicao = valor);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Cor, estado, marca, etc. (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isEdicao ? 'Salvar alterações' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
