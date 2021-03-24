import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/orderCard.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

String getOrderId="";
class OrderDetails extends StatelessWidget {
  final String orderID;

  OrderDetails({Key key , this.orderID}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    getOrderId =orderID;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future:  EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                .collection(EcommerceApp.collectionOrders).document(orderID).get(),
            builder: (c,snapshopt)
            {
              Map dataMap;
              if(snapshopt.hasData)
              {
                dataMap = snapshopt.data.data;
              }
              return snapshopt.hasData
                  ? Container(
                child: Column(
                  children: [
                    StatusBanner(status: dataMap[EcommerceApp.isSuccess],),
                    SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "₹" + dataMap[EcommerceApp.totalAmount].toString(),
                          style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold, ),

                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Order ID :" +getOrderId,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Ordered At: " +DateFormat("dd MMMM, yyyy - hh:mm aa")
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                        style: TextStyle(color: Colors.grey, fontSize: 16.0),
                      ),
                    ),
                    Divider(height: 2.0,),
                    FutureBuilder<QuerySnapshot>(
                      future: EcommerceApp.firestore
                          .collection("items").where("shortInfo",whereIn: dataMap[EcommerceApp.productID])
                          .getDocuments(),
                      builder: (c,dataSnapshopt)
                      {
                        return dataSnapshopt.hasData
                            ?OrderCard(
                          itemCount: dataSnapshopt.data.documents.length,
                          data: dataSnapshopt.data.documents,
                        )
                            :Center(child: circularProgress(),);
                      },
                    ),
                    Divider(height: 2.0,),
                    FutureBuilder<DocumentSnapshot>(
                      future:  EcommerceApp.firestore
                          .collection(EcommerceApp.collectionUser)
                          .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                          .collection(EcommerceApp.subCollectionAddress)
                          .document(dataMap[EcommerceApp.addressID])
                          .get(),
                      builder: (c,snap)
                      {
                        return snap.hasData
                            ?ShippingDetails(model: AddressModel.fromJson(snap.data.data),)
                            :Center(child: circularProgress(),);
                      },
                    ),

                  ],
                ),
              )
                  :Center(child: circularProgress(),);
            },
          ),
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;
  StatusBanner({Key key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;
    status ? iconData = Icons.done : iconData =  Icons.cancel;
    status ? msg = "Successfull" :"Unsuccessfull";

    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [Colors.indigo, Colors.lightBlueAccent],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: ()
            {
              SystemNavigator.pop();
            },
            child: Container(
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 20.0,),
          Text(
            "Order Placed"+msg,
            style :TextStyle(color: Colors.white),
          ),
          SizedBox( width:5.0,),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ShippingDetails extends StatelessWidget {
  AddressModel model;
  ShippingDetails({Key key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.0,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 90.0,),
          child: Text(
            "Shipment Details",
            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding:  EdgeInsets.symmetric(horizontal: 90.0,vertical: 5.0),
          width:screenWidth ,
          child: Table(
            children: [
              TableRow(
                  children: [
                    KeyText(msg: "Name",),
                    Text(model.name),

                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "Phone number",),
                    Text(model.phoneNumber),
                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "Flat No",),
                    Text(model.flatNumber),
                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "City",),
                    Text(model.city),
                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "State",),
                    Text(model.state),
                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "Pin Code",),
                    Text(model.pincode),
                  ]
              ),
            ],
          ),
        ),
        Padding(
          padding:EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: (){
                confirmedUserOrderReceived(context,getOrderId);
              },
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
                width: MediaQuery.of(context).size.width -40.0,
                height: 50.0,
                child: Center(
                  child: Text(
                    "Order Received", style: TextStyle(color: Colors.white,fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  confirmedUserOrderReceived(BuildContext context ,String mOrderId)
  {
    EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders).document(mOrderId).delete();
    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => StoreHome());
    Navigator.pushReplacement(context, route);
    Fluttertoast.showToast(msg: "Order has been received");
  }
}


