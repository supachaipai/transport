import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/server_setup_screen.dart';
import 'screens/web_portal_screen.dart';
import 'theme/app_theme.dart';

const String _compiledBaseUrl = String.fromEnvironment('TRANSPORT_BASE_URL', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  var baseUrl = prefs.getString('transport_base_url')?.trim() ?? '';
  if (baseUrl.isEmpty && _compiledBaseUrl.trim().isNotEmpty) {
    baseUrl = _compiledBaseUrl.trim();
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';
    await prefs.setString('transport_base_url', baseUrl);
  }

  runApp(TransportApp(baseUrl: baseUrl));
}

class TransportApp extends StatelessWidget {
  const TransportApp({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'แอพขนส่ง',
      theme: AppTheme.light(),
      home: baseUrl.isEmpty
          ? const ServerSetupScreen()
          : WebPortalScreen(baseUrl: baseUrl),
    );
  }
}
