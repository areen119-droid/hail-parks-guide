class AppConfig {
  /// False until the app is connected to Firebase (see main.dart).
  /// Screens that need Firebase are replaced with a notice while it is false.
  static bool firebaseReady = false;
}
