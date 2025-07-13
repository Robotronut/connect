// lib/models/user_model.dart

class UserModel {
  final String id;
  final List<String> imageUrls;
  final String status;
  final int age;
  final String height;
  final String weight;
  final String build;
  final String aboutMe;
  final String lookingFor;
  final String meetAt;
  final String nsfwPics;
  final String distance;
  final String gender;
  final String pronouns;
  final String race;
  final String relationshipStatus;

  final String
      userName; // Assuming this is always present and non-null from API

  UserModel({
    required this.id,
    required this.imageUrls,
    required this.status,
    required this.age,
    required this.height,
    required this.weight,
    required this.build,
    required this.aboutMe,
    required this.lookingFor,
    required this.meetAt,
    required this.nsfwPics,
    required this.distance,
    required this.gender,
    required this.pronouns,
    required this.race,
    required this.relationshipStatus,
    required this.userName,
  });

  // Factory constructor for creating a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      imageUrls: List<String>.from(
          json['imageUrls'] ?? []), // Safely handle null/empty list
      status: json['status'] as String,
      age: json['age'] as int,
      height: json['height'] as String,
      weight: json['weight'] as String,
      build: json['build'] as String,
      aboutMe: json['aboutMe'] as String,
      lookingFor: json['lookingFor'] as String,
      meetAt: json['meetAt'] as String,
      nsfwPics: json['nsfwPics'] as String,
      distance: json['distance'] as String,
      gender: json['gender'] as String,
      pronouns: json['pronouns'] as String,
      race: json['race'] as String,
      relationshipStatus: json['relationshipStatus'] as String,
      userName:
          json['userName'] as String, // Ensure this matches API key and type
    );
  }


  // Method to convert a UserModel instance to a JSON-compatible map
  // This is often named 'toMap' or 'toJson'
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrls': imageUrls,
      'status': status,
      'age': age,
      'height': height,
      'weight': weight,
      'build': build,
      'aboutMe': aboutMe,
      'lookingFor': lookingFor,
      'meetAt': meetAt,
      'nsfwPics': nsfwPics,
      'distance': distance,
      'gender': gender,
      'pronouns': pronouns,
      'race': race,
      'relationshipStatus': relationshipStatus,
      'userName': userName,
    };
  }

  // You can also add a copyWith method for immutability and easy updates
  UserModel copyWith({
    String? id,
    List<String>? imageUrls,
    String? status,
    int? age,
    String? height,
    String? weight,
    String? build,
    String? aboutMe,
    String? lookingFor,
    String? meetAt,
    String? nsfwPics,
    String? distance,
    String? gender,
    String? pronouns,
    String? race,
    String? relationshipStatus,
    String? userName,
  }) {
    return UserModel(
      id: id ?? this.id,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      build: build ?? this.build,
      aboutMe: aboutMe ?? this.aboutMe,
      lookingFor: lookingFor ?? this.lookingFor,
      meetAt: meetAt ?? this.meetAt,
      nsfwPics: nsfwPics ?? this.nsfwPics,
      distance: distance ?? this.distance,
      gender: gender ?? this.gender,
      pronouns: pronouns ?? this.pronouns,
      race: race ?? this.race,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      userName: userName ?? this.userName,
    );
  }
}
