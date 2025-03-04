import 'package:flutter/material.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';

Widget FleetItem(Vehicle vehicle, int? index) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 17.0,vertical: 5.0),
    child: Container(
       // Takes full width of the parent
      padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 8.0), // Optional padding
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // Adds shadow for depth
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners for the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), // Same border radius for the image
                  child: Image.asset(
                    vehicle.picUrl,
                    fit: BoxFit.fill, // Fill the container with the image
                  ),
                ),
              ),

              SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vehicle.vehicleNo,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vehicle.model,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          ElevatedButton(onPressed: (){print("Service History  Clicked");}, child: Text("View History",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            style:ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),

            )
          )
        ],
      ),
    ),
  );
}
