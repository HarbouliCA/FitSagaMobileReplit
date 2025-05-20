import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmailAndPassword(email, password);
    
    if (success && mounted) {
      // Navigate to home screen (replace the entire stack)
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else if (mounted) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      const Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Welcome text
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Login to continue your fitness journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
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
                        enabled: !isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Remember me and forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Remember me
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                activeColor: AppTheme.primaryColor,
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          
                          // Forgot password
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Navigate to forgot password screen
                                  },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login button
                      ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isLoading ? 'Logging in...' : 'Login',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Register option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pushReplacementNamed('/register');
                                  },
                            child: const Text('Register'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      
                      // Demo login options
                      const Divider(),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Demo Login Options',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Demo login options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDemoButton(
                            title: 'Client',
                            icon: Icons.person,
                            color: AppTheme.primaryColor,
                            onTap: () {
                              Provider.of<AuthProvider>(context, listen: false).setDemoUser();
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                          ),
                          _buildDemoButton(
                            title: 'Instructor',
                            icon: Icons.sports,
                            color: Colors.green,
                            onTap: () {
                              Provider.of<AuthProvider>(context, listen: false).setDemoUser(isInstructor: true);
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                          ),
                          _buildDemoButton(
                            title: 'Admin',
                            icon: Icons.admin_panel_settings,
                            color: Colors.purple,
                            onTap: () {
                              Provider.of<AuthProvider>(context, listen: false).setDemoUser(isAdmin: true);
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (isLoading)
            const LoadingIndicator(overlay: true),
        ],
      ),
    );
  }
  
  Widget _buildDemoButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}