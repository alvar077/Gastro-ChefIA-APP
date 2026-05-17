# ChefIA

**ChefIA** é um aplicativo mobile desenvolvido em **Flutter/Dart** para consulta, organização e acompanhamento de receitas culinárias.

O projeto foi desenvolvido como trabalho final da disciplina de **Desenvolvimento Mobile**. A proposta é criar um aplicativo complementar para um canal de culinária, permitindo que os usuários explorem receitas por categoria, busquem pratos por nome ou ingrediente, salvem receitas favoritas, registrem anotações pessoais e acompanhem o progresso do preparo.

O foco principal do aplicativo é oferecer uma experiência prática, organizada, legível e funcional para uso durante o preparo das receitas.

---

## Tema do Projeto

O tema definido para o projeto foi um aplicativo de receitas para um canal de culinária no YouTube.

O problema apresentado foi que os seguidores do canal frequentemente pedem receitas nos comentários e se perdem entre muitos vídeos. O aplicativo tem como objetivo centralizar as receitas, permitir buscas rápidas e oferecer um caderno digital pessoal para favoritos, anotações e acompanhamento do preparo.

---

## Objetivo do Aplicativo

O **ChefIA** tem como objetivo permitir que o usuário:

- Visualize categorias de receitas;
- Busque receitas por nome;
- Busque receitas por ingrediente;
- Busque receitas por categoria;
- Veja detalhes completos de uma receita;
- Consulte ingredientes, medidas e modo de preparo;
- Salve receitas favoritas;
- Registre anotações pessoais;
- Marque etapas do preparo como concluídas;
- Ative o modo cozinha com fonte ampliada;
- Assista ao vídeo da receita quando disponível pela API;
- Abra o vídeo diretamente no YouTube quando houver restrição no player embutido.

---

## Tecnologias Utilizadas

- Flutter;
- Dart;
- Material Design;
- API REST;
- HTTP;
- SharedPreferences;
- Git;
- GitHub.

---

## Estrutura de Pastas

O projeto foi organizado com separação de responsabilidades:

```text
lib/
├── main.dart
├── models/
│   ├── meal_category.dart
│   ├── meal_detail.dart
│   └── meal_summary.dart
├── screens/
│   ├── home_screen.dart
│   ├── search_results_screen.dart
│   ├── recipe_detail_screen.dart
│   └── favorites_screen.dart
├── services/
│   ├── meal_service.dart
│   ├── favorite_service.dart
│   ├── note_service.dart
│   ├── progress_service.dart
│   └── preferences_service.dart
└── widgets/
    ├── loading_view.dart
    └── state_message.dart
```

### Descrição das principais pastas

- `models/`: contém as classes de dados utilizadas no app;
- `screens/`: contém as telas principais do aplicativo;
- `services/`: contém a lógica de API, favoritos, anotações, progresso e preferências;
- `widgets/`: pasta reservada para componentes reutilizáveis da interface.

---

## Como Rodar o Projeto

### 1. Clonar o repositório

```bash
git clone https://github.com/alvar077/ChefIA-APP.git
```

### 2. Entrar na pasta do projeto

```bash
cd chefapp_projetoddm
```

### 3. Instalar as dependências

```bash
flutter pub get
```

### 4. Verificar os dispositivos disponíveis

```bash
flutter devices
```

### 5. Rodar no emulador Android

Abra um emulador pelo Android Studio e execute:

```bash
flutter run
```

Ou informe diretamente o dispositivo:

```bash
flutter run -d emulator-5554
```

---


### 6. Rodar no Chrome

```bash
flutter run -d chrome --web-port 5000
```

O uso da porta fixa `5000` ajuda a manter os dados salvos localmente no navegador durante os testes com Flutter Web.

---



## Comandos Úteis

Analisar o código:

```bash
flutter analyze
```

Instalar dependências:

```bash
flutter pub get
```

Limpar o projeto:

```bash
flutter clean
```

Rodar o projeto:

```bash
flutter run
```

---

## Autor e desenvolvedores:

**Álvaro de Souza Santos**

**Deyvidy Emanoel Loiola**

**Philip Dantas**

**Marco Vinicio**


Curso: Engenharia de Software  
Disciplina: Desenvolvimento Mobile

---

## Status do Projeto

Projeto em fase final de desenvolvimento, com as principais funcionalidades obrigatórias implementadas e ajustes finais de identidade visual, publicação simulada e apresentação.
