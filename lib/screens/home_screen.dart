import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   List<ChatUser> _list=[]; 
   final List<ChatUser> _searchList=[];
   bool _isSearching=false;
   void initState()
   {
    super.initState();
    APIs.getSelfInfo();
    
    //for updating user active status according to lifecycle evenets
    //resume -- active or online
    //pause--inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print(message);

      if(APIs.auth.currentUser!=null)
      {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      
      return Future.value(message);
    });
   }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => FocusScope.of(context).unfocus(),
      child:WillPopScope(
        onWillPop: () {
          if(_isSearching)
          {
            setState(() {
              _isSearching=false;
            });
            return Future.value(false);
          }
           else
            {
              return Future.value(true);
            }
            
        },
        child: Scaffold(
          appBar: AppBar(
           
            elevation: 0,
            leading: Icon(CupertinoIcons.home),
            centerTitle: true,
            title: _isSearching?TextField(
              style: TextStyle(fontSize: 16, letterSpacing: .5),
              onChanged: (val){
                // search logic to be implemented here
                _searchList.clear();
                for(var i in _list)
                {
                  if(i.name.toLowerCase().contains(val.toLowerCase()))
                  {
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
              cursorColor: Colors.white,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name',
                
                ),
              
            ):Text(
              "Sandesh",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22),
            ),
            actions: [
              IconButton(onPressed: () {
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid: Icons.search)),
              IconButton(onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me,)));}, icon: Icon(Icons.person)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                // await APIs.auth.signOut();
                // await GoogleSignIn().signOut();
              },
              child: Icon(
                Icons.add_comment_rounded,
                size: 40,
              ),
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: ((context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
          
                  // if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    //log('Data : ${data}');
                   _list=data?.map((e)=> ChatUser.fromJson(e.data())).toList()??[];
                  return(_list.isNotEmpty==true? ListView.builder(
                        padding: EdgeInsets.only(top: mq.height * 0.02),
                        itemCount: _isSearching?_searchList.length:_list.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                         // return Text('Name : ${list[index]}');
                         return ChatUserCard(user: _isSearching?_searchList[index]:_list[index]);
                        }): Center(child: Text("No Connections found!!",style: TextStyle(fontSize: 20),)));
                    
                }
              }
              )
              ),
        ),
      ),
    );
  }
}
