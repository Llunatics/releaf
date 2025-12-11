import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_state.dart';
import 'core/services/supabase_service.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ReleafApp());
}

class ReleafApp extends StatefulWidget {
  const ReleafApp({super.key});

  @override
  State<ReleafApp> createState() => _ReleafAppState();
}

class _ReleafAppState extends State<ReleafApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'Releaf',
            debugShowCheckedModeBanner: false,
            themeMode: _appState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
