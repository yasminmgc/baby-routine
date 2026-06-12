# Baby Routine — Banco de Dados
## Especificação PostgreSQL + Prisma

---

## 1. Tecnologias

| Tecnologia | Versão recomendada |
|---|---|
| PostgreSQL | 15+ |
| Prisma ORM | 5.x |
| Hospedagem | Heroku Postgres (plano Essential) |

---

## 2. Convenções

- Todos os IDs são `UUID` gerados pelo banco (`gen_random_uuid()`).
- Timestamps sempre em UTC, tipo `TIMESTAMP WITH TIME ZONE`.
- Nomes de tabelas em `snake_case`, plural, em inglês.
- Chaves estrangeiras nomeadas como `{referenced_table}_id`.
- Campos obrigatórios marcados como `NOT NULL`.
- Soft delete **não utilizado** na v1.0 — exclusão é física.

---

## 3. Modelo de Acesso — Regras Fundamentais

O sistema opera sobre as seguintes regras de acesso:

| Regra | Descrição |
|---|---|
| **Um usuário pode cuidar de vários bebês** | Ex: mãe cuida de dois filhos |
| **Um bebê pode ter vários cuidadores** | Ex: pai, mãe, avó, babá |
| **Todo cuidador tem acesso igual aos dados do bebê** | Qualquer cuidador pode registrar qualquer evento |
| **O criador do bebê é automaticamente o primeiro cuidador** | Com papel `owner` em `baby_caregivers` |
| **Somente o `owner` pode excluir o bebê ou remover outros cuidadores** | Regra de negócio aplicada no Use Case |
| **Qualquer evento registrado guarda quem o registrou** | Campo `user_id` em todas as tabelas de eventos |

### Fluxo de acesso ao abrir o app

```
Usuário faz login
    │
    ▼
Sistema busca todos os bebês onde o usuário
está presente em baby_caregivers
    │
    ▼
Usuário vê a lista de bebês e seleciona um
    │
    ▼
Usuário pode registrar qualquer evento para
aquele bebê — o registro guarda o user_id de quem fez
```

---

## 4. Diagrama de Entidades

```
users ──────────────────────────────────────────────────────────┐
  │                                                              │
  │ (N:N via baby_caregivers)                                   │
  ▼                                                              │
babies                                                           │
  ├── baby_caregivers  (quem tem acesso ao bebê + papel)        │
  │       └── user_id ─────────────────────────────────────────►┘
  ├── routine_events   (baby_id + user_id de quem registrou)
  ├── routines         (baby_id + user_id de quem configurou)
  ├── reminders        (baby_id + user_id destinatário)
  ├── health_records   (baby_id + user_id de quem registrou)
  ├── growth_measurements (baby_id + user_id de quem mediu)
  └── notes            (baby_id + user_id de quem anotou)
```

---

## 5. Schema Prisma

```prisma
// schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─────────────────────────────────────────
// USERS
// ─────────────────────────────────────────

model User {
  id           String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  name         String   @db.VarChar(100)
  email        String   @unique @db.VarChar(150)
  passwordHash String   @map("password_hash") @db.VarChar(255)
  fcmToken     String?  @map("fcm_token") @db.VarChar(255)
  createdAt    DateTime @default(now()) @map("created_at") @db.Timestamptz

  // Bebês onde este usuário é cuidador (inclui os que ele criou)
  caregiverOf    BabyCaregiver[]
  routineEvents  RoutineEvent[]
  routines       Routine[]
  reminders      Reminder[]
  notes          Note[]
  healthRecords  HealthRecord[]
  measurements   GrowthMeasurement[]

  @@map("users")
}

// ─────────────────────────────────────────
// BABIES
// ─────────────────────────────────────────

model Baby {
  id              String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  name            String   @db.VarChar(100)
  birthDate       DateTime @map("birth_date") @db.Date
  gender          String?  @db.VarChar(10)   // male | female | other
  initialWeightKg Decimal? @map("initial_weight_kg") @db.Decimal(5, 3)
  initialHeightCm Decimal? @map("initial_height_cm") @db.Decimal(5, 2)
  allergies       String?  @db.Text
  createdAt       DateTime @default(now()) @map("created_at") @db.Timestamptz

  // Todos os cuidadores deste bebê (N:N com users)
  caregivers         BabyCaregiver[]
  routineEvents      RoutineEvent[]
  routines           Routine[]
  reminders          Reminder[]
  healthRecords      HealthRecord[]
  growthMeasurements GrowthMeasurement[]
  notes              Note[]

  @@map("babies")
}

// ─────────────────────────────────────────
// BABY CAREGIVERS (N:N users ↔ babies)
// ─────────────────────────────────────────
//
// Esta é a tabela central de controle de acesso.
// Todo usuário que precisa acessar um bebê DEVE estar aqui.
//
// Ao criar um bebê, o criador é automaticamente inserido
// nesta tabela com role = "owner" (regra do Use Case).
//
// role values:
//   owner     — criou o bebê; pode excluí-lo e gerenciar cuidadores
//   caregiver — convidado; pode registrar e visualizar eventos

model BabyCaregiver {
  id        String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId    String   @map("baby_id") @db.Uuid
  userId    String   @map("user_id") @db.Uuid
  role      String   @default("caregiver") @db.VarChar(20)
  // role values: owner | caregiver
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby Baby @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([babyId, userId])
  @@index([userId])   // busca rápida: "quais bebês este usuário cuida?"
  @@map("baby_caregivers")
}

// ─────────────────────────────────────────
// ROUTINE EVENTS
// ─────────────────────────────────────────
//
// Registra cada evento de rotina do bebê.
// baby_id → a quem pertence o evento
// user_id → quem registrou o evento (mãe, pai, babá, etc.)
//
// eventType values:
// feeding | sleep | diaper | bath | appointment | vaccination | medication

model RoutineEvent {
  id          String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId      String    @map("baby_id") @db.Uuid
  userId      String    @map("user_id") @db.Uuid
  routineId   String?   @map("routine_id") @db.Uuid
  eventType   String    @map("event_type") @db.VarChar(30)
  scheduledAt DateTime? @map("scheduled_at") @db.Timestamptz
  occurredAt  DateTime? @map("occurred_at") @db.Timestamptz
  status      String    @default("completed") @db.VarChar(20)
  // status values: completed | missed | cancelled
  details     Json?     @db.JsonB
  notes       String?   @db.Text
  createdAt   DateTime  @default(now()) @map("created_at") @db.Timestamptz

  baby    Baby     @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user    User     @relation(fields: [userId], references: [id])
  routine Routine? @relation(fields: [routineId], references: [id])

  @@index([babyId, eventType])
  @@index([babyId, occurredAt])
  @@map("routine_events")
}

// ─────────────────────────────────────────
// ROUTINES
// ─────────────────────────────────────────
//
// Configuração de recorrência de atividades do bebê.
// baby_id → a qual bebê a rotina pertence
// user_id → quem configurou a rotina

model Routine {
  id               String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId           String   @map("baby_id") @db.Uuid
  userId           String   @map("user_id") @db.Uuid
  activityType     String   @map("activity_type") @db.VarChar(30)
  intervalMinutes  Int?     @map("interval_minutes")
  defaultStartTime String?  @map("default_start_time") @db.VarChar(5) // "HH:MM"
  active           Boolean  @default(true)
  createdAt        DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby      Baby           @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user      User           @relation(fields: [userId], references: [id])
  events    RoutineEvent[]
  reminders Reminder[]

  @@map("routines")
}

// ─────────────────────────────────────────
// REMINDERS
// ─────────────────────────────────────────
//
// Lembretes de eventos futuros.
// baby_id  → a qual bebê o lembrete pertence
// user_id  → quem receberá a notificação push
//
// Observação: um lembrete é sempre destinado a um usuário
// específico. Se todos os cuidadores devem ser notificados,
// deve-se criar um lembrete por cuidador (gerado pelo Use Case).

model Reminder {
  id           String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId       String   @map("baby_id") @db.Uuid
  userId       String   @map("user_id") @db.Uuid
  routineId    String?  @map("routine_id") @db.Uuid
  reminderType String   @map("reminder_type") @db.VarChar(30)
  description  String   @db.VarChar(255)
  triggerAt    DateTime @map("trigger_at") @db.Timestamptz
  recurrence   String?  @db.VarChar(20) // none | daily | interval
  active       Boolean  @default(true)
  sent         Boolean  @default(false)
  createdAt    DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby    Baby     @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user    User     @relation(fields: [userId], references: [id])
  routine Routine? @relation(fields: [routineId], references: [id])

  @@index([triggerAt, sent, active])
  @@map("reminders")
}

// ─────────────────────────────────────────
// HEALTH RECORDS
// ─────────────────────────────────────────
//
// Histórico de saúde do bebê (consultas, vacinas, medicamentos, exames).
// baby_id → a quem pertence o registro
// user_id → quem registrou

model HealthRecord {
  id          String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId      String   @map("baby_id") @db.Uuid
  userId      String   @map("user_id") @db.Uuid
  recordType  String   @map("record_type") @db.VarChar(30)
  // appointment | vaccination | medication | exam
  occurredAt  DateTime @map("occurred_at") @db.Timestamptz
  title       String   @db.VarChar(150)
  description String?  @db.Text
  createdAt   DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby Baby @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user User @relation(fields: [userId], references: [id])

  @@index([babyId, recordType])
  @@map("health_records")
}

// ─────────────────────────────────────────
// GROWTH MEASUREMENTS
// ─────────────────────────────────────────
//
// Medidas de crescimento do bebê.
// baby_id → a quem pertence a medida
// user_id → quem registrou a medida

model GrowthMeasurement {
  id                  String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId              String   @map("baby_id") @db.Uuid
  userId              String   @map("user_id") @db.Uuid
  measuredAt          DateTime @map("measured_at") @db.Date
  weightKg            Decimal? @map("weight_kg") @db.Decimal(5, 3)
  heightCm            Decimal? @map("height_cm") @db.Decimal(5, 2)
  headCircumferenceCm Decimal? @map("head_circumference_cm") @db.Decimal(5, 2)
  notes               String?  @db.Text
  createdAt           DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby Baby @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user User @relation(fields: [userId], references: [id])

  @@map("growth_measurements")
}

// ─────────────────────────────────────────
// NOTES
// ─────────────────────────────────────────
//
// Anotações personalizadas sobre o bebê.
// baby_id → a quem pertence a anotação
// user_id → quem escreveu

model Note {
  id        String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  babyId    String   @map("baby_id") @db.Uuid
  userId    String   @map("user_id") @db.Uuid
  content   String   @db.Text
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamptz

  baby Baby @relation(fields: [babyId], references: [id], onDelete: Cascade)
  user User @relation(fields: [userId], references: [id])

  @@map("notes")
}
```

---

## 6. Regra de Negócio: Criação de Bebê

Ao criar um novo bebê, o Use Case deve executar as duas operações em uma **transação única**:

```typescript
// babies.usecase.ts (pseudo-código)

async function createBaby(userId: string, data: CreateBabyDTO) {
  return await prisma.$transaction(async (tx) => {
    // 1. Cria o bebê
    const baby = await tx.baby.create({ data });

    // 2. Insere o criador como owner em baby_caregivers
    await tx.babyCaregiver.create({
      data: {
        babyId: baby.id,
        userId: userId,
        role: 'owner',
      },
    });

    return baby;
  });
}
```

Isso garante que o criador **sempre** aparece na listagem de bebês e tem acesso garantido via `baby_caregivers`, sem depender de nenhuma lógica especial de consulta.

---

## 7. Regra de Negócio: Verificação de Acesso

Em **todos** os Use Cases que operam sobre um bebê, a primeira ação é verificar se o usuário autenticado é cuidador daquele bebê:

```typescript
// Verificação padrão aplicada em todos os Use Cases de bebê
const caregiver = await prisma.babyCaregiver.findUnique({
  where: { babyId_userId: { babyId, userId } },
});

if (!caregiver) throw new AppError('Access denied', 403);
```

Para operações exclusivas do `owner` (excluir bebê, remover cuidadores):

```typescript
if (caregiver.role !== 'owner') {
  throw new AppError('Only the owner can perform this action', 403);
}
```

---

## 8. Estrutura do Campo `details` (JSON) por Tipo de Evento

O campo `details` em `routine_events` é flexível e varia conforme o `eventType`:

### feeding
```json
{
  "feedingType": "bottle | breast | solids",
  "amountMl": 120,
  "durationMin": 15
}
```

### sleep
```json
{
  "startTime": "2026-05-08T14:00:00Z",
  "endTime": "2026-05-08T15:30:00Z",
  "durationMin": 90,
  "location": "crib | bed | arms"
}
```

### diaper
```json
{
  "type": "pee | poop | both",
  "color": "yellow | green | brown",
  "consistency": "normal | pasty | liquid",
  "rash": false
}
```

### bath
```json
{
  "temperature": "warm"
}
```

### appointment
```json
{
  "professional": "Dr. Ana",
  "specialty": "Pediatrics",
  "appointmentType": "routine | urgent",
  "recommendations": "Gain weight",
  "requestedExams": ["blood test"]
}
```

### vaccination
```json
{
  "vaccineName": "MMR",
  "lot": "123456",
  "site": "right thigh",
  "appliedBy": "Nurse Carla",
  "reactions": "mild fever"
}
```

### medication
```json
{
  "medicationName": "Paracetamol",
  "dose": "2ml",
  "reason": "Fever"
}
```

---

## 9. Índices Relevantes

| Tabela | Campos indexados | Justificativa |
|---|---|---|
| `baby_caregivers` | `(baby_id, user_id)` — unique | Evitar duplicidade e verificação de acesso |
| `baby_caregivers` | `(user_id)` | Busca rápida: "quais bebês este usuário cuida?" |
| `routine_events` | `(baby_id, event_type)` | Filtro por tipo na listagem |
| `routine_events` | `(baby_id, occurred_at)` | Consultas por data e relatórios |
| `reminders` | `(trigger_at, sent, active)` | Job de disparo de notificações |
| `health_records` | `(baby_id, record_type)` | Filtro no histórico de saúde |

---

## 10. Estratégia de Migrations

```bash
# Criar nova migration
npx prisma migrate dev --name migration_name

# Aplicar em produção
npx prisma migrate deploy

# Inspecionar o banco
npx prisma studio
```

Regras:
- Nunca editar migrations já aplicadas em produção.
- Toda alteração de schema gera uma nova migration.
- Migrations ficam versionadas em `prisma/migrations/` e commitadas no repositório.
