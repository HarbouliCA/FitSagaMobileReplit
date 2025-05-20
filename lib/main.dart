import 'package:flutter/material.dart';
import 'package:fitsaga/demo/demo_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DemoApp());
}

// This class is temporarily not used while we demonstrate the UI enhancements
// We'll re-enable it once Firebase integration is fixed
/* 
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'FitSAGA',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.login, // Start with login screen
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
*/