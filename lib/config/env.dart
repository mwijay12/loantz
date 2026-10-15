/// Application Environment Configuration
///
/// These values can be overridden at build time via:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppEnv {
  AppEnv._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fzlykkwgkydswvnlryhk.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ6bHlra3dna3lkc3d2bmxyeWhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIwNTA1NTAsImV4cCI6MjEwNzYyNjU1MH0.5WsVDMjEPBRDIlYcUge9anedGq59p3_6Ewxfso6LWGk',
  );

  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );
}
