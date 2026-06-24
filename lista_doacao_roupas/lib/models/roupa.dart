import 'dart:convert';

/// Categorias disponíveis para as peças de roupa (RF05 - organização por categoria).
enum CategoriaRoupa {
  camisetas('Camisetas'),
  calcas('Calças'),
  vestidos('Vestidos / Saias'),
  casacos('Casacos / Blusas'),
  calcados('Calçados'),
  intimas('Roupas íntimas'),
  infantil('Infantil'),
  acessorios('Acessórios'),
  outros('Outros');

  const CategoriaRoupa(this.rotulo);

  /// Texto exibido ao usuário.
  final String rotulo;

  /// Recupera a categoria a partir do nome salvo, com fallback seguro.
  static CategoriaRoupa fromNome(String? nome) {
    return CategoriaRoupa.values.firstWhere(
      (c) => c.name == nome,
      orElse: () => CategoriaRoupa.outros,
    );
  }
}

/// Condição/estado de conservação da peça.
enum CondicaoRoupa {
  nova('Nova'),
  seminova('Seminova'),
  usada('Usada');

  const CondicaoRoupa(this.rotulo);

  final String rotulo;

  static CondicaoRoupa fromNome(String? nome) {
    return CondicaoRoupa.values.firstWhere(
      (c) => c.name == nome,
      orElse: () => CondicaoRoupa.usada,
    );
  }
}

/// Representa uma peça de roupa destinada à doação.
class Roupa {
  Roupa({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.tamanho,
    required this.quantidade,
    required this.condicao,
    this.descricao = '',
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  final String id;
  final String nome;
  final CategoriaRoupa categoria;
  final String tamanho;
  final int quantidade;
  final CondicaoRoupa condicao;
  final String descricao;
  final DateTime criadoEm;

  Roupa copyWith({
    String? nome,
    CategoriaRoupa? categoria,
    String? tamanho,
    int? quantidade,
    CondicaoRoupa? condicao,
    String? descricao,
  }) {
    return Roupa(
      id: id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      tamanho: tamanho ?? this.tamanho,
      quantidade: quantidade ?? this.quantidade,
      condicao: condicao ?? this.condicao,
      descricao: descricao ?? this.descricao,
      criadoEm: criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria.name,
      'tamanho': tamanho,
      'quantidade': quantidade,
      'condicao': condicao.name,
      'descricao': descricao,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Roupa.fromMap(Map<String, dynamic> map) {
    return Roupa(
      id: map['id'] as String,
      nome: map['nome'] as String? ?? '',
      categoria: CategoriaRoupa.fromNome(map['categoria'] as String?),
      tamanho: map['tamanho'] as String? ?? '',
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 1,
      condicao: CondicaoRoupa.fromNome(map['condicao'] as String?),
      descricao: map['descricao'] as String? ?? '',
      criadoEm:
          DateTime.tryParse(map['criadoEm'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Roupa.fromJson(String source) =>
      Roupa.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
