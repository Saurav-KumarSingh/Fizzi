import 'package:fizzi/feature/post/domain/entities/post.dart';

abstract class PostStates{}

// initial
class PostInitial extends PostStates {}

// loading..
class PostLoading extends PostStates {}

// uploading
class PostUpLoading extends PostStates {

}

// error
class PostError extends PostStates {
  final String message;
  PostError(this.message);
}

// loaded
class PostLoaded extends PostStates {
  final List<Post> posts;
  PostLoaded(this.posts);
}
