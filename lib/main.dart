// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/cubits/auth/auth_cubit.dart';
import 'package:notes_app/cubits/notes/notes_cubit.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/repositories/firestore_notes_repository.dart';
import 'package:notes_app/screens/auth_screen.dart';
import 'package:notes_app/screens/notes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this is imported for StreamBuilder<User?>

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<NotesCubit>(
          create: (context) => NotesCubit(
            FirestoreNotesRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StreamBuilder<User?>( // Use StreamBuilder to listen to auth state changes
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // User is logged in, navigate to NotesScreen
              return const NotesScreen();
            } else {
              // User is not logged in, navigate to AuthScreen
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}