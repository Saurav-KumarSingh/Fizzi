import 'dart:typed_data';

import 'package:fizzi/feature/post/domain/entities/comment.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/domain/repos/post_repo.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../storage/domain/storage_repo.dart';


class PostCubit extends Cubit<PostStates> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostInitial());

  // create a new post
  Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      emit(PostUpLoading());

      // upload image for mobile
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImgMobile(imagePath, post.id);
      }

      // upload image for web
      else if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImgWeb(imageBytes, post.id);
      }

      // assign url to post
      final newPost = post.copyWith(imageUrl: imageUrl);

      // ✅ Await DB call
      await postRepo.createPost(newPost);

      // refresh posts
      await fetchAllposts();
    } catch (e) {
      emit(PostError("Failed to create post: $e"));
    }
  }

  // fetch all posts
  Future<void> fetchAllposts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Failed to fetch posts: $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
      // ✅ refresh after delete
      await fetchAllposts();
    } catch (e) {
      emit(PostError("Failed to delete post: $e"));
    }
  }

  //like post
  Future<void> toggleLikePost(String postId,String userId)async{
    try{
      await postRepo.toggleLikePost(postId, userId);


    }catch(e){
        emit(PostError("Failed to toggle like: $e"));
    }
  }

  // add a comment to a post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      await fetchAllposts();
    } catch (e) {
      emit(PostError("Failed to add comment: $e"));
    }
  }

  // delete comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllposts();
    } catch (e) {
      emit(PostError("Failed to delete comment: $e"));
    }
  }
}
