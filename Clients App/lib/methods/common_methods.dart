import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:http/http.dart' as http;
import 'package:users_app/models/address_model.dart';

import '../models/direction_details.dart';

class CommonMethods
{
  Future<void> checkConnectivity(BuildContext context) async {
    try {
      // Check the current network connection
      var connectionResult = await Connectivity().checkConnectivity();

      // Validate the connection status
      if (connectionResult == ConnectivityResult.none) {
        if (!context.mounted) return;

        displaySnackBar(
          "Your Internet is not available. Check your connection and try again.",
          context,
        );
      } else {
        // Optionally, check if there's an actual internet connection
        final hasInternet = await _hasInternetAccess();
        if (!hasInternet) {
          if (!context.mounted) return;

          displaySnackBar(
            "You are connected to a network, but no internet access is available.",
            context,
          );
        }
      }
    } catch (e) {
      debugPrint("Error while checking connectivity: $e");

      if (!context.mounted) return;

      displaySnackBar(
        "Unable to check connectivity. Please try again later.",
        context,
      );
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint("No internet access: $e");
      return false;
    }
  }

  void displaySnackBar(String messageText, BuildContext context) {
    // Ensure the widget context is valid
    if (!context.mounted) return;

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messageText,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3), // Customize duration
      ),
    );
  }


  static sendRequestToAPI(String apiUrl) async
  {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try
    {
      if(responseFromAPI.statusCode == 200)
      {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }
      else
      {
        return "error";
      }
    }
    catch(errorMsg)
    {
      return "error";
    }
  }

  ///Reverse GeoCoding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(Position position, BuildContext context) async
  {
    String humanReadableAddress = "";
    String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if(responseFromAPI != "error")
    {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  ///Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async
  {
    String urlDirectionsAPI = "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if(responseFromDirectionsAPI == "error")
    {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  String calculateFareAmount(DirectionDetails directionDetails, double weightInKg,double baseFareAmount, double distancePerKmAmount, double durationPerMinuteAmount, double weightFactor) {
    double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;
    double totalWeightFareAmount = weightInKg * weightFactor;

    double overAllTotalFareAmount = (baseFareAmount + totalDistanceTravelFareAmount + totalDurationSpendFareAmount + totalWeightFareAmount)*10;

    return overAllTotalFareAmount.toStringAsFixed(1);
  }

}