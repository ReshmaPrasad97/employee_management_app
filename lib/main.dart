import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/employee.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('🔔 Background notification received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  print('APP STARTED');
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeAdapter());

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🔔 Foreground notification received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 Notification tapped');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  });

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('NOTIFICATION PERMISSION: ${settings.authorizationStatus}');

  final token = await messaging.getToken();

  print('FCM DEVICE TOKEN: $token');
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print('🔔 App opened from terminated state');
    print('Title: ${initialMessage.notification?.title}');
    print('Body: ${initialMessage.notification?.body}');
  }

  runApp(const ProviderScope(
    child: MyApp(),
  ));

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

