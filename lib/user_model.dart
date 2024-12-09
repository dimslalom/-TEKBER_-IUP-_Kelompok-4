class User {
  String username;
  String password;
  String bio;
  String profileImage;

  User({
    required this.username,
    required this.password,
    this.bio = 'No bio yet',
    this.profileImage = 'default',
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'bio': bio,
    'profileImage': profileImage,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] ?? '',
    password: json['password'] ?? '',
    bio: json['bio'] ?? 'No bio yet',
    profileImage: json['profileImage'] ?? 'default',
  );
}