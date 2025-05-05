import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    String dropOffDestinationAddress =
    Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName
        .toString();
    String pickUpAddress =
    Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName
        .toString();

    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $oauthToken",
    };

    Map<String, dynamic> titleBodyNotificationMap = {
      "title": "NET TRIP REQUEST from $userName",
      "body": "PickUp Location: $pickUpAddress \nDropOff Location: $dropOffDestinationAddress",
    };

    Map<String, dynamic> dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "tripID": tripID,
    };

    Map<String, dynamic> bodyNotificationMap = {
      "message": {
        "notification": titleBodyNotificationMap,
        "data": dataMapNotification,
        "token": deviceToken,
      }
    };

    await http.post(
      Uri.parse("https://fcm.googleapis.com/....messages:send"),
      headers: headerNotificationMap,
      body: jsonEncode(bodyNotificationMap),
    );
  }
}
