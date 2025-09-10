import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizzi/feature/post/domain/entities/post.dart';
import 'package:fizzi/feature/post/domain/repos/post_repo.dart';

class CloudinaryPostRepo implements PostRepo{
  final FirebaseFirestore firebaseFirestore=FirebaseFirestore.instance;


  // store posts in posts collection

  final CollectionReference postCollection=FirebaseFirestore.instance.collection("posts");

  @override
  Future<void> createPost(Post post) async {
    try{
      await postCollection.doc(post.id).set(post.toJson());
    }catch (e){

      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId)async {
    await postCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts()async {
    try{
      //get all post-> recents post first


      final postsSnapshot=await postCollection.orderBy('timestamp',descending: true).get();

      //convert each document from Json ->List of Posts
      final List<Post> allPosts=postsSnapshot.docs.map((doc)=>Post.fromJson(doc.data() as Map<String,dynamic>)).toList();

      print(allPosts);
      return allPosts;
    }catch (e){
        throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId)async {
    try{
      //fetch user posts
      final postsSnapshot=await postCollection.where('userId',isEqualTo: userId).orderBy('timestamp',descending: true).get();

      //convert each document from Json ->List of Posts
      final List<Post> userPosts=postsSnapshot.docs.map((doc)=>Post.fromJson(doc.data() as Map<String,dynamic>)).toList();

      return userPosts;

    }catch (e){
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId,String userId)async{

    try{

      //get post doc
      final postDoc= await postCollection.doc(postId).get();
      if(postDoc.exists){
        final post=Post.fromJson(postDoc.data() as Map<String,dynamic>);


        // check if user have alredy liked

        final hasLiked=post.likes.contains(userId);

        if(hasLiked){
          post.likes.remove(userId);//unlike
        }else{
          post.likes.add(userId);//like
        }

        //update post with new like list

        await postCollection.doc(postId).update({'likes':post.likes});


      }else{
        throw Exception("Post not found");
      }

    }catch (e){

      throw Exception("Error toggling like: $e");
    }

  }

}