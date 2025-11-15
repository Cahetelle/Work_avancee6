import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'page/accueil_page.dart';
import 'page/theme.dart';
import 'services/database_manager.dart';
import 'services/notification_service.dart';


class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialisation Firebase
  await Firebase.initializeApp();

  //  Initialisation SQLite
  await DBHelper.initDB();

  //  Initialisation des notifications locales
  await NotificationService.instance.init();

  //  Verrouille l’orientation en portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const HouefaSenseApp(),
    ),
  );
}

class HouefaSenseApp extends StatelessWidget {
  const HouefaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HOUEFASENSE",
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const AccueilPage(),
    );
  }
}
