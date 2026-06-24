# Diagrama de Arquitetura — Lista de Doação de Roupas

Aplicativo Flutter para organização de roupas destinadas à doação (cadastro,
edição, exclusão, listagem, busca e filtro por categoria), com persistência
local via `SharedPreferences`.

## 1. Arquitetura em camadas

```mermaid
flowchart TB
    subgraph App["App (main.dart)"]
        MA["ListaDoacaoApp\nMaterialApp + Tema Material 3"]
    end

    subgraph UI["Camada de Apresentação (lib/screens, lib/widgets)"]
        HS["HomeScreen\nListagem · busca · filtro"]
        FS["RoupaFormScreen\nCadastro · edição"]
        RC["RoupaCard\nCartão da peça (editar/excluir)"]
        ET["_Etiqueta\nChip de metadado"]
    end

    subgraph DATA["Camada de Dados (lib/data)"]
        RR["RoupaRepository\nlistar · adicionar · atualizar\nremover · exportarJson"]
    end

    subgraph MODEL["Modelo de Domínio (lib/models)"]
        R["Roupa\n(toMap/fromMap, toJson/fromJson, copyWith)"]
        CAT["enum CategoriaRoupa"]
        CON["enum CondicaoRoupa"]
    end

    subgraph PERSIST["Persistência"]
        SP[("SharedPreferences\nchave: roupas_cadastradas\nList<String> JSON")]
    end

    MA --> HS
    HS --> FS
    HS --> RC
    RC --> ET
    HS --> RR
    FS --> RR
    RR --> R
    R --> CAT
    R --> CON
    RR --> SP
```

## 2. Relacionamento entre classes

```mermaid
classDiagram
    class Roupa {
        +String id
        +String nome
        +CategoriaRoupa categoria
        +String tamanho
        +int quantidade
        +CondicaoRoupa condicao
        +String descricao
        +DateTime criadoEm
        +copyWith() Roupa
        +toMap() Map
        +toJson() String
        +fromMap(map)$ Roupa
        +fromJson(source)$ Roupa
    }

    class CategoriaRoupa {
        <<enum>>
        camisetas, calcas, vestidos
        casacos, calcados, intimas
        infantil, acessorios, outros
        +String rotulo
        +fromNome(nome)$ CategoriaRoupa
    }

    class CondicaoRoupa {
        <<enum>>
        nova, seminova, usada
        +String rotulo
        +fromNome(nome)$ CondicaoRoupa
    }

    class RoupaRepository {
        -String _chave
        +listar() Future~List~Roupa~~
        +adicionar(roupa) Future
        +atualizar(roupa) Future
        +remover(id) Future
        +exportarJson() Future~String~
    }

    class HomeScreen
    class RoupaFormScreen
    class RoupaCard

    Roupa --> CategoriaRoupa
    Roupa --> CondicaoRoupa
    RoupaRepository ..> Roupa : cria/serializa
    HomeScreen --> RoupaRepository : usa
    RoupaFormScreen --> RoupaRepository : usa
    HomeScreen --> RoupaCard : renderiza
    HomeScreen ..> RoupaFormScreen : navega
    RoupaCard --> Roupa : exibe
```

## 3. Fluxo principal (cadastro / edição)

```mermaid
sequenceDiagram
    actor U as Usuário
    participant H as HomeScreen
    participant F as RoupaFormScreen
    participant Rep as RoupaRepository
    participant SP as SharedPreferences

    U->>H: abre o app
    H->>Rep: listar()
    Rep->>SP: getStringList()
    SP-->>Rep: List<String> JSON
    Rep-->>H: List<Roupa> (ordenada)

    U->>H: toca "Cadastrar"
    H->>F: push(RoupaFormScreen)
    U->>F: preenche e salva
    F->>Rep: adicionar() / atualizar()
    Rep->>SP: setStringList()
    F-->>H: pop(true)
    H->>Rep: listar() (recarrega)
    Rep-->>H: lista atualizada
```
