/// Supabase Configuration
///
/// PENTING: Ganti nilai di bawah ini dengan kredensial dari Supabase Dashboard
/// Settings → API → Project URL dan anon/public key
///
/// JANGAN commit file ini ke repository publik!
/// Tambahkan ke .gitignore untuk keamanan.
library;

class SupabaseConfig {
  // Ganti dengan Project URL dari Supabase Dashboard
  static const String supabaseUrl = 'https://lnnmpqyxpzwsgieesxtv.supabase.co';

  // Ganti dengan anon/public key dari Supabase Dashboard
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxubm1wcXl4cHp3c2dpZWVzeHR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0Mjk0MDksImV4cCI6MjA4MTAwNTQwOX0.OrMZGduQg67qaER13_0p1ndtn9-H1OBByLbOHSIoDvU';

  // Storage bucket name
  static const String bookImagesBucket = 'book-images';
}
