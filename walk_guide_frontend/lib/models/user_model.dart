class UserModel {
  final dynamic id;
  final String email;
  final String? nickname;
  final String? password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.nickname,
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  // 1. 서버에서 받아온 데이터를 Dart 객체로 변환
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      nickname: json['nickname'],
      password: json['password'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // 2. Dart 객체를 서버로 보낼 수 있는 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (nickname != null) 'nickname': nickname,
      if (password != null) 'password': password,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
