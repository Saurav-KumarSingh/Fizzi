import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text("Welcome to Home Page!"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
    }
      ,child: Text('log'),),
    );
  }
}
