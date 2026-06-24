import 'package:flutter/material.dart';

import '../data/roupa_repository.dart';
import '../models/roupa.dart';
import '../widgets/roupa_card.dart';
import 'roupa_form_screen.dart';

/// Tela inicial: lista as roupas cadastradas, permite buscar por nome ou
/// categoria (RF06), filtrar por categoria (RF05) e acessar as operações
/// de cadastro, edição e exclusão (RF01, RF02, RF03, RF04).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoupaRepository _repositorio = RoupaRepository();
  final TextEditingController _buscaController = TextEditingController();

  List<Roupa> _roupas = [];
  bool _carregando = true;
  String _termoBusca = '';
  CategoriaRoupa? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final roupas = await _repositorio.listar();
    if (!mounted) return;
    setState(() {
      _roupas = roupas;
      _carregando = false;
    });
  }

  /// Aplica busca textual (nome ou categoria) e filtro de categoria.
  List<Roupa> get _roupasFiltradas {
    final termo = _termoBusca.trim().toLowerCase();
    return _roupas.where((roupa) {
      final correspondeCategoria =
          _categoriaFiltro == null || roupa.categoria == _categoriaFiltro;
      final correspondeBusca = termo.isEmpty ||
          roupa.nome.toLowerCase().contains(termo) ||
          roupa.categoria.rotulo.toLowerCase().contains(termo) ||
          roupa.descricao.toLowerCase().contains(termo);
      return correspondeCategoria && correspondeBusca;
    }).toList();
  }

  Future<void> _abrirFormulario({Roupa? roupa}) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RoupaFormScreen(roupa: roupa)),
    );
    if (salvou == true) {
      await _carregar();
    }
  }

  Future<void> _excluir(Roupa roupa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir roupa'),
        content: Text('Deseja realmente excluir "${roupa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _repositorio.remover(roupa.id);
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${roupa.nome}" excluída.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Doação de Roupas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar'),
      ),
      body: Column(
        children: [
          _buildBarraBusca(),
          _buildFiltrosCategoria(),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildBarraBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou categoria...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _termoBusca.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _termoBusca = '');
                  },
                ),
        ),
        onChanged: (valor) => setState(() => _termoBusca = valor),
      ),
    );
  }

  Widget _buildFiltrosCategoria() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: _categoriaFiltro == null,
              onSelected: (_) => setState(() => _categoriaFiltro = null),
            ),
          ),
          for (final categoria in CategoriaRoupa.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria.rotulo),
                selected: _categoriaFiltro == categoria,
                onSelected: (_) =>
                    setState(() => _categoriaFiltro = categoria),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    final roupas = _roupasFiltradas;

    if (_roupas.isEmpty) {
      return _buildEstadoVazio(
        icone: Icons.checkroom,
        titulo: 'Nenhuma roupa cadastrada',
        subtitulo: 'Toque em "Cadastrar" para adicionar a primeira peça.',
      );
    }

    if (roupas.isEmpty) {
      return _buildEstadoVazio(
        icone: Icons.search_off,
        titulo: 'Nenhum resultado encontrado',
        subtitulo: 'Tente outro termo de busca ou categoria.',
      );
    }

    // Layout responsivo: grade em telas largas, lista em telas estreitas.
    return RefreshIndicator(
      onRefresh: _carregar,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colunas = (constraints.maxWidth ~/ 360).clamp(1, 4);
          if (colunas == 1) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: roupas.length,
              itemBuilder: (context, index) => RoupaCard(
                roupa: roupas[index],
                onEditar: () => _abrirFormulario(roupa: roupas[index]),
                onExcluir: () => _excluir(roupas[index]),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
              mainAxisExtent: 168,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: roupas.length,
            itemBuilder: (context, index) => RoupaCard(
              roupa: roupas[index],
              onEditar: () => _abrirFormulario(roupa: roupas[index]),
              onExcluir: () => _excluir(roupas[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoVazio({
    required IconData icone,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitulo,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
