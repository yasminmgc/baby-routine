# Baby Routine — Backend
## Especificação `baby-routine-api`

---

## 1. Stack Técnica

| Tecnologia                         | Versão recomendada | Função                           |
| ---------------------------------- | ------------------ | -------------------------------- |
| Node.js                            | 20 LTS             | Runtime                          |
| TypeScript                         | 5.x                | Linguagem                        |
| Express                            | 4.x                | Framework HTTP                   |
| Prisma                             | 5.x                | ORM                              |
| PostgreSQL                         | 15+                | Banco de dados                   |
| jsonwebtoken                       | 9.x                | Autenticação JWT                 |
| bcryptjs                           | 2.x                | Hash de senhas                   |
| Zod                                | 3.x                | Validação de entrada             |
| swagger-jsdoc + swagger-ui-express | latest             | Documentação da API              |
| firebase-admin                     | 12.x               | Envio de notificações push (FCM) |
| node-cron                          | 3.x                | Job scheduler para lembretes     |
| Jest                               | 29.x               | Testes unitários                 |
| Supertest                          | 6.x                | Testes de integração das rotas   |
| ts-jest                            | latest             | Suporte TypeScript no Jest       |
| dotenv                             | 16.x               | Variáveis de ambiente            |

---

## 2. Arquitetura

O projeto segue uma **arquitetura em camadas inspirada na Clean Architecture / Onion Architecture**, adaptada para a escala do projeto sem over-engineering.

```
HTTP Request
    │
    ▼
[ Router (Express) ]
    │
    ▼
[ Controller ]       ← recebe req/res, valida entrada com Zod, chama o Use Case
    │
    ▼
[ Use Case ]         ← regra de negócio pura, sem dependência de framework
    │
    ▼
[ Repository ]       ← abstração do acesso a dados
    │
    ▼
[ Prisma Client ]    ← comunicação com PostgreSQL
```

### Princípios

- **Controllers** nunca contêm regras de negócio — apenas orquestram entrada e saída.
- **Use Cases** são classes ou funções puras, fáceis de testar unitariamente.
- **Repositories** encapsulam todo acesso ao Prisma; os Use Cases nunca importam o Prisma diretamente.
- **Injeção de dependência simples** via construtores (sem container IoC na v1.0).

---

## 3. Estrutura de Pastas

```
baby-routine-api/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
│
├── src/
│   ├── config/
│   │   ├── env.ts              # Leitura e validação das variáveis de ambiente
│   │   ├── firebase.ts         # Inicialização do Firebase Admin SDK
│   │   └── swagger.ts          # Configuração do Swagger
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.routes.ts
│   │   │   ├── auth.usecase.ts
│   │   │   ├── auth.repository.ts
│   │   │   └── auth.schemas.ts
│   │   │
│   │   ├── users/
│   │   │   ├── users.controller.ts
│   │   │   ├── users.routes.ts
│   │   │   ├── users.usecase.ts
│   │   │   ├── users.repository.ts
│   │   │   └── users.schemas.ts
│   │   │
│   │   ├── babies/
│   │   │   ├── babies.controller.ts
│   │   │   ├── babies.routes.ts
│   │   │   ├── babies.usecase.ts
│   │   │   ├── babies.repository.ts
│   │   │   └── babies.schemas.ts
│   │   │
│   │   ├── events/
│   │   │   ├── events.controller.ts
│   │   │   ├── events.routes.ts
│   │   │   ├── events.usecase.ts
│   │   │   ├── events.repository.ts
│   │   │   └── events.schemas.ts
│   │   │
│   │   ├── routines/
│   │   │   ├── routines.controller.ts
│   │   │   ├── routines.routes.ts
│   │   │   ├── routines.usecase.ts
│   │   │   ├── routines.repository.ts
│   │   │   └── routines.schemas.ts
│   │   │
│   │   ├── reminders/
│   │   │   ├── reminders.controller.ts
│   │   │   ├── reminders.routes.ts
│   │   │   ├── reminders.usecase.ts
│   │   │   ├── reminders.repository.ts
│   │   │   └── reminders.schemas.ts
│   │   │
│   │   ├── health/
│   │   │   ├── health.controller.ts
│   │   │   ├── health.routes.ts
│   │   │   ├── health.usecase.ts
│   │   │   └── health.repository.ts
│   │   │
│   │   ├── measurements/
│   │   │   ├── measurements.controller.ts
│   │   │   ├── measurements.routes.ts
│   │   │   ├── measurements.usecase.ts
│   │   │   └── measurements.repository.ts
│   │   │
│   │   ├── notes/
│   │   │   ├── notes.controller.ts
│   │   │   ├── notes.routes.ts
│   │   │   ├── notes.usecase.ts
│   │   │   └── notes.repository.ts
│   │   │
│   │   └── reports/
│   │       ├── reports.controller.ts
│   │       ├── reports.routes.ts
│   │       └── reports.usecase.ts
│   │
│   ├── shared/
│   │   ├── middlewares/
│   │   │   ├── auth.middleware.ts      # Verificação do JWT
│   │   │   ├── error.middleware.ts     # Handler global de erros
│   │   │   └── validate.middleware.ts  # Validação Zod genérica
│   │   ├── errors/
│   │   │   └── AppError.ts             # Classe de erro customizado
│   │   ├── utils/
│   │   │   ├── jwt.ts
│   │   │   ├── bcrypt.ts
│   │   │   └── notifications.ts        # Wrapper para envio via FCM
│   │   └── types/
│   │       └── express.d.ts            # Extensão do tipo Request (userId, etc.)
│   │
│   ├── jobs/
│   │   └── notification.job.ts         # Cron job para disparar lembretes
│   │
│   ├── app.ts                          # Criação e configuração do Express app
│   └── server.ts                       # Ponto de entrada — listen
│
├── tests/
│   ├── unit/
│   │   ├── auth.usecase.spec.ts
│   │   ├── babies.usecase.spec.ts
│   │   ├── events.usecase.spec.ts
│   │   └── ...
│   └── integration/
│       ├── auth.routes.spec.ts
│       ├── babies.routes.spec.ts
│       └── ...
│
├── .env.example
├── jest.config.ts
├── tsconfig.json
└── package.json
```

---

## 4. Autenticação

### Estratégia: JWT (stateless)

- No login, o servidor gera um **Access Token** (JWT) com validade de **7 dias**.
- O token é enviado no header `Authorization: Bearer <token>` em todas as rotas protegidas.
- O payload do JWT contém: `{ sub: userId, email, iat, exp }`.
- O middleware `auth.middleware.ts` valida o token e injeta `req.userId` para uso nos controllers.
- Senhas armazenadas com **bcrypt** (salt rounds: 12).

### Variáveis de ambiente necessárias

```env
JWT_SECRET=your_secret_here
JWT_EXPIRES_IN=7d
```

---

## 5. Controle de Acesso a Bebês

Antes de qualquer operação envolvendo um bebê, o sistema verifica se o usuário autenticado está presente na tabela `baby_caregivers` para aquele bebê. Todo usuário com acesso — seja o criador (`owner`) ou um cuidador convidado (`caregiver`) — pode registrar, visualizar e editar eventos livremente.

```typescript
// Verificação padrão — aplicada em todos os Use Cases de bebê
const caregiver = await babiesRepository.findCaregiver(babyId, userId);
if (!caregiver) throw new AppError('Access denied', 403);
```

Operações destrutivas ou administrativas (excluir o bebê, remover cuidadores) exigem adicionalmente que o usuário seja `owner`:

```typescript
// Verificação de ownership — aplicada apenas em operações administrativas
if (caregiver.role !== 'owner') {
  throw new AppError('Only the owner can perform this action', 403);
}
```

| Operação | `caregiver` | `owner` |
|---|---|---|
| Visualizar dados do bebê | ✅ | ✅ |
| Registrar/editar/remover eventos | ✅ | ✅ |
| Configurar rotinas e lembretes | ✅ | ✅ |
| Adicionar novos cuidadores | ✅ | ✅ |
| Remover outros cuidadores | ❌ | ✅ |
| Excluir o bebê | ❌ | ✅ |

---

## 6. Endpoints da API

Base URL: `https://baby-routine-api.herokuapp.com/api/v1`

### 6.1 Autenticação

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/auth/register` | Criar nova conta | ❌ |
| POST | `/auth/login` | Login e obtenção do JWT | ❌ |
| PATCH | `/auth/fcm-token` | Atualizar token FCM do dispositivo | ✅ |

**POST /auth/register**
```json
// Request
{ "name": "Maria", "email": "maria@email.com", "password": "Password@123" }

// Response 201
{ "id": "uuid", "name": "Maria", "email": "maria@email.com", "token": "jwt..." }
```

**POST /auth/login**
```json
// Request
{ "email": "maria@email.com", "password": "Password@123" }

// Response 200
{ "token": "jwt...", "user": { "id": "uuid", "name": "Maria", "email": "..." } }
```

**PATCH /auth/fcm-token**
```json
// Request
{ "fcmToken": "device_fcm_token_here" }

// Response 200
{ "message": "FCM token updated successfully." }
```

---

### 6.2 Bebês

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies` | Criar perfil de bebê | ✅ |
| GET | `/babies` | Listar bebês do usuário | ✅ |
| GET | `/babies/:id` | Detalhar bebê | ✅ |
| PUT | `/babies/:id` | Atualizar perfil do bebê | ✅ |
| DELETE | `/babies/:id` | Remover bebê | ✅ |
| POST | `/babies/:id/caregivers` | Adicionar responsável pelo e-mail | ✅ |
| DELETE | `/babies/:id/caregivers/:userId` | Remover responsável | ✅ |
| GET | `/babies/:id/caregivers` | Listar responsáveis | ✅ |

**GET /babies**

Retorna apenas os bebês onde o usuário autenticado está presente em `baby_caregivers`. Inclui o `role` do usuário em cada bebê, para que o app possa decidir quais ações exibir (ex: mostrar botão de excluir somente para `owner`).

```json
// Response 200
[
  {
    "id": "uuid",
    "name": "João",
    "birthDate": "2025-01-10",
    "gender": "male",
    "allergies": null,
    "currentUserRole": "owner"
  },
  {
    "id": "uuid-2",
    "name": "Ana",
    "birthDate": "2024-06-20",
    "gender": "female",
    "allergies": null,
    "currentUserRole": "caregiver"
  }
]
```

**POST /babies**

Ao criar um bebê, o Use Case executa uma transação que cria o registro do bebê e insere o usuário em `baby_caregivers` com `role = "owner"` automaticamente.

```json
// Request
{
  "name": "João",
  "birthDate": "2025-01-10",
  "gender": "male",
  "initialWeightKg": 3.5,
  "initialHeightCm": 50.0,
  "allergies": null
}

// Response 201
{
  "id": "uuid",
  "name": "João",
  "birthDate": "2025-01-10",
  "gender": "male",
  "currentUserRole": "owner"
}
```

**POST /babies/:id/caregivers**
```json
// Request
{ "email": "pai@email.com" }

// Response 200
{ "message": "Caregiver added successfully." }
```

---

### 6.3 Eventos da Rotina

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies/:babyId/events` | Registrar evento | ✅ |
| GET | `/babies/:babyId/events` | Listar eventos (com filtros) | ✅ |
| GET | `/babies/:babyId/events/:id` | Detalhar evento | ✅ |
| PUT | `/babies/:babyId/events/:id` | Atualizar evento | ✅ |
| DELETE | `/babies/:babyId/events/:id` | Remover evento | ✅ |

**Query params para listagem:**
- `type` — `feeding | sleep | diaper | bath | appointment | vaccination | medication`
- `startDate` — `YYYY-MM-DD`
- `endDate` — `YYYY-MM-DD`
- `page` — número da página (padrão: 1)
- `limit` — itens por página (padrão: 20, máx: 100)

**POST /babies/:babyId/events**
```json
// Request
{
  "eventType": "feeding",
  "occurredAt": "2026-05-08T14:30:00Z",
  "details": {
    "feedingType": "bottle",
    "amountMl": 120
  },
  "notes": "Drank well"
}
```

---

### 6.4 Rotinas

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies/:babyId/routines` | Criar rotina recorrente | ✅ |
| GET | `/babies/:babyId/routines` | Listar rotinas | ✅ |
| PUT | `/babies/:babyId/routines/:id` | Atualizar rotina | ✅ |
| DELETE | `/babies/:babyId/routines/:id` | Remover rotina | ✅ |
| PATCH | `/babies/:babyId/routines/:id/toggle` | Ativar/desativar rotina | ✅ |

**POST /babies/:babyId/routines**
```json
// Request
{
  "activityType": "feeding",
  "intervalMinutes": 180,
  "defaultStartTime": "06:00"
}
```

---

### 6.5 Lembretes

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies/:babyId/reminders` | Criar lembrete manual | ✅ |
| GET | `/babies/:babyId/reminders` | Listar lembretes | ✅ |
| PUT | `/babies/:babyId/reminders/:id` | Atualizar lembrete | ✅ |
| DELETE | `/babies/:babyId/reminders/:id` | Remover lembrete | ✅ |

---

### 6.6 Checklist Diário

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| GET | `/babies/:babyId/checklist` | Checklist do dia (ou data específica) | ✅ |

**Query params:** `date` — `YYYY-MM-DD` (padrão: hoje)

**Response 200**
```json
{
  "date": "2026-05-08",
  "items": [
    {
      "type": "feeding",
      "scheduledTime": "06:00",
      "occurredAt": "2026-05-08T06:15:00Z",
      "status": "completed",
      "eventId": "uuid"
    },
    {
      "type": "feeding",
      "scheduledTime": "09:00",
      "occurredAt": null,
      "status": "pending",
      "eventId": null
    }
  ]
}
```

---

### 6.7 Histórico de Saúde

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| GET | `/babies/:babyId/health` | Listar histórico de saúde | ✅ |

**Query params:** `type` — `appointment | vaccination | medication | exam`

---

### 6.8 Medidas de Crescimento

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies/:babyId/measurements` | Registrar medida | ✅ |
| GET | `/babies/:babyId/measurements` | Listar medidas | ✅ |
| DELETE | `/babies/:babyId/measurements/:id` | Remover medida | ✅ |

---

### 6.9 Anotações

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| POST | `/babies/:babyId/notes` | Criar anotação | ✅ |
| GET | `/babies/:babyId/notes` | Listar anotações | ✅ |
| PUT | `/babies/:babyId/notes/:id` | Atualizar anotação | ✅ |
| DELETE | `/babies/:babyId/notes/:id` | Remover anotação | ✅ |

---

### 6.10 Relatórios

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| GET | `/babies/:babyId/reports/sleep` | Horas de sono por dia | ✅ |
| GET | `/babies/:babyId/reports/feeding` | Frequência de mamadas por dia | ✅ |
| GET | `/babies/:babyId/reports/diapers` | Trocas de fralda por dia | ✅ |
| GET | `/babies/:babyId/reports/growth` | Evolução de peso, altura e PC | ✅ |
| GET | `/babies/:babyId/reports/medication` | Histórico de medicações | ✅ |

**Query params comuns:** `startDate`, `endDate` (formato `YYYY-MM-DD`)

---

## 7. Tratamento de Erros

Todas as rotas retornam erros no formato padronizado:

```json
{
  "status": "error",
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

| HTTP | Código | Situação |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Dados de entrada inválidos |
| 401 | `UNAUTHORIZED` | Token ausente ou inválido |
| 403 | `FORBIDDEN` | Usuário sem acesso ao recurso |
| 404 | `NOT_FOUND` | Recurso não encontrado |
| 409 | `CONFLICT` | Conflito (ex: e-mail já cadastrado) |
| 500 | `INTERNAL_ERROR` | Erro interno não tratado |

---

## 8. Notificações Push (FCM)

### Fluxo

1. O app Flutter, após o login, registra o **FCM token** do dispositivo via `PATCH /auth/fcm-token`.
2. O backend armazena o token na coluna `users.fcm_token`.
3. Um **cron job** (`node-cron`) roda a cada minuto, consulta `reminders` com `trigger_at <= now AND sent = false AND active = true`.
4. Para cada lembrete encontrado, envia a notificação push via **Firebase Admin SDK** e marca `sent = true`.

### Configuração Firebase

```env
FIREBASE_PROJECT_ID=baby-routine-xxx
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
```

### Exemplo de disparo

```typescript
// src/shared/utils/notifications.ts
import { getMessaging } from 'firebase-admin/messaging';

export async function sendPushNotification(
  fcmToken: string,
  title: string,
  body: string
): Promise<void> {
  await getMessaging().send({
    token: fcmToken,
    notification: { title, body },
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default' } } },
  });
}
```

---

## 9. Variáveis de Ambiente

```env
# Database
DATABASE_URL=postgresql://user:pass@host:5432/baby_routine

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# Firebase
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=

# App
PORT=3000
NODE_ENV=production
```

---

## 10. Estratégia de Testes

### Testes Unitários (`tests/unit/`)

- Testam os **Use Cases** de forma isolada.
- Dependências (repositories) são **mockadas** com Jest (`jest.fn()`).
- Cada Use Case deve ter cobertura dos cenários: sucesso, erros de negócio e edge cases.

```typescript
// Exemplo: tests/unit/babies.usecase.spec.ts
describe('CreateBabyUseCase', () => {
  it('should create a baby with valid data', async () => { ... });
  it('should throw error if user does not exist', async () => { ... });
});
```

### Testes de Integração (`tests/integration/`)

- Testam as **rotas HTTP** de ponta a ponta usando **Supertest**.
- Utilizam um banco PostgreSQL separado para testes (variável `DATABASE_URL` de teste).
- Cada suite limpa as tabelas relevantes no `beforeEach`.

```typescript
// Exemplo: tests/integration/auth.routes.spec.ts
describe('POST /auth/register', () => {
  it('should return 201 with token for valid data', async () => {
    const res = await request(app).post('/api/v1/auth/register').send({ ... });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('token');
  });

  it('should return 409 if email already exists', async () => { ... });
  it('should return 400 for invalid input', async () => { ... });
});
```

### Cobertura mínima esperada (v1.0)

| Camada | Meta |
|---|---|
| Use Cases | 80% |
| Rotas críticas (auth, babies, events) | 70% |

### Scripts

```json
// package.json
"scripts": {
  "test": "jest",
  "test:unit": "jest tests/unit",
  "test:integration": "jest tests/integration",
  "test:coverage": "jest --coverage"
}
```

---

## 11. Documentação Swagger

Disponível em `GET /api/v1/docs` após subir o servidor.

Gerada automaticamente via **swagger-jsdoc** a partir das anotações nos arquivos de rotas. Cada endpoint deve documentar sumário, parâmetros, body schema e todas as respostas possíveis (200, 201, 400, 401, 403, 404, 500).

---

## 12. Deploy no Heroku

```bash
# Criar app
heroku create baby-routine-api

# Adicionar PostgreSQL
heroku addons:create heroku-postgresql:essential-0

# Configurar variáveis de ambiente
heroku config:set JWT_SECRET=... FIREBASE_PROJECT_ID=... # etc.

# Deploy
git push heroku main

# Executar migrations em produção
heroku run npx prisma migrate deploy
```

### Procfile

```
web: node dist/server.js
release: npx prisma migrate deploy
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```
