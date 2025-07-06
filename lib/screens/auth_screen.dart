// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/cubits/auth/auth_cubit.dart';
import 'package:notes_app/cubits/auth/auth_state.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginMode = true; // To toggle between login and signup
  bool _isLoading = false; // To manage local loading state (though Cubit will handle global)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAuthForm() {
    // Validate the form before attempting authentication
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved on form fields

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Access the AuthCubit instance
      final authCubit = context.read<AuthCubit>();

      // Call the appropriate method on the Cubit
      if (_isLoginMode) {
        authCubit.signInWithEmailAndPassword(email, password);
      } else {
        authCubit.createUserWithEmailAndPassword(email, password);
      }
      // The loading state will now be handled by the BlocBuilder/BlocListener
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Sign Up'),
      ),
      body: BlocListener<AuthCubit, AuthState>( // <--- BlocListener for side effects
        listener: (context, state) {
          // You removed AuthFlowHandler's navigation, so we put it here.
          // However, typically, AuthFlowHandler handles navigation AFTER successful login.
          // This listener is primarily for Snackbars (success/error messages)

          if (state is AuthError) {
            // Show error message using SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous snackbars
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isLoginMode
                    ? 'Login successful!'
                    : 'Account created!'),
                backgroundColor: Colors.green,
              ),
            );
            // AuthFlowHandler will handle navigation away from AuthScreen on AuthSuccess
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email address'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Use BlocBuilder to show loading spinner or buttons
                  BlocBuilder<AuthCubit, AuthState>( // <--- BlocBuilder for UI rebuilds
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const CircularProgressIndicator();
                      }
                      return Column(
                        children: [
                          ElevatedButton(
                            onPressed: _submitAuthForm,
                            child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode; // Toggle mode
                                // Clear fields when switching mode
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            child: Text(_isLoginMode
                                ? 'Create a new account'
                                : 'I already have an account'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}