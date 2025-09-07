import 'package:fizzi/feature/home/presentation/components/my_drawer_tile.dart';
import 'package:fizzi/feature/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Column(
            children: [
              // logo
              Icon(
                  Icons.person,
                  size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              Divider(color: Theme.of(context).colorScheme.secondary,),
              // quick links

              // home

              MyDrawerTile(title: 'H O M E', icon: Icons.home_filled, onTap: (){
                Navigator.pop(context);
              }),

              // profile

              MyDrawerTile(title: 'P R O F I L E', icon: Icons.person, onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProfilePage()));
              }),

              // search

              MyDrawerTile(title: 'S E A R C H', icon: Icons.search, onTap: (){

              }),


              // settings

              MyDrawerTile(title: 'S E T T I N G S', icon: Icons.settings, onTap: (){}),


              const Spacer(),

              // logout

              MyDrawerTile(title: 'L O G O U T', icon: Icons.logout, onTap: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
                }),


            ],
          ),
        ),
      ),
    );
  }
}
