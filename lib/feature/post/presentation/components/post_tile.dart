import 'package:cached_network_image/cached_network_image.dart';
import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {


  //cubits
  late final postCubit=context.read<PostCubit>();
  late final profileCubit=context.read<ProfileCubit>();


  bool isOwnPost=false;
  //current user

  AppUser? currentUser;

  //profileUser

  ProfileUser? postUser;

  //on startup
  @override
  void initState(){
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser(){
    final authCubit=context.read<AuthCubit>();
    currentUser=authCubit.currentUser;
    isOwnPost=(widget.post.userId==currentUser!.uid);
  }
  void fetchPostUser()async{
    final fetchedUser=await profileCubit.getUserProfile(widget.post.userId);
    if(fetchedUser != null){
      setState(() {
        postUser=fetchedUser;
      });
    }
  }


  //LIKES

  void toggleLikePost() {
    // 1️⃣ Check the current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // 2️⃣ Update the UI immediately (optimistic update)
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    // 3️⃣ Tell backend (Cubit) to update like status
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((error) {
      // 4️⃣ If something goes wrong, revert the UI
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // undo the unlike → like again
        } else {
          widget.post.likes.remove(currentUser!.uid); // undo the like → unlike again
        }
      });
    });
  }


  //onDelete conformation

  void showOptions(){
    showDialog(context: context,
        builder: (context)=>AlertDialog(title: const Text("Delete Post?"),
        actions: [

          TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text('cancel')),

          //delete
          TextButton(onPressed: (){
            widget.onDeletePressed();
            Navigator.of(context).pop();
          }, child: Text('delete')),
        ],)
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header (profile + name + delete) ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // profile pic
                postUser?.profileImageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: postUser!.profileImageUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 20,
                    backgroundImage: imageProvider,
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person, size: 24),
                  ),
                )
                    : const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 24),
                ),

                const SizedBox(width: 10),

                // username
                Expanded(
                  child: Text(
                    widget.post.userName.isNotEmpty
                        ? widget.post.userName
                        : "Unknown User",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),

                // delete (only for own post)
                if (isOwnPost)
                  IconButton(
                    onPressed: showOptions,
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),

          // ---- Post Image ----

           CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(height: 400, color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, size: 40),
            ),


          // ---- Actions (like, comment, timestamp) ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),

                      ),
                      const SizedBox(width: 4),
                      Text(widget.post.likes.length.toString()),
                    ],
                  ),

                ),

                const SizedBox(width: 5),

                Icon(Icons.mode_comment_outlined,
                    size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                const Text("0"),

                const Spacer(),

                // timestamp (shortened)
                Text(
                  widget.post.timestamp.toString().substring(0, 10),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
