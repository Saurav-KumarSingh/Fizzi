//FOLLOW and UNFOLLOW

import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {

    // print(isFollowing);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: isFollowing
            ? Theme.of(context).colorScheme.primary
            : Colors.blue,
        textColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(
          horizontal: 36, // more horizontal padding → wider button
          vertical: 14,   // more vertical padding → taller button
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isFollowing
              ? const BorderSide(color: Colors.blue, width: 2) // blue border when unfollow
              : BorderSide.none,
        ),
        child: Text(
          isFollowing ? "Unfollow" : "Follow",
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
