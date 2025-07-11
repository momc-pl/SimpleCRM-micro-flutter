import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/core/di/injection_container.dart';
import 'package:simple_crm_flutter/core/routing/app_router.dart';
import 'package:simple_crm_flutter/core/theme/app_theme.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';
import 'package:simple_crm_flutter/core/services/microservices_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize logger first
    AppLogger.init();
    AppLogger.info('Starting SimpleCRM Flutter application...');
    
    // Initialize dependency injection
    await initializeDependencies();
    AppLogger.info('Dependency injection initialized');
    
    // Initialize microservices coordination
    final coordinator = sl<MicroservicesCoordinator>();
    await coordinator.initialize();
    AppLogger.info('Microservices coordinator initialized');
    
    runApp(const ProviderScope(child: SimpleCrmApp()));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize application: $e', stackTrace);
    // In production, you might want to show an error screen
    runApp(const ProviderScope(child: SimpleCrmApp()));
  }
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
