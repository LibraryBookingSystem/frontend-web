import 'user.dart';

/// Login request model
class LoginRequest {
  final String username;
  final String password;
  
  const LoginRequest({
    required this.username,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

/// Register request model
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final Role role;
  
  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.role = Role.student,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role.value,
    };
  }
}

/// Authentication response model
class AuthResponse {
  final String token;
  final User user;
  
  const AuthResponse({
    required this.token,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

