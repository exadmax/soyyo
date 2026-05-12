# PLANO — Garantir App

> Documento vivo de acompanhamento. Atualizar a cada sessão de trabalho.
> **Última atualização:** 2026-05-12

---

## Visão geral

App Flutter (Android + Web) para gestão de garantias de produtos.
Stack: Flutter · Firebase Auth · Firestore · Isar (offline) · Firebase Storage.

---

## Status das telas

| Tela | Arquivo | Status | Observações |
|------|---------|--------|-------------|
| Login | `features/auth/presentation/login_page.dart` | ✅ Pronto | Login-only, link para RegisterPage, Google, forgot password |
| Cadastro | `features/auth/presentation/register_page.dart` | ✅ Pronto | CPF (UI, máscara), força de senha (4 segmentos), terms checkbox |
| Dashboard | `features/dashboard/presentation/dashboard_page.dart` | ✅ Pronto | KPI cards, health %, seções expirando/recente, bottom nav |
| Meus Produtos | `features/products/presentation/products_page.dart` | ✅ Pronto | Busca, stats strip, filter chips, cards c/ progress bar |
| Cadastro Produto | `features/products/presentation/product_form_page.dart` | ✅ Pronto | Chips de duração (3/6/12/24/36m + Outro), summary card |
| Categorias | `features/categories/presentation/categories_page.dart` | ✅ Pronto | Agrupadas (custom/padrão), delete com confirmação |
| Splash | `features/splash/presentation/splash_page.dart` | ✅ Pronto | Animação inicial existente |

---

## Integrações de navegação

| De | Para | Como | Status |
|----|------|------|--------|
| Splash | Login ou Dashboard | `_AuthGate` via `authStateChanges` | ✅ |
| Login | Dashboard | via `_AuthGate` automático | ✅ |
| Login | Cadastro | `Navigator.push` | ✅ |
| Dashboard → bottom nav | Produtos | `Navigator.push` | ✅ |
| Dashboard → bottom nav | Categorias | `Navigator.push` | ✅ |
| Dashboard → FAB | Cadastro Produto | `Navigator.push` | ✅ |
| Meus Produtos | Editar Produto | `Navigator.push(ProductFormPage(existing:))` | ✅ |
| Meus Produtos → FAB | Novo Produto | `Navigator.push` | ✅ |

---

## Camada de dados

| Funcionalidade | Implementação | Status |
|---------------|---------------|--------|
| Auth email/senha | `AuthService.signIn/register` | ✅ |
| Auth Google | `AuthService.signInWithGoogle` | ✅ |
| Logout | `AuthService.signOut` | ✅ |
| Forgot password | `FirebaseAuth.sendPasswordResetEmail` | ✅ |
| CRUD Produtos (local) | `ProductRepository` + Isar | ✅ |
| CRUD Categorias (local) | `ProductRepository` + Isar | ✅ |
| Delete Categoria | `ProductRepository.deleteCategory` | ✅ |
| Sync periódico Firestore | `syncIfNeeded` (14 dias) | ✅ |
| Write Firestore fire-and-forget | Todas saves/deletes | ✅ |
| Upload nota fiscal | `InvoiceStorageService` | ✅ |
| Notificações locais | `WarrantyAlertService` (Android, 7d + dia) | ✅ |
| Dados isolados por usuário | `users/{uid}/products`, `users/{uid}/categories` | ✅ |

---

## O que falta (próximas iterações)

### Alta prioridade
- [ ] **Tela de Perfil** — Nome, e-mail, foto, opção de mudar senha, excluir conta
- [ ] **Regras de segurança Firestore** — `match /users/{uid}` com `allow read, write: if request.auth.uid == uid`
- [ ] **Visualizar nota fiscal** — Modal/fullscreen para exibir imagem salva em `noteImageUrl`
- [ ] **Estado de carregamento na Dashboard** — shimmer ou skeleton enquanto Isar carrega

### Média prioridade
- [ ] **Gerenciamento de estado** — Riverpod ou Provider (hoje instancia repo direto nos widgets)
- [ ] **Tela de notificações** — Lista dos alertas pendentes agendados
- [ ] **Filtro de garantias na Dashboard** — "Ver todos vencendo" já navega para ProductsPage; pode passar filtro inicial
- [ ] **Editar categoria** — Hoje só cria e deleta; permitir renomear
- [ ] **Timezone dinâmico** — Hoje hardcoded `America/Sao_Paulo` em `WarrantyAlertService`
- [ ] **Paginação / carregamento lazy** — Para usuários com muitos produtos

### Baixa prioridade / Melhorias
- [ ] **Onboarding** — Tela de boas-vindas no primeiro login explicando o app
- [ ] **Export** — PDF ou CSV das garantias (relatório)
- [ ] **Widget Android** — Resumo de garantias expirando na home screen
- [ ] **Sincronização em background** — WorkManager para sync periódico mesmo com app fechado
- [ ] **Busca por voz** — Na tela de Meus Produtos
- [ ] **Compartilhar produto** — Deep link para produto específico

---

## Decisões arquiteturais registradas

| Decisão | Motivo |
|---------|--------|
| Isar-first + Firestore fire-and-forget | Funciona 100% offline; Firestore é backup/sync |
| `fastHash()` FNV-1a para Isar IDs | Isar exige `int`; UUID preservado em `firestoreId` |
| Sync a cada 14 dias | Evita leituras Firestore excessivas em uso normal |
| Sem state management por ora | MVP mais rápido; Riverpod planejado como next step |
| CPF apenas no UI (não salvo) | Privacidade; LGPD; CPF não é necessário para funcionamento do app |
| Bottom nav sem shell persistente | Navegação com `Navigator.push`; simples para MVP |

---

## Como trabalhar neste documento

1. Quando iniciar uma sessão, leia este arquivo primeiro
2. Mova itens de "O que falta" para a tabela "Status das telas" quando implementados
3. Registre decisões arquiteturais novas na tabela correspondente
4. Atualize a data de "Última atualização" no topo

---

## Comandos úteis

```bash
# Gerar schemas Isar (após mudar *_isar_schema.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Analisar código
flutter analyze

# Rodar no Android
flutter run -d android

# Rodar no Web (Chrome)
flutter run -d chrome --web-renderer canvaskit
```
