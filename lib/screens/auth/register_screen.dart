import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import '../../models/user.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/theme_switcher.dart';

/// Registration screen for new user signup
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with ValidationMixin, ErrorHandlingMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Role _selectedRole = Role.student;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: [
          ThemeSwitcherIcon(),
        ],
      ),
      body: SafeArea(
        child: ResponsiveFormLayout(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.getFontSize(
                            context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 24, tablet: 28, desktop: 32)),
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => validateUsername(value),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => validateEmail(value),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => validatePassword(value),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => validatePasswordConfirmation(
                      value,
                      _passwordController.text,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Role selection
                  DropdownButtonFormField<Role>(
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    initialValue: _selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: Role.student,
                        child: Text('STUDENT'),
                      ),
                      DropdownMenuItem(
                        value: Role.faculty,
                        child: Text('FACULTY'),
                      ),
                      DropdownMenuItem(
                        value: Role.admin,
                        child: Text('ADMIN'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                  // Conditional message based on selected role
                  if (_selectedRole == Role.student)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'STUDENT accounts are automatically approved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'FACULTY and ADMIN accounts require approval from an existing administrator. You will receive an email once your account is approved.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                            ),
                      ),
                    ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Terms checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child:
                              const Text('I accept the terms and conditions'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 20, tablet: 24, desktop: 28)),
                  // Register button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        height: Responsive.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading || !_acceptTerms
                              ? null
                              : () => _handleRegister(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.isMobile(context) ? 14 : 16,
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Register'),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          mobile: 16, tablet: 20, desktop: 24)),
                  // Login link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                  // Error display
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
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

  void _navigateToDashboard(BuildContext context, Role role) {
    switch (role) {
      case Role.student:
        Navigator.pushReplacementNamed(context, RouteNames.studentHome);
        break;
      case Role.faculty:
        Navigator.pushReplacementNamed(context, RouteNames.staffDashboard);
        break;
      case Role.admin:
        Navigator.pushReplacementNamed(context, RouteNames.adminDashboard);
        break;
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      showErrorSnackBar(context, 'Please accept the terms and conditions');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final request = RegisterRequest(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    try {
      await authProvider.register(request);

      if (context.mounted) {
        final user = authProvider.currentUser;
        if (user != null) {
          // Show success message
          if (_selectedRole == Role.student) {
            showSuccessSnackBar(context, 'Registration successful! Welcome!');
          } else {
            // Should not happen if blocking is active, but fallback:
            showSuccessSnackBar(
              context,
              'Registration successful! Your account is pending approval.',
            );
          }
          // Navigate to appropriate dashboard based on role
          _navigateToDashboard(context, user.role);
        } else {
          // Fallback: navigate to login if user data not available
          showSuccessSnackBar(
              context, 'Registration successful! Please login.');
          Navigator.pushReplacementNamed(context, RouteNames.login);
        }
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('approval')) {
          showSuccessSnackBar(
            context,
            'Registration successful! Your account is pending approval. Please wait for an administrator to approve it.',
          );
          Navigator.pushReplacementNamed(context, RouteNames.login);
        } else {
          // Clean up exception string for display
          final displayMessage = e
              .toString()
              .replaceAll('ApiException:', '')
              .replaceAll('Exception:', '')
              .trim();
          showErrorSnackBar(context, displayMessage);
        }
      }
    }
  }
}
