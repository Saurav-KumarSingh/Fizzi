import 'package:cached_network_image/cached_network_image.dart';
import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/presentation/components/text_field.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/post/domain/entities/comment.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/presentation/components/comment_tile.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_states.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/feature/profile/presentation/pages/profile_page.dart';
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
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  //current user

  AppUser? currentUser;

  //profileUser

  ProfileUser? postUser;

  //on startup
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  void fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
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
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // 4️⃣ If something goes wrong, revert the UI
      setState(() {
        if (isLiked) {
          widget.post.likes.add(
            currentUser!.uid,
          ); // undo the unlike → like again
        } else {
          widget.post.likes.remove(
            currentUser!.uid,
          ); // undo the like → unlike again
        }
      });
    });
  }

  //comment text controller
  final commentTextController = TextEditingController();

  // open comment box -> user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: CustomTextField(
          controller: commentTextController,
          hintText: "Type a comment",
          obscureText: false,
        ), // MyTextField
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ), // TextButton
          // save button
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ), // TextButton
        ],
      ), // AlertDialog
    );
  }

  void addComment() {
    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    ); // Comment

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //onDelete conformation

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'),
          ),

          //delete
          TextButton(
            onPressed: () {
              widget.onDeletePressed();
              Navigator.of(context).pop();
            },
            child: Text('delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        // borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header (profile + name + delete) ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 👤 Profile pic + username (clickable)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(uid: widget.post.userId)));
                    },
                    child: Row(
                      children: [
                        // Profile picture
                        postUser?.profileImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: postUser!.profileImageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: imageProvider,
                                    ),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                      radius: 20,
                                      child: Icon(Icons.person, size: 24),
                                    ),
                              )
                            : const CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.person, size: 24),
                              ),

                        const SizedBox(width: 10),

                        // Username
                        Expanded(
                          child: Text(
                            widget.post.userName.isNotEmpty
                                ? widget.post.userName
                                : "Unknown User",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                            ),
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🗑️ Delete (only for own post)
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
                        onTap: toggleLikePost,
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

                // comment button
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ), // Icon
                ), // GestureDetector

                const SizedBox(width: 5),

                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ), // TextStyle
                ), // Text

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

          // CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10),

                Text(widget.post.text),
              ],
            ),
          ),

          // COMMENT SECTION
          BlocBuilder<PostCubit, PostStates>(
            builder: (context, state) {
              // LOADED
              if (state is PostLoaded) {
                // find individual post
                final post = state.posts.firstWhere(
                  (post) => post.id == widget.post.id,
                );

                if (post.comments.isNotEmpty) {
                  // how many comments to show
                  int showCommentCount = post.comments.length;

                  // comment section
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // get individual comment
                      final comment = post.comments[index];

                      // comment tile UI
                      return CommentTile(comment: comment);
                    },
                  ); // ListView.builder
                }
              }

              // LOADING..
              if (state is PostLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // ERROR
              else if (state is PostError) {
                return Center(child: Text(state.message));
              } else {
                return const Center(child: SizedBox());
              }
            },
          ),
        ],
      ),
    );
  }
}
