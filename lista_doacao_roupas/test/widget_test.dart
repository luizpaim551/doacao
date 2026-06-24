import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lista_doacao_roupas/main.dart';
import 'package:lista_doacao_roupas/models/roupa.dart';

void main() {
  group('Modelo Roupa', () {
    test('serializa e desserializa preservando os dados', () {
      final roupa = Roupa(
        id: '1',
        nome: 'Camiseta branca',
        categoria: CategoriaRoupa.camisetas,
        tamanho: 'M',
        quantidade: 3,
        condicao: CondicaoRoupa.seminova,
        descricao: 'Algodão',
      );

      final recuperada = Roupa.fromJson(roupa.toJson());

      expect(recuperada.id, roupa.id);
      expect(recuperada.nome, roupa.nome);
      expect(recuperada.categoria, CategoriaRoupa.camisetas);
      expect(recuperada.tamanho, 'M');
      expect(recuperada.quantidade, 3);
      expect(recuperada.condicao, CondicaoRoupa.seminova);
      expect(recuperada.descricao, 'Algodão');
    });

    test('fromNome usa fallback seguro para valores desconhecidos', () {
      expect(CategoriaRoupa.fromNome('inexistente'), CategoriaRoupa.outros);
      expect(CondicaoRoupa.fromNome(null), CondicaoRoupa.usada);
    });

    test('copyWith altera apenas os campos informados', () {
      final roupa = Roupa(
        id: '1',
        nome: 'Calça',
        categoria: CategoriaRoupa.calcas,
        tamanho: '42',
        quantidade: 1,
        condicao: CondicaoRoupa.usada,
      );

      final editada = roupa.copyWith(quantidade: 5);

      expect(editada.id, '1');
      expect(editada.nome, 'Calça');
      expect(editada.quantidade, 5);
    });
  });

  testWidgets('App inicia exibindo o título e o botão de cadastro',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ListaDoacaoApp());
    await tester.pumpAndSettle();

    expect(find.text('Lista de Doação de Roupas'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Cadastrar'),
        findsOneWidget);
    expect(find.text('Nenhuma roupa cadastrada'), findsOneWidget);
  });
}
