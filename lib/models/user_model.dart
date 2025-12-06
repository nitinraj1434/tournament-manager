class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final double walletBalance;
  final String role;
  final String phoneNumber;
  final String bio;
  final String address;
  final int matchesPlayed;
  final int matchesWon;
  final double totalEarnings;
  final String gameUid;
  final String gameName;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.walletBalance,
    required this.role,
    this.phoneNumber = '',
    this.bio = '',
    this.address = '',
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.totalEarnings = 0.0,
    this.gameUid = '',
    this.gameName = '',
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      role: data['role'] ?? 'user',
      phoneNumber: data['phoneNumber'] ?? '',
      bio: data['bio'] ?? '',
      address: data['address'] ?? '',
      matchesPlayed: data['matchesPlayed'] ?? 0,
      matchesWon: data['matchesWon'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      gameUid: data['gameUid'] ?? '',
      gameName: data['gameName'] ?? '',
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'walletBalance': walletBalance,
      'role': role,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'address': address,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'totalEarnings': totalEarnings,
      'gameUid': gameUid,
      'gameName': gameName,
      'fcmToken': fcmToken,
    };
  }
}
