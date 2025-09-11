import 'package:fizzi/feature/auth/presentation/components/custombutton.dart';
import 'package:fizzi/feature/auth/presentation/components/text_field.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/responsive/constrained_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? toggleAuthPages;
  const LoginPage({super.key, this.toggleAuthPages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // login method
  void login(){
    final String email=emailController.text.trim();
    final String password=passwordController.text.trim();
    
    // auth cubit manage
    final authCubit=context.read<AuthCubit>();
    
    // email and psd field is not empty
    if(email.isNotEmpty && password.isNotEmpty){
      authCubit.login(email, password);
    }else{
      // show error
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please Enter both email and password")));
    }
    
  }

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo
                  Center(
                    child: Image.asset(
                      'assets/logo/fizzi_webp.webp',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Welcome bck msg

                  Text("Welcome back, you've been missed!",style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 17),),
                  SizedBox(height: 30,),

                  /// Email field
                  CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  /// Password field
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 50),

                  /// Login button
                  CustomButton(text: 'login', onTap: login),
                  const SizedBox(height: 30),

                  /// Signup redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account? ",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      GestureDetector(
                        onTap: widget.toggleAuthPages,
                        child: Text("Register now",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
