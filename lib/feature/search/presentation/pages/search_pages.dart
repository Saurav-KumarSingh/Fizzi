import 'package:fizzi/feature/profile/presentation/components/user_tile.dart';
import 'package:fizzi/feature/search/presentation/cubit/search_cubit.dart';
import 'package:fizzi/feature/search/presentation/cubit/search_states.dart';
import 'package:fizzi/responsive/constrained_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();
  late SearchCubit searchCubit;

  @override
  void initState() {
    super.initState();
    searchCubit = context.read<SearchCubit>();

    // listen for changes in search field
    _searchController.addListener(onSearchChange);
  }

  void onSearchChange() {
    final query = _searchController.text.trim();
    searchCubit.searchUsers(query);
  }

  @override
  void dispose() {
    _searchController.removeListener(onSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text("No users found"));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              },
            );
          } else if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Start searching for users.."));
        },
      ),
    );
  }
}
