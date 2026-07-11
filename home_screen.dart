/// Central place for environment/config values.
///
/// Point [apiBaseUrl] at your FastAPI backend. For a device/emulator talking
/// to a server running on your dev machine:
///   - Android emulator -> http://10.0.2.2:8000
///   - iOS simulator    -> http://localhost:8000
///   - Physical device  -> http://<your-lan-ip>:8000
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Backend contract (adjust to match your FastAPI routes):
  //   POST   /designs                 -> { job_id }
  //   GET    /designs/{job_id}        -> DesignJob (status, metrics, urls)
  //   GET    /designs/{job_id}/stl    -> binary STL file
  //   GET    /designs/{job_id}/glb    -> binary GLB file (for in-app preview)
  static String submitEndpoint() => '$apiBaseUrl/designs';
  static String statusEndpoint(String jobId) => '$apiBaseUrl/designs/$jobId';
  static String stlEndpoint(String jobId) => '$apiBaseUrl/designs/$jobId/stl';
  static String glbEndpoint(String jobId) => '$apiBaseUrl/designs/$jobId/glb';

  static const Duration pollInterval = Duration(seconds: 2);
  static const Duration requestTimeout = Duration(seconds: 20);
}
