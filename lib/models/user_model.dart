class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as dynamic).toDate() 
          : null,
      lastLogin: data['lastLogin'] != null 
          ? (data['lastLogin'] as dynamic).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }
}