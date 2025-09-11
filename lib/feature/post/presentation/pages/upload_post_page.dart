import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_states.dart';
import 'package:fizzi/responsive/constrained_scaffold.dart';
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
          comments: [],
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
            return ConstrainedScaffold(
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

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 single slot for picker/preview
            GestureDetector(
              onTap: pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (kIsWeb && webImage != null)
                    ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.memory(
                      webImage!,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.4),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "Tap to replace image",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
                    : (!kIsWeb && imagePickedFile != null)
                    ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.file(
                      File(imagePickedFile!.path!),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.4),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "Tap to replace image",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
                    : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      width: 1.5,
                    ),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined, size: 40),
                      SizedBox(height: 8),
                      Text("Add Image"),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // caption text box
            CustomTextField(
              controller: textController,
              hintText: "Caption",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }




}

