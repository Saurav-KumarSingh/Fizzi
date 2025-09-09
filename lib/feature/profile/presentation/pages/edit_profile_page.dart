import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fizzi/feature/auth/presentation/components/text_field.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _bioTextController = TextEditingController();

  //mobile img pick
  PlatformFile? imagePickedFile;

  //web img pick
  Uint8List? webImg;


  //pick img

  Future<void>pickImage()async{
    final result=await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData:kIsWeb,
    );

    if(result!=null){
      setState(() {
        imagePickedFile=result.files.first;

        if(kIsWeb){
          webImg=imagePickedFile!.bytes;
        }
      });
    }
  }

  // update profile method

  void updateProfile()async {

    final profileCubit=context.read<ProfileCubit>();

    // prepare img

    final String uid=widget.user.uid;

    final String? newBio=_bioTextController.text.isNotEmpty?_bioTextController.text.trim():null;
    final imageMobilePath=kIsWeb?null :imagePickedFile?.path;
    final imageWebBytes=kIsWeb? imagePickedFile?.bytes :null;



    if(imagePickedFile !=null || newBio != null){

      profileCubit.updateProfile(
          uid: uid,
          newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    }else{//nothing to update

      Navigator.pop(context);

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
  Widget buildEditPage() {
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


          // profile pic

          Center(
            child: Container(
              height: 200,
              width: 200,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,

              ),
              child:
                //display selected img for mobile
              (!kIsWeb && imagePickedFile != null)?
                  Image.file(File(imagePickedFile!.path!),fit: BoxFit.cover,)
                  :
                //display selected img for mobile
              (kIsWeb && webImg != null)?
              Image.memory(webImg!,fit: BoxFit.cover):
              //display for no selected img
              CachedNetworkImage(
                imageUrl: widget.user.profileImageUrl,
                //loading
                placeholder: (context,url)=>const CircularProgressIndicator(),
                //error
                errorWidget:  (context,url,error)=>Icon(Icons.person, size: 60,color: Theme.of(context).colorScheme.primary,),
                imageBuilder: (context,imageProvider)=>Image(image: imageProvider,fit: BoxFit.cover,),
              )
            ),
          ),

          SizedBox(height: 15,),
          Center(
            child: MaterialButton(onPressed: pickImage,color: Colors.blue,child: const Text("Pick Image"),),
          ),

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

