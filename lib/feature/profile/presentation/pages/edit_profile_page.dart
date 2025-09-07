import 'package:fizzi/feature/auth/presentation/components/text_field.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _bioTextController = TextEditingController();



  // update profile method

  void updateProfile()async {

    final profileCubit=context.read<ProfileCubit>();

    if(_bioTextController.text.isNotEmpty){

      profileCubit.updateProfile(
          uid: widget.user.uid,
          newBio: _bioTextController.text.trim()
      );
    }
  }


  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading..
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Uploading..."),
                ],
              ), // Column
            ), // Center
          ); // Scaffold
        } else {
          // edit form
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    ); // BlocConsumer
  }
  Widget buildEditPage({double uploadProgress = 0.0}) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: updateProfile, icon: Icon(Icons.upload))
        ],
      ),
      body: Column(
        children: [


          //bio
          const Text("Bio"),
          const SizedBox(height: 10,),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: CustomTextField(controller: _bioTextController, hintText: widget.user.bio),
          )
        ],
      ),
    ); // Scaffold
  }
}

