class UserModel {
  final String? id; // Made nullable
  final List<String> imageUrls;
  final String? status;
  final int? age;
  final String? height;
  final String? weight;
  final String? bodyType;
  final String? aboutMe;
  final String? lookingFor;
  final String? meetAt;
  final String? acceptsNsfwPics;
  final String? distance;
  final String? gender;
  final String? pronouns;
  final String? race;
  final String? relationshipStatus;
  final String? userName;
  final String? joined;
  final bool isFresh;
  final List<String>? position;
  final List<String>? tribes;
  final String? sexualOrientation; // Added sexualOrientation

  UserModel(
      {this.id, // No longer required
      required this.imageUrls,
      this.status,
      this.age,
      this.height,
      this.bodyType,
      this.aboutMe,
      this.lookingFor,
      this.meetAt,
      required this.acceptsNsfwPics,
      this.distance,
      this.gender,
      this.pronouns,
      this.race,
      this.relationshipStatus,
      this.userName,
      this.joined,
      required this.isFresh,
      this.weight,
      this.tribes,
      this.sexualOrientation, // Ensure sexualOrientation is included
      this.position // Ensure weight is also included here if it was missing
      });

  // Factory constructor for creating a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'] as String?, // Safely parse nullable String
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        status: json['status'] as String?,
        age: json['age'] as int?,
        height: json['height'] as String?,
        weight: json['weight'] as String?,
        bodyType: json['bodyType'] as String?,
        aboutMe: json['aboutMe'] as String?,
        lookingFor: json['lookingFor'] as String?,
        meetAt: json['meetAt'] as String?,
        acceptsNsfwPics: json['acceptsNsfwPics'] as String?,
        distance: json['distance'] as String?,
        gender: json['gender'] as String?,
        pronouns: json['pronouns'] as String?,
        race: json['race'] as String?,
        relationshipStatus: json['relationshipStatus'] as String?,
        userName: json['userName'] as String?,
        joined: json['joined'] as String?,
        isFresh: json['isFresh'] is bool ? json['isFresh'] as bool : false,
        position: json['position'] != null
            ? List<String>.from(json['position'])
            : [], // Handle nullable tribes,
        tribes: json['tribes'] != null
            ? List<String>.from(json['tribes'])
            : [], // Handle nullable tribes,
        sexualOrientation: json['sexualOrientation'] as String?);
  }

  // Method to convert a UserModel instance to a JSON-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrls': imageUrls,
      'status': status,
      'age': age,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'aboutMe': aboutMe,
      'lookingFor': lookingFor,
      'meetAt': meetAt,
      'acceptsNsfwPics': acceptsNsfwPics,
      'distance': distance,
      'gender': gender,
      'pronouns': pronouns,
      'race': race,
      'relationshipStatus': relationshipStatus,
      'userName': userName,
      'joined': joined,
      'isFresh': isFresh,
      'position': position,
    };
  }

  // You can also add a copyWith method for immutability and easy updates
  UserModel copyWith(
      {String? id,
      List<String>? imageUrls,
      String? status,
      int? age,
      String? height,
      String? weight,
      String? bodyType,
      String? aboutMe,
      String? lookingFor,
      String? meetAt,
      String? acceptsNsfwPics,
      String? distance,
      String? gender,
      String? pronouns,
      String? race,
      String? relationshipStatus,
      String? userName,
      String? joined,
      bool? isFresh,
      List<String>? position,
      List<String>? tribes}) {
    return UserModel(
        id: id ?? this.id,
        imageUrls: imageUrls ?? this.imageUrls,
        status: status ?? this.status,
        age: age ?? this.age,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bodyType: bodyType ?? this.bodyType,
        aboutMe: aboutMe ?? this.aboutMe,
        lookingFor: lookingFor ?? this.lookingFor,
        meetAt: meetAt ?? this.meetAt,
        acceptsNsfwPics: acceptsNsfwPics ?? this.acceptsNsfwPics,
        distance: distance ?? this.distance,
        gender: gender ?? this.gender,
        pronouns: pronouns ?? this.pronouns,
        race: race ?? this.race,
        relationshipStatus: relationshipStatus ?? this.relationshipStatus,
        userName: userName ?? this.userName,
        joined: joined ?? this.joined,
        isFresh: isFresh ?? this.isFresh,
        position: position ?? this.position,
        tribes: tribes ?? this.tribes);
  }
}
