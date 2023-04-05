import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
//import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info(if null-> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: .1,
      child: InkWell(
        onTap: () {
          //for navigating to chat screen
          Navigator.push(context,MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,snapshot){ 
          final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data() as Map<String, dynamic>)).toList() ?? [];
              if (list.isNotEmpty) 
              _message = list[0];
          // final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          // if (list.isNotEmpty) 
          // _message = list[0];
             return ListTile(
          // trailing: Text(
          //   "12:00 PM",
          //   style: TextStyle(color: Colors.grey),
          // ),
          // last message time
          trailing:_message==null
          ?null
          : 
          _message!.read.isEmpty && _message!.fromId!=APIs.user.uid? 
          Container( 
            width: 15,
            height: 15,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.green),
          ):Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),style: TextStyle(color: Colors.black54),),
          title: Text(widget.user.name),
          subtitle: Row(
            children: [
              if(_message!=null && _message!.type==Type.image)
              Icon(Icons.image),
              Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'Image'
                                : _message!.msg
                            : widget.user.about,
                        maxLines: 1),
            ],
          ),
          //leading: CircleAvatar(child: Icon(CupertinoIcons.person,)),
          leading: InkWell(
            onTap: () {
              showDialog(context: context, builder: (_)=> ProfileDialog(user: widget.user,));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .3),
              child: CachedNetworkImage(
                  width: mq.height * 0.055,
                  height: mq.height * 0.055,
                  imageUrl: widget.user.image,
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(CupertinoIcons.person))),
            ),
          ),
        );
        },)
      ),
    );
  }
}
