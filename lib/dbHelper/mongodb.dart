 
import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    var db = await Db.create(MONGO_COMM_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    userCollection = db.collection(USER_COLLECTION);
  }

  // static register(String firstName, String lastName, String email) async {
  //   // print("nowwwwwwwwwwwwwwww");
  //   var db = await Db.create(MONGO_COMM_URL);
  //   await db.open();
  //   inspect(db);
  //   await userCollection.insertOne(
  //       {"firstName": firstName, "lastName": lastName, "email": email});

  //       //  print("nowwwwwwwwwwwwwwww222233");
  // }


  static register(String firstName, String lastName, String email) async {
  var db = await Db.create(MONGO_COMM_URL);
  await db.open();
  var userCollection = db.collection('users'); // Assuming 'users' is the collection name

  await userCollection.insertOne({
    "firstName": firstName,
    "lastName": lastName,
    "email": email
  });

  await db.close();
}


  static test() async {
    print("nowwwwwwwwwwwwwwww");
    var db = await Db.create(MONGO_COMM_URL);
    await db.open();
    inspect(db);
    await userCollection.insertOne(
        {"firstName": "Test", "lastName": "test", "email": "test"});

         print("nowwwwwwwwwwwwwwww222233");
  }


  static deleteAccount(String email) async {
    await userCollection.deleteOne({"email": email});
  }

  // await collection.insertOne({
  // "username" : "mp",
  // "name" : "Max Payne",
  // "email" : "maxpayne@gmail.com"
  // });

  // await collection.insertMany([
  //   {"username": "mp", "name": "Max Payne", "email": "maxpayne@gmail.com"},
  //   {"username": "mp2", "name": "Max Payne2", "email": "maxpayne2@gmail.com"}
  // ]);

  // await collection.update(
  //     where.eq("username", "mp"), modify.set("name", "Max p"));

  // await collection.updateMany(
  //     where.eq("username", "mp"), modify.set("name", "Max p"));

  // print(await collection.find().toList());

  // await collection.deleteOne({"username": "mp"});
  // await collection.deleteMany({"username": "mp2"});

  // static Future<List<Map<String, dynamic>>> getDocuments() async {
  //   try {
  //     final users = await db.collection(USER_COLLECTION).find().toList();
  //     return users;
  //   } catch (e) {
  //     print(e);
  //     return Future.value(e as FutureOr<List<Map<String, dynamic>>>?);
  //   }
  // }

// static insert(User user) async {
//     await userCollection.insertAll([user.toMap()]);
//   }

//  static update(User user) async {
//     var u = await userCollection.findOne({"_id": user.uid});
//     u["firstName"] = user;
//     u["lastName"] = user;
//     u["email"] = user.email;
//     await userCollection.save(u);
//   }

  // static delete(User user) async {
  //   await userCollection.remove(where.id(user.uid as ObjectId));
  // }
}
