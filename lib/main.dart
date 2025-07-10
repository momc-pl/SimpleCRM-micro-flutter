import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/core/di/injection_container.dart';
import 'package:simple_crm_flutter/core/routing/app_router.dart';
import 'package:simple_crm_flutter/core/theme/app_theme.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initializeDependencies();
  
  // Initialize logger
  AppLogger.init();
  
  runApp(const ProviderScope(child: SimpleCrmApp()));
}

class SimpleCrmApp extends ConsumerWidget {
  const SimpleCrmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'SimpleCRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
