import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.indigo, Colors.lightBlueAccent],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: Text(
          "e-Shop",
          style: TextStyle(fontSize: 55.0, color: Colors.white, fontFamily: "Signatra"),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/admin.png",
                height: 240.0,
                width: 240.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin Login",
                style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "id",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            RaisedButton(
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty
                    && _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                    context: context,
                    builder: (c)
                    {
                      return ErrorAlertDialog(message: "Please write Correct id and password",);
                    }
                );
              },
              color: Colors.white,
              child: Text("login In", style: TextStyle(color: Colors.black),),
            ),
            SizedBox(
              height: 100.0,
            ),
            Container(
              height: 2.0,
              width: _screenWidth * 0.8,
              color: Colors.white,
            ),
            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AuthenticScreen())),
              icon: (Icon(Icons.nature_people, color: Colors.white)),
              label: Text("i am not Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            ),
            SizedBox(
              height: _screenHeight / 5,
            ),
          ],
        ),
      ),
    );
  }

  loginAdmin()
  {
    Firestore.instance.collection("admins").getDocuments().then((snapshot){
      snapshot.documents.forEach((result){
        if(result.data["id"] != _adminIDTextEditingController.text.trim())
        {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter correct id"),));
        }
        else if(result.data["password"] != _passwordTextEditingController.text.trim())
        {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter correct Password!"),));
        }
        else
        {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Welcome Dear Admin, " + result.data["name"]),));
          setState(() {
            _adminIDTextEditingController.text = "";
            _passwordTextEditingController.text = "";
          });

          Route route = MaterialPageRoute(builder: (c) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
