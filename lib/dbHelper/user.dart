 

class User {
  String id;
  final String firstName;
  final String lastName;
  final String email;
  // final String userName;
  // final String password;
  // final Array favorites;
  // final String profilePic;

  User(
      {this.id = "",
      required this.firstName,
      required this.lastName,
      required this.email,
      // required this.userName,
      // required this.password,
      // required this.favorites,
      // required this.profilePic
      });


 Map<String, Object?> toMap() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }


  User.fromJson(Map<String, Object?> json)
      : this(
            id: json['_id']! as String,
            firstName: json['firstName']! as String,
            lastName: json['lastName']! as String,
            email: json['email']! as String,
            // userName: json['userName']! as String,
            // password: json['password']! as String,
            // favorites: json['favorites']! as Array,
            // profilePic: json['profilePic']! as String
            );

  Map<String, Object?> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      // 'userName': userName,
      // 'password': password,
      // 'favorites': favorites,
      // 'profilePic': profilePic,
    };
  }
}