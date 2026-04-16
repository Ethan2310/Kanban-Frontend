import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/ui/app_text_box.dart';
import 'package:kanban_frontend/core/ui/password_input_box.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _passwordInputState = PasswordInputState.normal;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _handleLogin() {
    final isValid = _formKey.currentState!.validate();

    setState(() {
      _passwordInputState = isValid
          ? PasswordInputState.normal
          : PasswordInputState.invalid;
    });

    if (isValid) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('User Login')),
        body: BlocConsumer<AuthBloc, AuthState>(builder: (context, state) {
          final isLoading = state is AuthLoading;
          final passwordInputState = state is AuthError &&
                  state.type == AuthErrorType.invalidCredentials
              ? PasswordInputState.incorrect
              : _passwordInputState;

          return Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                      const SizedBox(height: 40),
                      AppTextBox(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefix: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      PasswordInputBox(
                        controller: _passwordController,
                        enabled: !isLoading,
                        state: passwordInputState,
                        onFieldSubmitted: (_) => _handleLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ))
                              : const Text('Login'))
                    ],
                  )));
        }, listener: (context, state) {
          if (state is AuthError &&
              state.type == AuthErrorType.invalidCredentials) {
            setState(() {
              _passwordInputState = PasswordInputState.incorrect;
            });
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is! AuthLoading) {
            setState(() {
              _passwordInputState = PasswordInputState.normal;
            });
          }
        }));
  }
}
