import 'package:flutter/material.dart';
import 'theme/app_palette.dart';
import 'views/welcome/welcome_page.dart';
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
        '/': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/livescore': (context) => const LiveScorePage(),
        '/news': (context) => const NewsPage(),
      },
    );
  }
}
