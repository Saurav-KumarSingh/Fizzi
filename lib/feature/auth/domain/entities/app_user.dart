class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  // Convert user -> JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  // Convert JSON -> user
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}
