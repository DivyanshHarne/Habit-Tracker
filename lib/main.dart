
import 'package:flutter/material.dart';
import 'package:habits/pages/home_page.dart';
import 'package:habits/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'database/habit_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialise the database
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();
  runApp(
    MultiProvider(providers: [
      //habit provider
      ChangeNotifierProvider(create: (context)=> HabitDatabase()),
      //theme provider
      ChangeNotifierProvider(create: (context)=>ThemeProvider(),)
    ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );

  }
}
