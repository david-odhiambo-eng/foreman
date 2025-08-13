import 'package:flutter/material.dart';
import 'package:foreman/models/signup_signin.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:foreman/views/onboarding/sign_in.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authService = AuthService();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Welcome, please provide your details',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/foreman.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Form content
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: usernameController,
                              hint: 'Enter your Username',
                              fillColor: Colors.black.withOpacity(0.7),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: emailController,
                              hint: 'Enter your email',
                              fillColor: Colors.black.withOpacity(0.7),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: passwordController,
                              hint: 'Enter your password',
                              fillColor: Colors.black.withOpacity(0.7),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: confirmPasswordController,
                              hint: 'Confirm your password',
                              fillColor: Colors.black.withOpacity(0.7),
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),

                            // Sign Up button
                            ElevatedButton(
                              onPressed: () async{
                                
                                  await authService.createUser(
                                  context: context, 
                                  email: emailController.text, 
                                  password: passwordController.text, 
                                  confirmPassword: confirmPasswordController.text
                                  );

                                

                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text('Sign Up'),
                            ),
                            const SizedBox(height: 20),

                            // Login link
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => Login()));
                              },
                              child: Text(
                                'Already have an account? Login',
                                style: reusableStyle().copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color fillColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        fillColor: fillColor,
        filled: true,
        hintText: hint,
        hintStyle: reusableStyle().copyWith(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
