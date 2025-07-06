// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/cubits/auth/auth_cubit.dart';
import 'package:notes_app/cubits/auth/auth_state.dart';
import 'package:notes_app/cubits/notes/notes_cubit.dart';
import 'package:notes_app/screens/auth_screen.dart';
import 'package:notes_app/screens/notes_screen.dart';
import 'package:notes_app/repositories/firestore_notes_repository.dart'; // <--- IMPORTANT: This is the new import

import 'firebase_options.dart';

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
        // This is the key part: providing the NotesCubit with its new dependency
        BlocProvider<NotesCubit>(
          create: (context) => NotesCubit(FirestoreNotesRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          // Sticking with primarySwatch for consistency with previous steps,
          // though Material3 theme is also an option if you prefer that look.
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // This BlocBuilder handles the routing between AuthScreen and NotesScreen
        // based on the AuthCubit's state, similar to what AuthFlowHandler did.
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const NotesScreen();
            } else {
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}