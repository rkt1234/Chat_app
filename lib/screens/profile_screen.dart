import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey=GlobalKey<FormState>();
  String? _image;
  // void message()
  // {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("updated")));
  // }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Center(child: Text("Profile Screen"))),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              // for showing progress dialog
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);
              //signout from app
              await APIs.auth.signOut().then((value) async  {
                await GoogleSignIn().signOut().then((value)  {
                  // for hiding progress dialog
                  Navigator.pop(context);
                  //for moving to home screen
                  Navigator.pop(context);

                  APIs.auth=FirebaseAuth.instance;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            icon: Icon(Icons.logout),
            label: Text("Logout"),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                Stack(
                  children: [
                    // profile picture
                    _image!=null?
                    //local image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: Image.file(
                        File(_image!),
                        width: mq.height*.2,
                        height: mq.height*.2,
                       fit: BoxFit.fill,
                      ),
                    )
                    :

                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          width: mq.height * .2,
                          height: mq.height * .2,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) => CircleAvatar(
                                child: Icon(CupertinoIcons.person),
                              )),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        elevation: 0.1,
                        shape: CircleBorder(),
                        onPressed: () {
                          _showBottomSheet();
                        },
                        color: Colors.white,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) =>APIs.me.name=val??"",
                  validator: (val) => val!=null && val.isNotEmpty?null:"Required Field",
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Enter your name',
                      label: Text("Name")),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                TextFormField(
                  onSaved: (val) =>APIs.me.about=val??"",
                  validator: (val) => val!=null && val.isNotEmpty?null:"Required Field",
                  initialValue: widget.user.about,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info,
                        color: Colors.blue,
                      ),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'About',
                      label: Text("About")),
                ),
                SizedBox(
                  height: mq.height * .05,
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                    onPressed: () {
                      if(_formKey.currentState!.validate())
                      {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Center(child: Text("Profile updated successfully"))));
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text("UPDATE"))
              ]),
            ),
          ),
        ),
      ),
    );
  }
  // bottom sheet for picking a profile picture for user
  void _showBottomSheet()
  {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
      context: context, builder: (_){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.height*.05),
          children: [
            Text("Pick Profile Picture",textAlign: TextAlign.center, style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
            SizedBox(height: mq.height*.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                //pick image from gallery
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  fixedSize: Size(mq.width*.3,mq.height*.15)
                ),
                //onPressed: () {},
              onPressed: () async{
                final ImagePicker picker=ImagePicker();
                //pick an image
                final XFile? image=await picker.pickImage(source:ImageSource.gallery,imageQuality: 80);
                if(image!=null){
                print(image.path);
                setState(() {
                 _image=image.path; 
                });
                APIs.updateProfilePicture(File(_image!));
                //for hiding bottom sheet
                Navigator.pop(context);}
              },
              child: Image.asset('images/add.png')
              ),
              SizedBox(width: 20,),

              //pick image from camera
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  fixedSize: Size(mq.width*.3,mq.height*.15)
                ),
              onPressed: () async{
                final ImagePicker picker=ImagePicker();
                //pick an image
                final XFile? image=await picker.pickImage(source:ImageSource.camera,imageQuality: 80);
                if(image!=null){
                print(image.path);
                setState(() {
                 _image=image.path; 
                });
                APIs.updateProfilePicture(File(_image!));
                //for hiding bottom sheet
                Navigator.pop(context);}
              },
              child: Image.asset('images/camera.png')
              )
            ],)
          ],
        );
      }
    );
  }
}
