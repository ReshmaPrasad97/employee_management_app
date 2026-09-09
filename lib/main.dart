import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/employee_list_screen.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  print('APP STARTED');

  await dotenv.load(fileName: '.env');

  print('ENV LOADED');
  print('API URL: ${dotenv.env['API_BASE_URL']}');

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
      home: const EmployeeListScreen(),
    );
  }
}

