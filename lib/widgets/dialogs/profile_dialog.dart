import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../main.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(width: mq.width*.6, height: mq.height*.35, child: Stack(
        children: [
          Text(user.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          // user profile picture
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.25),
              child: CachedNetworkImage(
                width: mq.width*.5,
                fit:BoxFit.cover,
                imageUrl: user.image,
                errorWidget:(context,url,error)=>
                const CircleAvatar(child: Icon(CupertinoIcons.person)) ,
              ),
            ),
          ),
          Positioned(right: -10,top: -14, child: IconButton(onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder:(_)=> ViewProfileScreen(user: user)));
          },padding: EdgeInsets.all(0), icon: Icon(Icons.info_outline,color: Colors.blue,)))
        ],
      ),),
    );
  }
}