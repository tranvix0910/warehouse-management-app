import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'apis/api_client.dart';
import 'services/notification_service.dart';
import 'services/role_service.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/signin_page.dart';
import 'pages/signup_page.dart';
import 'pages/otp_page.dart';
import 'pages/main_layout.dart';
import 'pages/profile/profile_page.dart';
import 'pages/activity/activity_log_page.dart';
import 'pages/ai/ai_chatbot_page.dart';
import 'pages/ai/ai_report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ApiClient.init();
  await NotificationService().initialize();
  await RoleService().loadUserRole();
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      title: 'Warehouse Management App',
      debugShowCheckedModeBanner: false,
      theme: themeState.darkTheme,
      darkTheme: themeState.darkTheme,
      themeMode: ThemeMode.dark,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/main': (context) => const MainLayout(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
        '/activity-log': (context) => const ActivityLogPage(),
        '/ai-chatbot': (context) => const AIChatbotPage(),
        '/ai-report': (context) => const AIReportPage(),
        '/otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpPage(email: args['email'], username: args['username']);
        }
      },
    );
  }
}
