# Emplake — DDM / UFSCar

Engenharia reversa do jogo [Emplake](https://www.cyan-lang.org/emplake/) em Flutter.
Autora: **Nathalie Santos Komatsu**.

Dados os 4 dígitos de uma placa, o jogador insere operadores e o sinal de `=`
(sem mudar a ordem dos dígitos) para formar uma igualdade verdadeira.
A fórmula aparece logo abaixo renderizada em LaTeX.

## Interface

A placa tem **fendas** antes, entre e depois dos dígitos. Tocar numa fenda abre a
**roda de operadores**: o anel interno tem os binários (+ − × ÷ **) e o externo os
demais (parênteses, raízes, fatorial, módulo, base e teto). O `=` já começa na placa
e muda de fenda com as setinhas.

## Regras

| Nível | Operadores | Pontos |
|---|---|---|
| Fácil | + − × ÷ ( ) √ ∛ ! ** \|x\| ⌊x⌋ ⌈x⌉ | 1 |
| Intermediário | + − × ÷ ( ) √ ∛ ! ** \|x\| | 2 |
| Avançado | + − × ÷ ( ) √ ! \|x\| | 3 |
| Difícil | + − × ÷ ( ) \|x\| | 5 |

- Só o Fácil aceita divisão (e raiz) com resultado não inteiro.
- Dígitos vizinhos sem operador formam um número só (2 8 → 28).
- O menos unário é permitido: −(2 − 5) = 3.
- O sorteio só mostra placas **com solução** no nível (verificado por um solver)
  e que o jogador **ainda não resolveu** (lidas do Firestore).

## Arquitetura

```
lib/
  main.dart, app.dart          inicialização (Firebase, prefs, ProviderScope) e MaterialApp.router
  core/router/                 go_router, redirect de login, última rota (SharedPreferences)
  core/theme/                  tema a partir das configurações
  core/widgets/                loader animado, bandeiras (CustomPainter), seletor de idioma
  game/engine/                 Dart puro: tokens, parser, AST, racionais exatos, avaliador, LaTeX, solver
  game/domain/                 níveis e placas
  game/state/                  GameController (Riverpod Notifier)
  game/ui/                     tela do jogo, placa interativa, roda de operadores
  auth/ history/ ranking/ settings/ help/ shell/ data/ sound/
  l10n/                        traduções PT/EN (ARB + arquivos gerados)
test/engine_test.dart          testes do motor do jogo
```

| Requisito | Onde |
|---|---|
| LaTeX abaixo da fórmula | `game/ui/game_page.dart` (`flutter_math_fork`) |
| Login e-mail/senha e Google | `auth/login_page.dart` (`firebase_ui_auth`) |
| Integrante e idioma com bandeiras no login | `auth/login_page.dart`, `core/widgets/flags.dart` |
| Tudo traduzido | `lib/l10n/*.arb` (`flutter_localizations`) |
| Barra inferior curva + ajuda + configurações | `shell/app_shell.dart` (`curved_navigation_bar`), `help/help_dialog.dart` |
| Tema claro/escuro, fonte, tamanho, cor semente, temas prontos | `settings/` |
| Voltar à página anterior ao reabrir | `core/router/app_router.dart` (`RouteMemory`) |
| Riverpod | `settingsProvider`, `gameProvider`, `authUserProvider`, `routerProvider` |
| go_router | `core/router/app_router.dart` |
| Animações | roda (escala + rotação), operadores voltando após acerto, placa tremendo no erro, dígitos girando |
| Firestore + FutureBuilder + loader não padrão | `game_page.dart`, `history_page.dart`, `ranking_page.dart`, `app_loader.dart` |
| Pular placa | botão **Pular** |
| Som opcional (desligado por padrão) | `sound/sound_service.dart` (sons gerados em código) |
| Responsivo | `LayoutBuilder` em todas as páginas (celular, tablet, computador) |

## Como rodar

1. Copie estes arquivos para a pasta do projeto criado com `flutter create`
   (substitua `lib/`, `test/` e `pubspec.yaml`). **Não** apague o
   `lib/firebase_options.dart` gerado pelo `flutterfire configure`.
2. No Firebase: **Authentication → Sign-in method → Google → Configuração do SDK da Web**,
   copie o **ID do cliente da Web** e cole em `googleClientId` no `lib/main.dart`.
3. No Firebase: **Firestore → Regras**, cole o conteúdo de `firestore.rules` e publique.
4. `flutter pub get` (também gera as traduções em `lib/l10n/`).
5. `flutter test` e depois `flutter run -d chrome`.

## Publicação (GitHub Pages)

O workflow `.github/workflows/deploy.yml` compila a versão web e publica a cada push na `main`.
No repositório: **Settings → Pages → Source: GitHub Actions**. Link final:
`https://SEU-USUARIO.github.io/emplake/`. Adicione `SEU-USUARIO.github.io` em
**Firebase → Authentication → Settings → Authorized domains**.
