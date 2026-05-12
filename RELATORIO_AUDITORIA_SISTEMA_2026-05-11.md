# Relatorio de Auditoria Tecnica - SoyYo (Garantir)

Data: 2026-05-11
Escopo: checagem completa das telas, fluxos e arquitetura para continuidade por Claude e GitHub Copilot.

## 1) Metodo e limitacoes

Checagem realizada por leitura completa de codigo-fonte e configuracoes.

Validacoes automaticas tentadas:
- `flutter --version`
- `flutter analyze`
- `flutter test`

Resultado: todas bloqueadas por ausencia do SDK Flutter no ambiente atual (`flutter: command not found`).

## 2) Resumo executivo

Status geral: **base funcional consistente para Android/Web com auth, produtos, categorias, persistencia local (Isar), sincronizacao periodica com Firestore e notificacoes locais**.

Conclusao principal:
- Ha bastante implementacao real, inclusive pontos que estavam "planejados" em documentacoes antigas (ex.: isolamento por usuario no Firestore).
- Existem pontos de integracao pendentes (principalmente Dashboard nao conectado ao fluxo principal e lacunas de documentacao/qualidade).

Confianca da avaliacao: alta para estrutura e fluxos estaticos; media para comportamento runtime por falta de execucao local.

## 3) Inventario do que JA foi feito

### 3.1 Fluxo de inicializacao e autenticação
- App principal inicializa Firebase + Isar e sobe o app.
- Gate de autenticacao com Splash + listener de sessao.
- Login com e-mail/senha.
- Cadastro no mesmo formulario (modo alternado) na tela de login.
- Login com Google implementado.
- Recuperacao de senha (reset por e-mail) implementada.

### 3.2 Produtos
- Listagem de produtos via stream local (Isar), ordenada por vencimento.
- CRUD de produto (novo, editar, excluir).
- Campo de descricao opcional.
- Seletor de categoria e tipo de garantia.
- Captura de foto da nota fiscal via camera e upload para Firebase Storage.
- Agendamento/cancelamento de alertas locais de vencimento por produto.

### 3.3 Categorias
- Listagem de categorias via stream local.
- Inclusao de categoria customizada.
- Seed de categorias padrao na inicializacao de tela principal.

### 3.4 Persistencia, offline e sincronizacao
- Isar como fonte principal para leitura de UI.
- Escrita em Isar primeiro (update imediato), replicacao para Firestore em seguida.
- Sincronizacao periodica do Firestore para Isar com janela de 14 dias.
- Controle de ultimo sync em tabela dedicada (`SyncMetaIsarSchema`).

### 3.5 Firestore e seguranca
- Repositorio usa colecoes por usuario (`users/{uid}/products` e `users/{uid}/categories`).
- Regras Firestore restringem acesso ao proprio UID autenticado.

### 3.6 Interface e telas
- Splash animada implementada.
- Tela de produtos funcional.
- Tela de categorias funcional.
- Tela de login/cadastro funcional e com UI mais refinada.
- Dashboard implementada com layout completo e atalhos.

## 4) O que esta PARCIAL ou pendente de integracao

### 4.1 Dashboard nao esta no fluxo principal
- O fluxo principal (AuthGate) direciona para `ProductsPage`, nao para `DashboardPage`.
- A dashboard existe, mas esta "solta" sem entrypoint oficial no app principal.

Impacto: usuario nao acessa a tela dashboard na navegacao padrao.

### 4.2 Duplicidade de estrategia de cadastro
- Existe `RegisterPage` separada.
- Existe tambem cadastro incorporado na `LoginPage` (toggle Entrar/Criar conta).
- A tela separada `RegisterPage` nao aparece no fluxo ativo.

Impacto: risco de manutencao duplicada e divergencia de UX/regras.

### 4.3 Validacao automatica indisponivel no ambiente atual
- Sem Flutter SDK no container, nao foi possivel confirmar:
  - lints/analyze
  - testes
  - possiveis quebras de runtime/compilacao

Impacto: qualidade real de build ainda nao certificada neste ambiente.

### 4.4 Documentacao desalinhada
- Arquivos de orientacao indicam pontos como "futuros" que ja foram implementados (ex.: isolamento por usuario).
- Parte da documentacao ainda descreve `firebase_options.dart` como placeholder, mas arquivo esta configurado com projeto real.

Impacto: Claude/Copilot podem tomar decisoes erradas por contexto desatualizado.

## 5) Riscos tecnicos observados

1. Acoplamento de repositorio com usuario autenticado:
   - `currentUser!.uid` assume sessao sempre ativa.
   - Se houver chamada de repositório sem auth resolvida, pode ocorrer excecao.

2. Fluxo web diferente do app principal:
   - `main_web.dart` direciona para tela informativa (`_WebHome`) apos login, nao para produtos/dashboard.
   - Pode ser intencional, mas precisa estar explicitado como regra de produto.

3. Notificacoes com timezone fixo:
   - Timezone hardcoded em `America/Sao_Paulo`.
   - Pode gerar comportamento incorreto para usuarios fora desse fuso.

4. Ausencia de state management dedicado:
   - Repositorios/servicos instanciados direto em widgets.
   - Escala e testabilidade podem piorar com crescimento do app.

5. Cobertura de teste muito baixa:
   - Apenas 1 teste widget simples.
   - Nao cobre fluxos criticos (auth, sync, CRUD, notificacoes, regras de negocio).

## 6) Prioridades recomendadas (ordem sugerida)

P0 (antes de novas features):
1. Instalar Flutter SDK no ambiente de desenvolvimento e habilitar pipeline minima (`flutter analyze`, `flutter test`).
2. Decidir fluxo oficial pos-login:
   - Opcao A: `DashboardPage` como home.
   - Opcao B: manter `ProductsPage` e remover dashboard do escopo imediato.
3. Consolidar cadastro em uma unica tela/estrategia (ou justificar coexistencia).

P1 (robustez):
4. Atualizar documentacao de arquitetura/roadmap para refletir estado real.
5. Cobrir com testes ao menos:
   - auth gate
   - repositorio (save/delete/sync)
   - formularios e validacoes basicas
6. Revisar tratamento quando `currentUser` for null no repositorio.

P2 (evolucao):
7. Introduzir camada de estado (Riverpod/Provider/Bloc).
8. Timezone dinamico para notificacoes.
9. Evoluir dashboard para navegação oficial e analytics de vencimentos.

## 7) Guia operacional para Claude e GitHub Copilot daqui pra frente

### 7.1 Verdades do projeto (usar como fonte principal)
- Arquitetura atual: feature-first + Isar local + sync periodico Firestore.
- Dados Firestore ja estao isolados por usuario autenticado.
- Fluxo principal atual (app nativo): Splash -> AuthGate -> Login/Products.
- Dashboard existe, mas nao e home oficial.

### 7.2 Regras para futuras mudancas
- Sempre manter escrita local-first (Isar antes de Firestore).
- Evitar criar novas telas duplicadas para o mesmo fluxo (auth/produtos).
- Toda mudanca em schema Isar exige regeneracao com build_runner.
- Toda mudanca relevante deve atualizar documentacao tecnica no mesmo PR.

### 7.3 Checklist minimo antes de aceitar PR
- `flutter analyze` sem erros.
- `flutter test` sem falhas.
- Fluxo de login, cadastro, CRUD de produtos e categorias validado manualmente.
- Nenhuma regressao no auth gate e no sync periodico.

## 8) Evidencias principais (arquivos auditados)

- `lib/app/app.dart`
- `lib/main.dart`
- `lib/main_web.dart`
- `lib/features/auth/domain/auth_service.dart`
- `lib/features/auth/presentation/login_page.dart`
- `lib/features/auth/presentation/register_page.dart`
- `lib/features/products/data/product_repository.dart`
- `lib/features/products/presentation/products_page.dart`
- `lib/features/products/presentation/product_form_page.dart`
- `lib/features/products/data/invoice_storage_service.dart`
- `lib/features/categories/presentation/categories_page.dart`
- `lib/features/dashboard/presentation/dashboard_page.dart`
- `lib/features/alerts/warranty_alert_service.dart`
- `lib/features/splash/presentation/splash_page.dart`
- `lib/core/database/isar_database.dart`
- `lib/core/database/sync_meta_isar_schema.dart`
- `lib/firebase_options.dart`
- `firestore.rules`
- `pubspec.yaml`
- `analysis_options.yaml`
- `test/widget_test.dart`

---

Se quiser, o proximo passo ideal e eu transformar este relatorio em um plano de execucao com backlog tecnico (P0/P1/P2) no formato de tarefas prontas para PR.
