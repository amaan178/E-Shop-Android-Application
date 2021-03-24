import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formkey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cFlatHomeNumber = TextEditingController();
  final cCity = TextEditingController();
  final cState = TextEditingController();
  final cPincode = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            if(formkey.currentState.validate())
            {
              final model = AddressModel(
                name: cName.text.trim(),
                state: cState.text.trim(),
                pincode: cPincode.text,
                phoneNumber: cPhoneNumber.text,
                flatNumber: cFlatHomeNumber.text,
                city: cCity.text,
              ).toJson();

              //add to firestore
              EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                  .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.subCollectionAddress).document(DateTime.now().millisecondsSinceEpoch.toString())
                  .setData(model).then((value){
                final snack = SnackBar(content: Text("New Address Added successfully"));
                scaffoldKey.currentState.showSnackBar(snack);
                FocusScope.of(context).requestFocus(FocusNode());
                formkey.currentState.reset();
              });

              Route route = MaterialPageRoute(builder: (c) => StoreHome());
              Navigator.pushReplacement(context, route);
            }
          },
          label:Text("Done") ,
          backgroundColor: Colors.lightBlueAccent,
          icon: Icon(Icons.check),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Add New Address",
                    style: TextStyle(color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Name",
                      controller: cName,

                    ),
                    MyTextField(
                      hint: "Phone Number",
                      controller: cPhoneNumber,

                    ),
                    MyTextField(
                      hint: "Flat number or house number",
                      controller: cFlatHomeNumber,

                    ),
                    MyTextField(
                      hint: "City",
                      controller: cCity,

                    ),
                    MyTextField(
                      hint: "State",
                      controller: cState,

                    ),
                    MyTextField(
                      hint: "Pin Code",
                      controller: cPincode,

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  MyTextField({Key key, this.hint, this.controller,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child:TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val)=> val.isEmpty ? "Please fill all the feilds " : null,
      ) ,
    );
  }
}
