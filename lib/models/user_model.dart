class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  // Supabase metadata se data nikalne ke liye
  factory UserModel.fromSupabase(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }
}