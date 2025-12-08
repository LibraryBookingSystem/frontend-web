import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../models/user.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/theme_switcher.dart';
import '../../core/utils/responsive.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with ValidationMixin, ErrorHandlingMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ResponsiveFormLayout(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title
                      Icon(
                        Icons.library_books,
                        size: Responsive.getIconSize(
                          context,
                          mobile: 64,
                          tablet: 72,
                          desktop: 80,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 16, tablet: 20, desktop: 24)),
                      Text(
                        'Library Booking System',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.getFontSize(
                                context,
                                mobile: 24,
                                tablet: 28,
                                desktop: 32,
                              ),
                            ),
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 8, tablet: 12, desktop: 16)),
                      Text(
                        'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              fontSize: Responsive.getFontSize(
                                context,
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 32, tablet: 40, desktop: 48)),
                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            validateRequired(value, fieldName: 'Username'),
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
                        validator: (value) =>
                            validateRequired(value, fieldName: 'Password'),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(context),
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 8, tablet: 12, desktop: 16)),
                      // Remember me checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember me'),
                        ],
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 20, tablet: 24, desktop: 28)),
                      // Login button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return SizedBox(
                            height: Responsive.getButtonHeight(context),
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      Responsive.isMobile(context) ? 14 : 16,
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Login'),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                          height: Responsive.getSpacing(context,
                              mobile: 16, tablet: 20, desktop: 24)),
                      // Register link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.register);
                        },
                        child: const Text('Don\'t have an account? Register'),
                      ),
                      // Error display
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (authProvider.error != null) {
                            final errorMessage = authProvider.error!;
                            // Check for specific error messages and display them appropriately
                            final isPendingApproval = errorMessage
                                .toLowerCase()
                                .contains('pending approval');
                            final isRejected = errorMessage
                                    .toLowerCase()
                                    .contains('rejected') &&
                                errorMessage
                                    .toLowerCase()
                                    .contains('registration');

                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isPendingApproval
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : isRejected
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isPendingApproval
                                        ? Colors.orange
                                        : isRejected
                                            ? Colors.red
                                            : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPendingApproval
                                          ? Icons.pending_actions
                                          : isRejected
                                              ? Icons.block
                                              : Icons.error_outline,
                                      color: isPendingApproval
                                          ? Colors.orange
                                          : isRejected
                                              ? Colors.red
                                              : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: TextStyle(
                                          color: isPendingApproval
                                              ? Colors.orange.shade900
                                              : isRejected
                                                  ? Colors.red.shade900
                                                  : Colors.red.shade900,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
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
            // Theme switcher in top right corner
            Positioned(
              top: Responsive.getSpacing(context,
                  mobile: 8, tablet: 12, desktop: 16),
              right: Responsive.getSpacing(context,
                  mobile: 8, tablet: 12, desktop: 16),
              child: const ThemeSwitcherIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    print('🔍 DEBUG: Login button pressed');
    if (!_formKey.currentState!.validate()) {
      print('🔍 DEBUG: Form validation failed');
      return;
    }
    print('🔍 DEBUG: Form validation passed');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await executeWithErrorHandling(
      context,
      () async {
        print('🔍 DEBUG: Calling authProvider.login');
        return await authProvider.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      },
    );

    if (success == true && context.mounted) {
      // Navigate based on user role
      final user = authProvider.currentUser;
      if (user != null) {
        _navigateToDashboard(context, user.role);
      }
    }
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
}
