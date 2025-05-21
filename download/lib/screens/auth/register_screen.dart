import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: authProvider.isLoading
            ? const LoadingIndicator(message: 'Creating your account...')
            : _buildRegisterForm(context, authProvider),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 60,
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
              
              // Register Title
              const Text(
                'Create a new account',
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
              
              // Name Field
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
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
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Show terms of service
                                _showTermsAndConditions(context);
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Show privacy policy
                                _showPrivacyPolicy(context);
                              },
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Register Button
              ElevatedButton(
                onPressed: _agreeToTerms ? () => _handleRegister(authProvider) : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister(AuthProvider authProvider) async {
    // Clear any previous errors
    authProvider.clearError();
    
    // Validate form
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      final success = await authProvider.signUp(email, password, name);
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: const Text(
            'These Terms of Service ("Terms") govern your use of the FitSAGA mobile application. '
            'By using the app, you agree to these Terms.\n\n'
            '1. ACCEPTANCE OF TERMS\n'
            'By accessing or using the FitSAGA app, you agree to be bound by these Terms.\n\n'
            '2. ACCOUNT REGISTRATION\n'
            'You must register for an account to use certain features of the app. You are responsible for maintaining the confidentiality of your account information.\n\n'
            '3. USER CONDUCT\n'
            'You agree not to use the app for any unlawful purpose or in any way that could damage or impair the app or interfere with any other party\'s use of the app.\n\n'
            '4. INTELLECTUAL PROPERTY\n'
            'All content, design, graphics, and other materials on the app are owned by FitSAGA and are protected by copyright, trademark, and other intellectual property laws.\n\n'
            '5. LIMITATION OF LIABILITY\n'
            'FitSAGA shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the app.\n\n'
            '6. TERMINATION\n'
            'FitSAGA reserves the right to terminate or suspend your account and access to the app at any time for violation of these Terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: const Text(
            'This Privacy Policy describes how FitSAGA collects, uses, and shares information when you use our mobile application.\n\n'
            '1. INFORMATION WE COLLECT\n'
            'We collect information you provide directly to us, such as your name, email address, and other profile information. We also collect information about your use of the app.\n\n'
            '2. HOW WE USE YOUR INFORMATION\n'
            'We use the information we collect to provide, maintain, and improve the app, to communicate with you, and to personalize your experience.\n\n'
            '3. SHARING OF INFORMATION\n'
            'We may share your information with third-party service providers who perform services on our behalf, such as hosting, data analytics, and customer service.\n\n'
            '4. DATA SECURITY\n'
            'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.\n\n'
            '5. CHANGES TO THIS PRIVACY POLICY\n'
            'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.\n\n'
            '6. CONTACT US\n'
            'If you have any questions about this Privacy Policy, please contact us at support@fitsaga.com.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}