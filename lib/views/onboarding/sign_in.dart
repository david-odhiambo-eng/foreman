import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foreman/models/signup_signin.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:foreman/views/onboarding/sign_up.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController resetPasswordController = TextEditingController();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    
    

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

                    // Foreground form
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
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children:[
                                TextButton(onPressed:(){
                                  _resetPassword(context, resetPasswordController.text);
                                },
                                child:Text('Forgot Password?', style: reusableStyle(),),
                                )
                              ]
                            ),
                            
                            ElevatedButton(
                              onPressed: () async{
                                
                                  await authService.signIn(
                                    context: context, 
                                    email: emailController.text, 
                                    password:passwordController.text
                                    );


                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text('Sign In'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => SignUp()));
                              },
                              child: Text(
                                'Don\'t have an account? Sign Up',
                                style: reusableStyle().copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            
                            Text('OR', style:reusableStyle2(),),
                            _googleButton(context)


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

  Widget _googleButton(BuildContext context){
    return ElevatedButton(onPressed: ()async{
      await authService.signInWithGoogle(context);
    }, 
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(FontAwesomeIcons.google),
        Text('Sign In With Google')
      ],
    ));
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
  //reseting password
  Future _resetPassword(BuildContext context, String email)async{
    return showDialog(context: context, 
    builder: (_) => AlertDialog(
      title: Text('Please provide your spam email, we\'ll send password resets instructions'),
      actions: [
        Column(
          children: [
            TextField(
              controller: resetPasswordController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: reusableStyle1(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),
            SizedBox(height: 10,),
            Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('Cancel')),
            SizedBox(width: 10,),
            ElevatedButton(onPressed: ()async{
              await authService.resetPassword(context, resetPasswordController.text);
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue
            ),
            child: Text('Send')),
          ],),
          ],
        )
      ],
    ));
  }
}  
            

        
