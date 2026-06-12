# Baby Routine — Rotina do Bebê
## Visão Geral do Projeto

---

## 1. Identificação do Projeto

| Campo                | Valor              |
| -------------------- | ------------------ |
| Nome do produto      | Rotina do Bebê     |
| Nome técnico         | Baby Routine       |
| Repositório backend  | `baby-routine-api` |
| Repositório frontend | `baby-routine-app` |
| Versão da spec       | 1.0.0              |
| Data                 | 2026-05            |

---

## 2. Descrição

O **Baby Routine** é um aplicativo móvel multiplataforma (Android e iOS) desenvolvido para auxiliar pais, mães e demais responsáveis no gerenciamento da rotina diária de bebês. O app permite registrar e monitorar atividades essenciais — alimentação, sono, fraldas, banho, consultas médicas, vacinação e medicamentos — com suporte a múltiplos responsáveis acessando os mesmos dados simultaneamente em tempo real.

---

## 3. Objetivos

- Centralizar em um único ambiente todas as informações relevantes da rotina do bebê.
- Permitir que múltiplos responsáveis (pais, avós, babá, etc.) acompanhem e registrem eventos simultaneamente.
- Emitir lembretes e alertas em tempo real para evitar esquecimentos.
- Oferecer histórico e relatórios de saúde e desenvolvimento do bebê.
- Ser intuitivo e acessível para usuários sem conhecimento técnico.

---

## 4. Escopo da Versão 1.0

### Incluído

- Autenticação de usuários (cadastro, login, JWT)
- Gerenciamento de perfis de bebês
- Compartilhamento de bebê com múltiplos responsáveis
- Registro de eventos da rotina diária (alimentação, sono, fralda, banho, consulta, vacina, medicação)
- Configuração de rotinas e lembretes recorrentes
- Notificações push via Firebase Cloud Messaging (FCM)
- Checklist diário
- Relatórios e gráficos de evolução
- Histórico de saúde
- Anotações personalizadas
- API REST documentada com Swagger

### Fora do Escopo (v1.0)

- Upload de fotos/imagens
- Suporte a múltiplos idiomas (interface em pt-BR)
- Funcionamento offline
- Integração com planos de saúde ou prontuários médicos
- Pagamentos ou planos premium

---

## 5. Convenções de Nomenclatura

Todo o código-fonte, banco de dados e APIs devem ser escritos em **inglês**, sem exceção. Isso inclui:

- Nomes de tabelas e colunas do banco de dados
- Nomes de variáveis, funções, classes e arquivos
- Rotas da API REST
- Campos de request/response JSON
- Estrutura de pastas dos projetos
- Mensagens de commit e comentários no código

A interface do usuário (textos visíveis no app) permanece em **português (pt-BR)**.

---

## 6. Restrições e Requisitos Não Funcionais

| Requisito           | Detalhe                                                                 |
| ------------------- | ----------------------------------------------------------------------- |
| Usabilidade         | Interface simples e intuitiva, sem necessidade de conhecimento técnico  |
| Desempenho          | Resposta em até 2 segundos para ações comuns                            |
| Disponibilidade     | Indisponibilidade máxima de 1 hora por mês                              |
| Segurança           | Dados protegidos por criptografia; acesso restrito por autenticação JWT |
| Compatibilidade     | Android e iOS (via Flutter)                                             |
| Notificações        | Lembretes entregues de forma confiável via FCM                          |
| Idioma da interface | Português brasileiro (pt-BR)                                            |
| Idioma do código    | Inglês                                                                  |

---

## 7. Índice dos Documentos de Especificação

| Arquivo                | Conteúdo                                                                          |
| ---------------------- | --------------------------------------------------------------------------------- |
| `00-visao-geral.md`    | Este documento — contexto, escopo e objetivos                                     |
| `01-banco-de-dados.md` | Modelagem do banco de dados PostgreSQL, tabelas, relacionamentos e migrations     |
| `02-backend.md`        | Arquitetura, estrutura de pastas, endpoints da API, autenticação, testes          |
| `03-frontend.md`       | Arquitetura Flutter, estrutura de pastas, telas, navegação, estado e notificações |
