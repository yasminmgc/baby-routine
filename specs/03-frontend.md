# Baby Routine — Frontend
## Especificação `baby-routine-app` (Flutter)

---

## 1. Stack Técnica

| Tecnologia | Versão recomendada | Função |
|---|---|---|
| Flutter SDK | 3.22+ | Framework multiplataforma |
| Dart | 3.4+ | Linguagem |
| flutter_riverpod | 2.x | Gerenciamento de estado |
| go_router | 13.x | Navegação declarativa |
| dio | 5.x | Cliente HTTP |
| flutter_secure_storage | 9.x | Armazenamento seguro do JWT |
| firebase_core | latest | Inicialização Firebase |
| firebase_messaging | latest | Notificações push (FCM) |
| flutter_local_notifications | latest | Exibição local de notificações |
| intl | latest | Formatação de datas (pt-BR) |
| fl_chart | latest | Gráficos nos relatórios |
| freezed + json_serializable | latest | Modelos imutáveis e serialização JSON |
| build_runner | latest | Geração de código (freezed/json) |
| flutter_dotenv | latest | Variáveis de ambiente |
| google_fonts | latest | Tipografia (Nunito) |

---

## 2. Suporte a Plataformas

| Plataforma | Suporte |
|---|---|
| Android | ✅ (API 21+) |
| iOS | ✅ (iOS 13+) |
| Web | ❌ (fora do escopo v1.0) |
| Desktop | ❌ (fora do escopo v1.0) |

---

## 3. Arquitetura

O projeto segue a arquitetura **Feature-First** com separação de responsabilidades em camadas, compatível com o uso do Riverpod:

```
Presentation (Widgets/Screens)
        │
        ▼
   Controllers (Riverpod Notifiers)
        │
        ▼
   Repositories (abstrações)
        │
        ▼
   Data Sources (API via Dio)
```

### Camadas por feature

- **`presentation/`** — Screens (páginas) e Widgets reutilizáveis.
- **`controllers/`** — `AsyncNotifier` do Riverpod; orquestram estado e chamam repositories.
- **`repositories/`** — Interface + implementação; isolam a fonte de dados.
- **`models/`** — Classes Dart geradas com `freezed` + `json_serializable`.
- **`services/`** — Serviços transversais (ex: `NotificationService`).

---

## 4. Estrutura de Pastas

```
baby-routine-app/
├── android/
├── ios/
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   ├── main.dart                        # Ponto de entrada
│   ├── app.dart                         # MaterialApp + GoRouter setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart       # Base URL e endpoints
│   │   │   └── app_colors.dart          # Paleta de cores do app
│   │   ├── errors/
│   │   │   └── app_exception.dart       # Exceções customizadas
│   │   ├── network/
│   │   │   ├── dio_client.dart          # Configuração do Dio (interceptors)
│   │   │   └── auth_interceptor.dart    # Injeção automática do JWT
│   │   ├── storage/
│   │   │   └── secure_storage.dart      # Wrapper do flutter_secure_storage
│   │   └── utils/
│   │       ├── date_formatter.dart      # Formatação de datas pt-BR
│   │       └── validators.dart          # Validadores de formulário
│   │
│   ├── features/
│   │   │
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   ├── user.dart
│   │   │   │   └── user.g.dart
│   │   │   ├── repositories/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   └── presentation/
│   │   │       ├── splash_screen.dart
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   │
│   │   ├── babies/
│   │   │   ├── models/
│   │   │   │   ├── baby.dart
│   │   │   │   └── baby.g.dart
│   │   │   ├── repositories/
│   │   │   │   ├── baby_repository.dart
│   │   │   │   └── baby_repository_impl.dart
│   │   │   ├── controllers/
│   │   │   │   └── baby_controller.dart
│   │   │   └── presentation/
│   │   │       ├── select_baby_screen.dart
│   │   │       ├── create_baby_screen.dart
│   │   │       ├── edit_baby_screen.dart
│   │   │       └── caregivers_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   │   └── checklist_controller.dart
│   │   │   └── presentation/
│   │   │       ├── home_screen.dart
│   │   │       └── checklist_widget.dart
│   │   │
│   │   ├── events/
│   │   │   ├── models/
│   │   │   │   ├── routine_event.dart
│   │   │   │   └── routine_event.g.dart
│   │   │   ├── repositories/
│   │   │   │   ├── event_repository.dart
│   │   │   │   └── event_repository_impl.dart
│   │   │   ├── controllers/
│   │   │   │   └── event_controller.dart
│   │   │   └── presentation/
│   │   │       ├── feeding_screen.dart
│   │   │       ├── sleep_screen.dart
│   │   │       ├── diaper_screen.dart
│   │   │       ├── bath_screen.dart
│   │   │       ├── appointment_screen.dart
│   │   │       ├── vaccination_screen.dart
│   │   │       └── medication_screen.dart
│   │   │
│   │   ├── routines/
│   │   │   ├── models/
│   │   │   │   ├── routine.dart
│   │   │   │   └── routine.g.dart
│   │   │   ├── repositories/
│   │   │   │   ├── routine_repository.dart
│   │   │   │   └── routine_repository_impl.dart
│   │   │   ├── controllers/
│   │   │   │   └── routine_controller.dart
│   │   │   └── presentation/
│   │   │       └── configure_routines_screen.dart
│   │   │
│   │   ├── health/
│   │   │   ├── controllers/
│   │   │   │   └── health_controller.dart
│   │   │   └── presentation/
│   │   │       └── health_history_screen.dart
│   │   │
│   │   ├── reports/
│   │   │   ├── controllers/
│   │   │   │   └── report_controller.dart
│   │   │   └── presentation/
│   │   │       └── reports_screen.dart
│   │   │
│   │   └── notes/
│   │       ├── models/
│   │       │   ├── note.dart
│   │       │   └── note.g.dart
│   │       ├── repositories/
│   │       │   ├── note_repository.dart
│   │       │   └── note_repository_impl.dart
│   │       ├── controllers/
│   │       │   └── note_controller.dart
│   │       └── presentation/
│   │           └── notes_screen.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── app_button.dart          # Botão padrão do app
│       │   ├── app_text_field.dart      # Campo de texto padrão
│       │   ├── app_loading.dart         # Indicador de carregamento
│       │   ├── app_snackbar.dart        # Feedback de erros/sucesso
│       │   ├── event_card.dart          # Card de evento na listagem
│       │   └── health_record_item.dart  # Item do histórico de saúde
│       └── providers/
│           ├── dio_provider.dart
│           ├── storage_provider.dart
│           └── selected_baby_provider.dart  # Bebê ativo na sessão
│
├── test/
│   ├── unit/
│   │   └── auth_controller_test.dart
│   └── widget/
│       └── login_screen_test.dart
│
├── pubspec.yaml
└── .env
```

---

## 5. Gerenciamento de Estado com Riverpod

O projeto utiliza **Riverpod 2.x** com `AsyncNotifier` para estados assíncronos e `Notifier` para estados síncronos.

### Padrão adotado

```dart
// features/auth/controllers/auth_controller.dart

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(secureStorageProvider).saveToken(token);
    });
  }
}
```

### Providers globais essenciais

```dart
// shared/providers/selected_baby_provider.dart
final selectedBabyProvider = StateProvider<Baby?>((ref) => null);

// shared/providers/dio_provider.dart
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(secureStorageProvider));
});
```

---

## 6. Navegação com GoRouter

```dart
// app.dart

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final token = await SecureStorage().getToken();
    final isLoggedIn = token != null;
    final publicRoutes = ['/login', '/register', '/splash'];

    if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash',              builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',               builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',            builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/babies',              builder: (_, __) => const SelectBabyScreen()),
    GoRoute(path: '/home',                builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/feeding',             builder: (_, __) => const FeedingScreen()),
    GoRoute(path: '/sleep',               builder: (_, __) => const SleepScreen()),
    GoRoute(path: '/diaper',              builder: (_, __) => const DiaperScreen()),
    GoRoute(path: '/bath',                builder: (_, __) => const BathScreen()),
    GoRoute(path: '/appointment',         builder: (_, __) => const AppointmentScreen()),
    GoRoute(path: '/vaccination',         builder: (_, __) => const VaccinationScreen()),
    GoRoute(path: '/medication',          builder: (_, __) => const MedicationScreen()),
    GoRoute(path: '/routines',            builder: (_, __) => const ConfigureRoutinesScreen()),
    GoRoute(path: '/health',              builder: (_, __) => const HealthHistoryScreen()),
    GoRoute(path: '/reports',             builder: (_, __) => const ReportsScreen()),
    GoRoute(path: '/notes',               builder: (_, __) => const NotesScreen()),
    GoRoute(path: '/caregivers',          builder: (_, __) => const CaregiversScreen()),
  ],
);
```

---

## 7. Cliente HTTP (Dio)

```dart
// core/network/dio_client.dart

class DioClient {
  final Dio _dio;
  final SecureStorage _storage;

  DioClient(this._storage) : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _dio.interceptors.add(AuthInterceptor(_storage));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) =>
      _dio.delete(path);
}
```

```dart
// core/network/auth_interceptor.dart

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Redirecionar para tela de login
    }
    handler.next(err);
  }
}
```

---

## 8. Modelos com Freezed

```dart
// features/babies/models/baby.dart

@freezed
class Baby with _$Baby {
  const factory Baby({
    required String id,
    required String name,
    required DateTime birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  }) = _Baby;

  factory Baby.fromJson(Map<String, dynamic> json) => _$BabyFromJson(json);
}
```

```dart
// features/events/models/routine_event.dart

@freezed
class RoutineEvent with _$RoutineEvent {
  const factory RoutineEvent({
    required String id,
    required String eventType,
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  }) = _RoutineEvent;

  factory RoutineEvent.fromJson(Map<String, dynamic> json) =>
      _$RoutineEventFromJson(json);
}
```

Após criar ou alterar modelos, executar:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 9. Notificações Push (FCM)

### Configuração

1. Criar projeto no [Firebase Console](https://console.firebase.google.com).
2. Adicionar os apps Android e iOS ao projeto.
3. Baixar `google-services.json` (Android → `android/app/`) e `GoogleService-Info.plist` (iOS → `ios/Runner/`).
4. Adicionar `firebase_messaging` ao `pubspec.yaml`.

### Fluxo no app

```dart
// main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  runApp(const ProviderScope(child: App()));
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Exibir notificação local via flutter_local_notifications
}
```

```dart
// Após login bem-sucedido, no AuthController:
final fcmToken = await FirebaseMessaging.instance.getToken();
if (fcmToken != null) {
  await ref.read(authRepositoryProvider).updateFcmToken(fcmToken);
}
```

### Permissões iOS

No arquivo `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

---

## 10. Fluxo de Telas e Navegação

```
SplashScreen
  ├── [JWT válido] → SelectBabyScreen
  └── [sem JWT]   → LoginScreen
                      └── RegisterScreen

SelectBabyScreen
  ├── [seleciona bebê] → HomeScreen
  └── [+ Adicionar]   → CreateBabyScreen

HomeScreen (menu principal com o bebê selecionado)
  ├── Mamadeira  → FeedingScreen
  ├── Sono       → SleepScreen
  ├── Fralda     → DiaperScreen
  ├── Vacina     → VaccinationScreen
  ├── Consultas  → AppointmentScreen
  ├── Medicação  → MedicationScreen
  ├── ⚙ Config  → ConfigureRoutinesScreen
  └── Histórico  → HealthHistoryScreen
                     ├── ReportsScreen
                     └── NotesScreen
```

---

## 11. Design System

### Paleta de Cores

```dart
// core/constants/app_colors.dart

class AppColors {
  static const lilac        = Color(0xFFB39DDB);  // roxo suave — cor primária
  static const lilacDark    = Color(0xFF7E57C2);  // roxo escuro — botões
  static const mint         = Color(0xFF80CBC4);  // verde água — destaque
  static const peach        = Color(0xFFFCE4D6);  // pêssego — fundo warm
  static const lavender     = Color(0xFFE8EAF6);  // lavanda — fundo cool

  static const white        = Color(0xFFFFFFFF);
  static const lightGray    = Color(0xFFF5F5F5);
  static const textGray     = Color(0xFF757575);
  static const textDark     = Color(0xFF212121);

  static const success      = Color(0xFF66BB6A);
  static const error        = Color(0xFFEF5350);
  static const warning      = Color(0xFFFFA726);
}
```

### Tipografia

Fonte principal: **Nunito** — arredondada, amigável e legível, ideal para apps de cuidado infantil.

```dart
// Importada via google_fonts no ThemeData:
textTheme: GoogleFonts.nunitoTextTheme(),
```

### Tema Global

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lilac),
  useMaterial3: true,
  textTheme: GoogleFonts.nunitoTextTheme(),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: AppColors.lightGray,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lilacDark,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 52),
    ),
  ),
)
```

---

## 12. Tratamento de Erros no Frontend

```dart
// Nos controllers, usar AsyncValue.guard:
state = await AsyncValue.guard(() async {
  // chamada ao repository
});

// Nas screens, escutar erros com ref.listen:
ref.listen(myProvider, (_, state) {
  if (state.hasError) {
    AppSnackbar.showError(context, state.error.toString());
  }
});
```

```dart
// core/errors/app_exception.dart

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
```

---

## 13. pubspec.yaml

```yaml
name: baby_routine_app
description: Baby Routine — App de gestão da rotina infantil

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter

  # Estado e navegação
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.1

  # HTTP e armazenamento
  dio: ^5.4.3
  flutter_secure_storage: ^9.2.2
  flutter_dotenv: ^5.1.0

  # Firebase
  firebase_core: ^3.1.0
  firebase_messaging: ^15.0.1
  flutter_local_notifications: ^17.1.2

  # Modelos e serialização
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # UI
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  flutter_lints: ^4.0.0
```

---

## 14. Variáveis de Ambiente

```env
# .env
API_BASE_URL=https://baby-routine-api.herokuapp.com/api/v1
```

```dart
// core/constants/api_constants.dart
class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
}
```

---

## 15. Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Gerar código (freezed, json_serializable, riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Rodar no Android
flutter run -d android

# Rodar no iOS
flutter run -d ios

# Executar testes
flutter test

# Build release Android (APK)
flutter build apk --release

# Build release iOS
flutter build ios --release
```
