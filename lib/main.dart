import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foreman/firebase_options.dart';
import 'package:foreman/models/providers/notes_provider.dart';
import 'package:foreman/models/providers/purchases_provider.dart';
import 'package:foreman/models/providers/totals_tools_provider.dart';
import 'package:foreman/models/worker_provider.dart';


import 'package:foreman/views/onboarding/sign_in.dart';
import 'package:foreman/views/onboarding/splash_screen.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Foreman());
    
}

class Foreman extends StatelessWidget {
  const Foreman({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WorkerProvider()),
        ChangeNotifierProvider(create: (context) => ToolsProvider()),
        ChangeNotifierProvider(create: (context) => NotesProvider()),
        ChangeNotifierProvider(create: (context) => PurchasesProvider()),
      ],
      child: MaterialApp(
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData && snapshot.data != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          }
        });

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}



  

  
  


