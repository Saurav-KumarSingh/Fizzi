import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:fizzi/feature/post/domain/entities/comment.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {

  //current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  //show dialog to delete
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'),
          ),

          //delete
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(widget.comment.postId, widget.comment.id);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          //name
          Text(widget.comment.userName, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          //comment text
          Text(widget.comment.text),

          const Spacer(),

          if(isOwnPost) GestureDetector(child: Icon(Icons.more_horiz),onTap: showOptions,),
        ],
      ),
    );
  }
}
