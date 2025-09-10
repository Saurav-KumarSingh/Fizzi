import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_states.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/components/text_field.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  //mobile image pick

  PlatformFile? imagePickedFile;


  //web image pick

  Uint8List? webImage;

  //text controller
  final textController=TextEditingController();

  //current user
  AppUser? currentUser;

  void getCurrentUser()async{
    final authCubit=context.read<AuthCubit>();
    currentUser=authCubit.currentUser;
  }

  // select img

  Future<void>pickImage()async{
    final result=await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData:kIsWeb,
    );

    if(result!=null){
      setState(() {
        imagePickedFile=result.files.first;

        if(kIsWeb){
          webImage=imagePickedFile!.bytes;
        }
      });
    }
  }

  // create and upload post

  void uploadPost(){
    // check if image and caption provided

    if(imagePickedFile==null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Both image and caption are required"))
      );
      return;
    }

      // crete new post

      final newPost=Post(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: currentUser!.uid, userName: currentUser!.name,
          text: textController.text.trim(),
          imageUrl: '',
          timestamp: DateTime.now(),
          likes: [],
      );

      // post cubit

      final postCubit=context.read<PostCubit>();

      //web upload
      if(kIsWeb){
        postCubit.createPost(newPost,imageBytes: imagePickedFile?.bytes);
      }

      //mobile upload
      else{
        postCubit.createPost(newPost,imagePath: imagePickedFile?.path);
      }



    }


  @override
  void initState(){
    super.initState();

    getCurrentUser();
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit,PostStates>(
        builder: (context,state){
          //loading or uploading
          if(state is PostLoading || state is PostUpLoading){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return buildUploadPage();
        },
        listener: (context,state){
          if (state is PostLoaded) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Post uploaded successfully!"))
            );
          }
          if (state is PostError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}"))
            );
          }
        }
    );
  }

  Widget buildUploadPage(){
    return Scaffold(

//APP BAR
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Create Post"),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(onPressed: uploadPost, icon:const Icon(Icons.upload))
          ],
      ),

      //BODY

      body: Center(
        child: Column(
          children: [
            // img preview->web

            if(kIsWeb && webImage != null) Image.memory(webImage!),

            // img preview->mobile
            if(!kIsWeb && imagePickedFile != null) Image.file(File(imagePickedFile!.path!)),


            //pick img button 
            
            MaterialButton(onPressed: pickImage,child:const  Text("Pick Image"), color: Colors.blue,),

            // caption text box

            CustomTextField(controller: textController,hintText: "Caption",obscureText: false,),

          ],
        ),
      ),
    );
  }
}

