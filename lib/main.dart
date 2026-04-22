import 'package:flutter/material.dart';
import 'config/api_config.dart';
import 'theme/app_palette.dart';
// import 'views/welcome/welcome_page.dart';
import 'views/home/home_page.dart';
import 'views/livescore/livescore_page.dart';
import 'views/news/news_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ApiConfig.isConfigured) {
      return MaterialApp(
        title: 'Sport App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppPalette.pageBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPalette.brand,
            brightness: Brightness.dark,
          ),
        ),
        home: const Scaffold(
          backgroundColor: AppPalette.pageBackground,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 24),
                  Text(
                    'API Key Missing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please set your LiveScore API key to run the app.\n\n'
                    'Step 1: Subscribe to the LiveScore API on RapidAPI\n'
                    'and copy your personal API key from the dashboard.\n\n'
                    'Step 2: Run the app with:\n'
                    'flutter run --dart-define=LIVE_SCORE_API_KEY=your_key_here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Sport App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppPalette.pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.brand,
          brightness: Brightness.dark,
          primary: AppPalette.brand,
          surface: AppPalette.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.pageBackground,
          foregroundColor: AppPalette.textPrimary,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/livescore': (context) => const LiveScorePage(),
        '/news': (context) => const NewsPage(),
      },
    );
  }
}
