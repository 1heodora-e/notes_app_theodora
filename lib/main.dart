import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/cubits/auth/auth_cubit.dart';
import 'package:notes_app/cubits/auth/auth_state.dart';
import 'package:notes_app/screens/auth_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/screens/notes_screen.dart';
import 'package:notes_app/cubits/notes/notes_cubit.dart';
import 'package:notes_app/cubits/notes/notes_state.dart';

void main() async { // REPLACE the original main() with this updated one
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider( // <--- WRAP YOUR APP WITH MultiBlocProvider
      providers: [
        BlocProvider<AuthCubit>( // Provide the AuthCubit
          create: (context) => AuthCubit(),
        ),
        BlocProvider<NotesCubit>( // <--- ADD THIS BlocProvider for NotesCubit
          create: (context) => NotesCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true, // You can add this for Material 3 design
        ),
        // The home will now be a wrapper that listens to AuthCubit state
        home: const AuthFlowHandler(), // <--- NEW WIDGET to handle auth flow
      ),
    );
  }
}

// This new widget will listen to the AuthCubit and switch screens
class AuthFlowHandler extends StatelessWidget {
  const AuthFlowHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder <AuthCubit, AuthState>( // Listen to AuthCubit's state
      builder: (context, state) {
        if (state is AuthSuccess) {
          // If a user is authenticated (AuthSuccess state), show the NotesScreen
          // IMPORTANT: You need to create this NotesScreen later in lib/screens/notes_screen.dart
          // For now, you can put a simple Placeholder or Text('Notes Screen')
          return const NotesScreen(); // Replace with const NotesScreen() later
        }
        // Otherwise (AuthInitial, AuthLoading, AuthError), show the AuthScreen
        return const AuthScreen();
      },
    );
  }
}
