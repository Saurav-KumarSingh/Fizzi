import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fizzi/feature/auth/presentation/components/text_field.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';
import 'package:fizzi/responsive/constrained_scaffold.dart';
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
          return ConstrainedScaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Uploading..."),
                ],
              ), // Column
            ), // Center
          );
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
    return ConstrainedScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: const Icon(Icons.check),
            tooltip: "Save",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture with circular style
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      backgroundImage: (!kIsWeb && imagePickedFile != null)
                          ? FileImage(File(imagePickedFile!.path!))
                          : (kIsWeb && webImg != null)
                          ? MemoryImage(webImg!)
                          : null,
                      child: (imagePickedFile == null && webImg == null)
                          ? CachedNetworkImage(
                        imageUrl: widget.user.profileImageUrl,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        imageBuilder: (context, imageProvider) =>
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: imageProvider,
                            ),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bio field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Bio",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _bioTextController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: widget.user.bio.isNotEmpty
                    ? widget.user.bio
                    : "Write something about yourself...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

