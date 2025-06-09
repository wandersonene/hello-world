import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validation.dart';
import '../service_locator.dart';
import 'login_screen.dart'; // To navigate to login after registration
import 'project_list_screen.dart'; // Updated to ProjectListScreen

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/register';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // CPF or Email
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = sl<AuthService>();
        final user = await authService.registerUser(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        setState(() { _isLoading = false; });

        // Navigate to Dashboard or Login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Welcome ${user.name}.')),
          );
          // Option 1: Navigate to Login screen
          // Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);

          // Option 2: Navigate directly to ProjectListScreen (auto-login)
          Navigator.of(context).pushReplacementNamed(
            ProjectListScreen.routeName,
            arguments: user.name, // Pass userName as argument
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: InputValidators.validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'CPF or Email'),
                validator: InputValidators.validateUsername,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress, // General purpose
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: InputValidators.validatePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) => InputValidators.validateConfirmPassword(
                  _passwordController.text,
                  value,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _isLoading ? null : _register(),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
