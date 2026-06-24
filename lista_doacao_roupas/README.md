# Lista de Doação de Roupas

Aplicativo desenvolvido em **Flutter** para organização de roupas destinadas à
doação, conforme o *Documento de Visão – Projeto de Extensão (UNISENAI MT,
2026/1)*. Permite o controle simples e centralizado das peças disponíveis, com
uso individual, sem necessidade de autenticação ou integração com APIs externas.

## Funcionalidades (Requisitos Funcionais)

| Req. | Descrição | Onde |
|------|-----------|------|
| RF01 | Cadastro de roupas | Botão **Cadastrar** → formulário |
| RF02 | Edição de roupas | Toque no card ou menu → **Editar** |
| RF03 | Exclusão de roupas | Menu do card → **Excluir** (com confirmação) |
| RF04 | Listagem de todas as roupas | Tela inicial |
| RF05 | Organização por categorias | Chips de filtro por categoria |
| RF06 | Busca por nome ou categoria | Campo de busca no topo |

### Dados de cada peça
Nome, categoria, tamanho, quantidade, condição (nova/seminova/usada) e
observações.

## Requisitos não funcionais atendidos
- **Usabilidade:** interface simples, intuitiva e em português.
- **Responsividade:** layout adapta-se a celular (lista) e computador/web
  (grade com múltiplas colunas).
- **Desempenho:** persistência local rápida, sem dependência de rede.
- **Manutenibilidade:** código organizado em camadas (modelo, repositório,
  telas e widgets).

## Arquitetura

```
lib/
├── main.dart                      # Inicialização e tema do app
├── models/
│   └── roupa.dart                 # Modelo Roupa + enums de Categoria/Condição
├── data/
│   └── roupa_repository.dart      # Persistência local (CRUD) via SharedPreferences
├── screens/
│   ├── home_screen.dart           # Listagem, busca e filtros
│   └── roupa_form_screen.dart     # Cadastro e edição
└── widgets/
    └── roupa_card.dart            # Item da lista
```

A persistência usa **SharedPreferences** (banco de dados local simples),
funcionando em web, Android, Linux e demais plataformas suportadas pelo
Flutter, sem configuração adicional.

## Como executar

Pré-requisitos: Flutter 3.44+ instalado.

```bash
cd lista_doacao_roupas
flutter pub get

# Navegador (web)
flutter run -d chrome

# Android / Linux desktop
flutter run

# Gerar build web de produção
flutter build web
```

## Testes e qualidade

```bash
dart analyze     # análise estática (sem issues)
flutter test     # testes de unidade e widget
```

## Observações sobre LGPD
O sistema não coleta dados pessoais de doadores ou beneficiários — armazena
apenas informações das peças de roupa, localmente no dispositivo do usuário.

---
UNISENAI Mato Grosso – Cuiabá/MT | 2026/1 | Versão 1.0
