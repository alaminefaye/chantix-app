import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/firebase_options.dart';
import 'data/services/storage_service.dart';
import 'data/services/push_notification_service.dart';
import 'presentation/auth/auth_provider.dart';
import 'presentation/auth/splash_screen.dart';
import 'presentation/projects/project_provider.dart';
import 'presentation/dashboard/dashboard_provider.dart';
import 'presentation/attendance/attendance_provider.dart';
import 'presentation/progress/progress_provider.dart';
import 'presentation/materials/material_provider.dart';
import 'presentation/employees/employee_provider.dart';
import 'presentation/expenses/expense_provider.dart';
import 'presentation/tasks/task_provider.dart';
import 'presentation/comments/comment_provider.dart';
import 'presentation/reports/report_provider.dart';

// Handler pour les notifications en arrière-plan (doit être une fonction top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PushNotificationService.backgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurer le handler pour les notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialiser le stockage local
  await StorageService.init();

  // Initialiser le service de notifications push
  await PushNotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Chantix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
