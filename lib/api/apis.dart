import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';

import '../models/chat_user.dart';

class APIs {
  //for storing self info
  static late ChatUser me;
  //for accessing firebase messagin(Push notification)
  static FirebaseMessaging fMessaging=FirebaseMessaging.instance;
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  // for accessing firebase storage
  static FirebaseStorage storage=FirebaseStorage.instance;
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  // to return current user
  static User get user => auth.currentUser!;
  // for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }
  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async
  {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print('Push Token: $t');
      }
    });

    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }
  // for getting current user info
  static Future<void> getSelfInfo() async
  {
   await firestore.collection('users').doc(user.uid).get().then((user)  async {
      if(user.exists)
      {
        me=ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        print("My Data: ${user.data()}");
        // for setting user status to active
        APIs.updateActiveStatus(true);
      }
      else
      {
        await createUser().then((value){
          getSelfInfo();
        });
      }
   });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey,there I am using sandesh",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers()
  {
    return firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }

  static Future<void> updateUserInfo() async
  {
    await firestore.collection('users').doc(user.uid).update({"name":me.name,"about":me.about});
  }

  static Future<void> updateProfilePicture(File file) async
  { 
    final ext=file.path.split('.').last;
    log('Extension: $ext');
    //storage file ref with path
    final ref=storage.ref().child('profile pictures/${user.uid}.$ext');
    //uploading image
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0){
      log('Data Transfered: ${p0.bytesTransferred/1000} kb');
    });
    //updating image in forestore database
     me.image=await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({'image':me.image});
  }
  /* Chat screen related API*/
  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user)
  {
    return firestore
    .collection('chats/${getConversationID(user.id)}/messages/')
    .orderBy('sent',descending: true)
    .snapshots();
  }


  
static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
? '${user.uid}_$id':'${id}_${user.uid}';

static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async
{
  final time=DateTime.now().millisecondsSinceEpoch.toString();
  // message to send
  final Message message=Message(
    toId: chatUser.id,
    msg: msg,
    read: '',
    type: type,
    fromId: user.uid,
    sent: time,);

    final ref=firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  
}
static Future<void> updateMessageReadStatus(Message message) async
{
  firestore.collection('chats/${getConversationID(message.fromId)}/messages/').doc(message.sent).update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
}
static Stream<QuerySnapshot> getLastMessage(ChatUser user)
{
  //get only last message of a specific chat
  return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent',descending: true).limit(1).snapshots();
}

//send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
  //get users info
  static Stream<QuerySnapshot<Map<String,dynamic>>> getUserInfo(ChatUser chatUser)
  {
    return firestore.collection('users').where('id',isEqualTo:chatUser.id).snapshots();

  }
  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async
  {
     firestore.collection('users').doc(user.uid).update({
      'is_online':isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken
     });
  }
}
