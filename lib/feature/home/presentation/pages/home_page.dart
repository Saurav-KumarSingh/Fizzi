import 'package:fizzi/feature/home/presentation/components/my_drawer.dart';
import 'package:fizzi/feature/post/presentation/components/post_tile.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_cubit.dart';
import 'package:fizzi/feature/post/presentation/cubit/post_states.dart';
import 'package:fizzi/feature/post/presentation/pages/upload_post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final postCubit=context.read<PostCubit>();

  @override
  void initState(){
    super.initState();
    //fetch all posts
    fetchAllPosts();

  }
    void fetchAllPosts(){
      postCubit.fetchAllposts();
    }

    void deletePost(String postId){
      postCubit.deletePost(postId);
      fetchAllPosts();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Fizzi"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPostPage()));
          }, icon:const Icon(Icons.add))
        ],
      ),

      drawer: MyDrawer(),

      body: BlocBuilder<PostCubit,PostStates>(builder: (context,state){

        //loading or uploading
        if(state is PostLoading || state is PostUpLoading){
          return const Center(child: CircularProgressIndicator(),);
        }

        // loaded

        else if(state is PostLoaded){
          final allPosts=state.posts;

          if(allPosts.isEmpty){
            return const Center(
              child: Text('No posts available'),
            );
          }else{
            return ListView.builder(itemCount: allPosts.length
                ,itemBuilder: (context,index){

                  //get individual post
                  final post =allPosts[index];

                  //image
                  return PostTile(post: post,onDeletePressed: ()=>  deletePost(post.id));
                });
          }
        }
        //error
        else if(state is PostError){
          return Center(child:
            Text(state.message),);
        }else{
          return const SizedBox();
        }

      }
      )

    );
  }
}
