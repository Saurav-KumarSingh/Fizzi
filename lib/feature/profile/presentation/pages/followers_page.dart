import 'package:fizzi/feature/profile/presentation/components/user_tile.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:fizzi/responsive/constrained_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowersPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowersPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ConstrainedScaffold(
        appBar: AppBar(
          title: const Text("Connections"),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor:Theme.of(context).colorScheme.primary ,
            tabs: [
              Tab(text: "Followers"),
              Tab(text: "Following"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Followers tab
            _buildUserList(followers, "No Followers", context),
            // Following tab
            _buildUserList(following, "No Following", context),
          ],
        ),
      ),
    );


  }

  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
      itemCount: uids.length,
      itemBuilder: (context, index) {
        // get each uid
        final uid = uids[index];

        return FutureBuilder(future: context.read<ProfileCubit>().getUserProfile(uid),
        builder: (context, snapshot) {
        // user loaded
        if (snapshot.hasData) {
        final user = snapshot.data!;
        return UserTile(user:user);
        }
        // loading..
        else if (snapshot.connectionState ==
        ConnectionState.waiting) {
        return ListTile(title: Text("Loading..."));
        }
        //not found
          else{
            return ListTile(title: Text("User not found"),);
        }
        },
        );
      },
    );
  }
}
