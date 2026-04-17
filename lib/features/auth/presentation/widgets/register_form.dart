import 'package:flutter/material.dart';
import 'package:kanban_frontend/core/ui/app_text_box.dart';
import 'package:kanban_frontend/core/ui/password_input_box.dart';

/// A reusable registration form widget.
///
/// Renders all fields inside a purple-tinted card.
/// The parent is responsible for providing controllers and a [formKey].
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.enabled = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextBox(
              controller: firstNameController,
              enabled: enabled,
              decoration: _fieldDecoration('First Name', Icons.person),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please enter your first name'
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextBox(
              controller: lastNameController,
              enabled: enabled,
              decoration: _fieldDecoration('Last Name', Icons.person_outline),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please enter your last name'
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextBox(
              controller: emailController,
              enabled: enabled,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration('Email', Icons.email),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Please enter a valid email';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            PasswordInputBox(
              controller: passwordController,
              enabled: enabled,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter a password';
                if (v.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordInputBox(
              label: 'Confirm Password',
              controller: confirmPasswordController,
              enabled: enabled,
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Please confirm your password';
                if (v != passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withAlpha(40),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      prefixIcon: Icon(icon, color: Colors.white70),
    );
  }
}
