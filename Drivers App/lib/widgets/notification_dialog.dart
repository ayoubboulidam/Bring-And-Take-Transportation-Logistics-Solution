import 'dart:async';

import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/pages/new_trip_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'loading_dialog.dart';


class NotificationDialog extends StatefulWidget
{
  TripDetails? tripDetailsInfo;

  NotificationDialog({super.key, this.tripDetailsInfo,});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog>
{
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();
  String packageWeight = "Loading...";
  String fareAmountExpected = "Loading...";

  cancelNotificationDialogAfter20Sec()
  {
    const oneTickPerSecond = Duration(seconds: 1);

    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer)
    {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if(tripRequestStatus == "accepted")
      {
        timer.cancel();
        driverTripRequestTimeout = 20;
      }

      if(driverTripRequestTimeout == 0)
      {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
        //audioPlayer.stop();
      }
    });
  }

  // Fetch package weight and fare amount from Firebase
  fetchPackageWeightAndFare() async {
    try {
      // Get package weight
      DataSnapshot packageWeightSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.tripDetailsInfo!.tripID!)
          .child("packageWeight")
          .get();

      // Get fare amount
      DataSnapshot fareAmountSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.tripDetailsInfo!.tripID!)
          .child("fareAmountExpected")
          .get();

      if (mounted) {
        setState(() {
          packageWeight = packageWeightSnapshot.value?.toString() ?? "Not specified";
          fareAmountExpected = fareAmountSnapshot.value?.toString() ?? "Not specified";
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          packageWeight = "Not available";
          fareAmountExpected = "Not available";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    cancelNotificationDialogAfter20Sec();
    fetchPackageWeightAndFare();
  }

  checkAvailabilityOfTripRequest(BuildContext context) async
  {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: 'please wait...',),
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once()
        .then((snap)
    {
      Navigator.pop(context);
      Navigator.pop(context);

      String newTripStatusValue = "";
      if(snap.snapshot.value != null)
      {
        newTripStatusValue = snap.snapshot.value.toString();
      }
      else
      {
        cMethods.displaySnackBar("Trip Request Not Found.", context);
      }

      if(newTripStatusValue == widget.tripDetailsInfo!.tripID)
      {
        driverTripStatusRef.set("accepted");

        //disable homepage location updates
        cMethods.turnOffLocationUpdatesForHomePage();

        Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripPage(newTripDetailsInfo: widget.tripDetailsInfo)));
      }
      else if(newTripStatusValue == "cancelled")
      {
        cMethods.displaySnackBar("Trip Request has been Cancelled by user.", context);
      }
      else if(newTripStatusValue == "timeout")
      {
        cMethods.displaySnackBar("Trip Request timed out.", context);
      }
      else
      {
        cMethods.displaySnackBar("Trip Request removed. Not Found.", context);
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 30.0,),

            Image.asset(
              "assets/images/uberexec.png",
              width: 140,
            ),

            const SizedBox(height: 16.0,),

            //title
            const Text(
              "NEW TRIP REQUEST",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const  SizedBox(height: 20.0,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 10.0,),

            //pick - dropoff
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickupAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15,),

                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/images/final.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.dropOffAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

            // Package Weight and Fare Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Package Weight
                  Row(
                    children: [
                      Icon(
                        Icons.scale,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Package Weight: ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          packageWeight,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Fare Amount
                  Row(
                    children: [

                      Text(
                        "Expected Fare (In Dhs) : ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          fareAmountExpected,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 8,),

            //decline btn - accept btn
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        Navigator.pop(context);
                        //audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF5C02),
                      ),
                      child: const Text(
                        "DECLINE",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        //audioPlayer.stop();

                        setState(() {
                          tripRequestStatus = "accepted";
                        });

                        checkAvailabilityOfTripRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "ACCEPT",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }
}