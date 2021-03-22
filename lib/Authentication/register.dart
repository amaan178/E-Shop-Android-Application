import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _cPasswordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 10.0,),
            InkWell(
              onTap: getImage,
              child: CircleAvatar(
                radius: _screenWidth * 0.15, //the circle will be formed with the help of this ratio
                backgroundColor: Colors.white,
                backgroundImage: _imageFile==null ? null : FileImage(_imageFile),
                child: _imageFile == null
                  ? Icon(Icons.add_photo_alternate, size: _screenWidth * 0.15, color: Colors.grey,)
                  : null,
              ),
            ),
            SizedBox(height: 8.0,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameTextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordTextEditingController,
                    data: Icons.person,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () { uploadAndSaveImage(); },
              color: Colors.white,
              child: Text("Sign up", style: TextStyle(color: Colors.black),),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 3.0,
              width: _screenWidth * 0.8,
              color: Colors.white,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _selectAndPickImage() async
  // {
  //   // ignore: deprecated_member_use
  //   _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  // }

  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadAndSaveImage() async
  {
    if(_imageFile == null)
    {
      showDialog(
        context: context,
        builder: (c)
        {
          return ErrorAlertDialog(message: "Please select an image file!");
        }
      );
    }
    else
    {
      _passwordTextEditingController.text == _cPasswordTextEditingController.text
          ? _emailTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
          && _cPasswordTextEditingController.text.isNotEmpty && _nameTextEditingController.text.isNotEmpty
          ? uploadToStorage()
          : displayDialog("Please fill up the registration complete form..")
          : displayDialog("Password do not match.");
    }
  }

  displayDialog(String msg)
  {
    showDialog(
      context: context,
      builder: (c)
        {
          return ErrorAlertDialog(message: msg,);
        }
    );
  }

  uploadToStorage() async
  {
    showDialog(
      context: context,
      builder: (c)
      {
        return LoadingAlertDialog(message: "Registering, Please wait.....");
      }
    );
    String imageFileName = DateTime.now().microsecondsSinceEpoch.toString(); //wll give unique name to save the file
    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((urlImage){
      userImageUrl = urlImage;

      _registerUser();
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async
  {
    FirebaseUser firebaseUser;

    await _auth.createUserWithEmailAndPassword
    (
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((auth){
      firebaseUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c)
        {
          return ErrorAlertDialog(message: error.message.toString(),);
        }
      );
    });

    if(firebaseUser != null){
      saveUserInfoToFirStore(firebaseUser).then((value){
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserInfoToFirStore(FirebaseUser fUser) async
  {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid" : fUser.uid,
      "email" : fUser.email,
      "name" : _nameTextEditingController.text.trim(),
      "url" : userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"],
    });

    await EcommerceApp.sharedPreferences.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, fUser.email);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, _nameTextEditingController.text);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}

