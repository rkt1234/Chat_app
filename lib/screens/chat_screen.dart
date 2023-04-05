//import 'dart:html';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//import 'package:message.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];
  // for handling message text changes
  final _textController=TextEditingController();
  bool _showEmoji=false; // for emoji
  bool _isUploading=false; // for checking if image is uploading or not
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are shown and back button is pressed then hide emojis
          // or else simple close current screen on back button
          onWillPop: () {
            if(_showEmoji)
            {
              setState(() {
                _showEmoji=!_showEmoji;
              });
              return Future.value(false);
            }
            else
            return Future.value(true);
          },
          child: Scaffold(
            backgroundColor: Color.fromARGB(255,234,248,255),
            appBar: AppBar(
              elevation: 0.1,
              automaticallyImplyLeading: false,
              flexibleSpace: InkWell(
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder:(_)=>ViewProfileScreen(user: widget.user)));
                },
                child: StreamBuilder(
                  stream: APIs.getUserInfo(widget.user),
                  builder: (context, snapshot) {
                     final data = snapshot.data?.docs;
                     final list =data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                    return Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: mq.height),
                        ),
                        //SizedBox(width: 20,),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                        CircleAvatar(
                          backgroundImage: NetworkImage(list.isNotEmpty ? list[0].image : widget.user.image),
                          radius: 25,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Text(
                              list.isNotEmpty ? list[0].name : widget.user.name,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white)),
                          ],
                        )
                      ],
                    );
                  }
                ),
              ),
            ),
            body: Column(children: [
              Expanded(
                child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: ((context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return SizedBox();
          
                        // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          //print('Data: ${jsonEncode(data![0].data())}');
                             //final data = snapshot.data?.docs;
                             //log('Data : ${data}');
                          _list=data?.map((e)=> Message.fromJson(e.data())).toList()??[];
                            print("ye hai");
                            print(_list);
                          // final _list=['hi','frandship karoge?'];
                          // _list.clear();
                          // _list.add(Message(
                          //     toId: "xyz",
                          //     msg: "Hii",
                          //     read: '',
                          //     type: Type.text,
                          //     fromId: APIs.user.uid,
                          //     sent: "12:00 AM"));
                          // _list.add(Message(
                          //     toId: APIs.user.uid,
                          //     msg: "Hello",
                          //     read: '',
                          //     type: Type.text,
                          //     fromId: 'xyz',
                          //     sent: "12:05 AM"));
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Say hi",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                Lottie.network(
                                    "https://assets10.lottiefiles.com/packages/lf20_hqfbl3nn.json",
                                    height: mq.height * 0.05),
                              ],
                            ));
                          }
                      }
                    })),
              ),
                // progress indicator for showing something is uploading
                if(_isUploading)
                Align(alignment:Alignment.centerRight , child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                )),

              _chatInput(),
                if(_showEmoji)            
                SizedBox(
                  height: mq.height*.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: Color.fromARGB(255,234,248,255),
                      columns: 8,
                      emojiSizeMax: 32*(Platform.isIOS ?1.30:1)
                    ),
                  ),
                )
              
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .025, vertical: mq.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showEmoji=!_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  Expanded(
                      child: TextField(
                        controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: (){
                      setState(() {
                        if(_showEmoji)
                        _showEmoji=!_showEmoji;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Type message here...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  // pick image from gallery
                  IconButton(
                      onPressed: () async{
                          final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),
                      // take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() => _isUploading = true);

                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),

          // send message button
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            onPressed: () {
              if(_textController.text.isNotEmpty)
              {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text="";
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
