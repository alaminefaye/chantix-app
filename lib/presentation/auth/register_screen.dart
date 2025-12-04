import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _isNameValid = value.isNotEmpty && value.length >= 2;
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid =
          value.isNotEmpty && value.contains('@') && value.contains('.');
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.length >= 8;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _isConfirmPasswordValid =
          value == _passwordController.text && value.isNotEmpty;
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'company_name': _companyNameController.text.trim(),
      };

      final success = await authProvider.register(data);

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Erreur d\'inscription',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFB41839), // Rouge
              const Color(0xFF3F1B3D), // Violet foncé
            ],
          ),
        ),
        child: Stack(
          children: [
            // Contenu du haut avec SafeArea
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      width: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Erreur chargement logo: $error');
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Titre
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Créez votre compte',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Créez votre compte Chantix',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Zone de contenu blanche qui descend jusqu'en bas
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.35,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // Champ Nom complet
                        const Text(
                          'Nom complet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB41839),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          onChanged: _validateName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Votre nom complet',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFB41839),
                                width: 2,
                              ),
                            ),
                            suffixIcon: _isNameValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Champ Email
                        const Text(
                          'Téléphone ou Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB41839),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: _validateEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Votre email',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFB41839),
                                width: 2,
                              ),
                            ),
                            suffixIcon: _isEmailValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Champ Nom de l'entreprise
                        const Text(
                          'Nom de l\'entreprise',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB41839),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _companyNameController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nom de votre entreprise',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFB41839),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom de l\'entreprise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Champ Mot de passe
                        const Text(
                          'Mot de passe',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB41839),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: _validatePassword,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Votre mot de passe',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFB41839),
                                width: 2,
                              ),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isPasswordValid)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 8) {
                              return 'Le mot de passe doit contenir au moins 8 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Champ Confirmation mot de passe
                        const Text(
                          'Confirmer le mot de passe',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB41839),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          onChanged: _validateConfirmPassword,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Confirmez votre mot de passe',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFB41839),
                                width: 2,
                              ),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isConfirmPasswordValid)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Bouton Sign Up
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFB41839),
                                    Color(0xFF3F1B3D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'S\'INSCRIRE',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Lien Sign In
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vous avez déjà un compte ? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Color(0xFF424242),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
