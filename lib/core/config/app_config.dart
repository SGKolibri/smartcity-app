/// Configuração de ambiente do app.
///
/// A base URL pode ser sobrescrita em build/run com:
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000
///
/// Emulador Android usa `10.0.2.2` para alcançar o `localhost` da máquina host.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Namespace Socket.IO do backend (fase 5).
  static String get realtimeUrl => apiBaseUrl;
  static const String realtimeNamespace = '/tempo-real';

  /// Tarifa de referência B4a (PRD §6). O backend também devolve em `GET /kpis`.
  static const double tarifaKwh = 0.58;

  static const Duration httpConnectTimeout = Duration(seconds: 8);
  static const Duration httpReceiveTimeout = Duration(seconds: 15);
}
