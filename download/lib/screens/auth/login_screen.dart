import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: authProvider.isLoading
            ? const LoadingIndicator(message: 'Signing in...')
            : _buildLoginForm(context, authProvider),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Name
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Login Title
              const Text(
                'Sign in to your account',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Error Message
              if (authProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingRegular),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    border: Border.all(
                      color: AppTheme.errorColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.error!,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.errorColor,
                          size: 16,
                        ),
                        onPressed: () {
                          authProvider.clearError();
                        },
                      ),
                    ],
                  ),
                ),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Basic email validation
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Remember Me & Forgot Password
              Row(
                children: [
                  // Remember Me
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Text('Remember me'),
                  
                  const Spacer(),
                  
                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Login Button
              ElevatedButton(
                onPressed: () => _handleLogin(authProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Register Link
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Don\'t have an account? ',
                    style: const TextStyle(
                      color: AppTheme.textLightColor,
                    ),
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/register');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    // Clear any previous errors
    authProvider.clearError();
    
    // Validate form
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      final success = await authProvider.signIn(email, password);
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}