// lib/cubits/auth/auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth
import 'package:notes_app/cubits/auth/auth_state.dart'; // Your custom states

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()); // Initial state is AuthInitial

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading()); // Emit loading state

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, emit AuthSuccess with the user's UID
      emit(AuthSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase Auth errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An authentication error occurred: ${e.message}';
      }
      emit(AuthError(errorMessage)); // Emit error state with message
    } catch (e) {
      // Catch any other unexpected errors
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading()); // Emit loading state

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, emit AuthSuccess with the user's UID
      emit(AuthSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase Auth errors
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An authentication error occurred: ${e.message}';
      }
      emit(AuthError(errorMessage)); // Emit error state with message
    } catch (e) {
      // Catch any other unexpected errors
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  // Optional: Add a sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      emit(AuthInitial()); // Go back to initial state after sign out
    } catch (e) {
      emit(AuthError('Failed to sign out: $e'));
    }
  }
}