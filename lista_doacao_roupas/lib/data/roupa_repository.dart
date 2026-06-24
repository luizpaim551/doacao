import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/roupa.dart';

/// Repositório responsável pela persistência local das roupas (RNF: banco
/// de dados local/simples). Usa [SharedPreferences], funcionando em web,
/// mobile e desktop sem configuração adicional.
class RoupaRepository {
  static const String _chave = 'roupas_cadastradas';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Lê todas as roupas cadastradas (RF04 - listagem).
  Future<List<Roupa>> listar() async {
    final prefs = await _prefs;
    final dados = prefs.getStringList(_chave) ?? <String>[];
    final roupas = dados.map(Roupa.fromJson).toList();
    // Mais recentes primeiro.
    roupas.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return roupas;
  }

  /// Adiciona uma nova roupa (RF01 - cadastro).
  Future<void> adicionar(Roupa roupa) async {
    final roupas = await listar();
    roupas.add(roupa);
    await _salvarTudo(roupas);
  }

  /// Atualiza uma roupa existente (RF02 - edição).
  Future<void> atualizar(Roupa roupa) async {
    final roupas = await listar();
    final indice = roupas.indexWhere((r) => r.id == roupa.id);
    if (indice == -1) {
      throw StateError('Roupa não encontrada para atualização: ${roupa.id}');
    }
    roupas[indice] = roupa;
    await _salvarTudo(roupas);
  }

  /// Remove uma roupa pelo id (RF03 - exclusão).
  Future<void> remover(String id) async {
    final roupas = await listar();
    roupas.removeWhere((r) => r.id == id);
    await _salvarTudo(roupas);
  }

  Future<void> _salvarTudo(List<Roupa> roupas) async {
    final prefs = await _prefs;
    final dados = roupas.map((r) => r.toJson()).toList();
    await prefs.setStringList(_chave, dados);
  }

  /// Exporta os dados em JSON (útil para backup / mitigar risco de perda).
  Future<String> exportarJson() async {
    final roupas = await listar();
    return const JsonEncoder.withIndent('  ')
        .convert(roupas.map((r) => r.toMap()).toList());
  }
}
