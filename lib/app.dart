import 'package:fizzi/feature/auth/data/firebase_auth_repo.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_states.dart';
import 'package:fizzi/feature/auth/presentation/pages/auth_page.dart';
import 'package:fizzi/feature/home/presentation/pages/home_page.dart';
import 'package:fizzi/feature/profile/data/firebase_profile_repo.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/feature/storage/data/cloudinary_repo.dart';
import 'package:fizzi/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authRepo = FirebaseAuthRepo();

  // profile repo
  final profileRepo = FirebaseProfileRepo();
  // STORAGE repo
  final storageRepo = CloudinaryRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
              profileRepo: profileRepo,
              storageRepo:storageRepo
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fizzi',
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            debugPrint("Auth state: $authState");

            if (authState is UnAuthenticated) return AuthPage();
            if (authState is Authenticated) return HomePage();

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ),
    );
  }
}
