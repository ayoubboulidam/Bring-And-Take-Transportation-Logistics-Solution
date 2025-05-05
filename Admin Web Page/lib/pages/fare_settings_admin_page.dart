import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../models/DirectionDetails.dart';

class FareSettingsAdminPage extends StatefulWidget {
  static const String id = 'fare-settings';

  const FareSettingsAdminPage({Key? key}) : super(key: key);

  @override
  State<FareSettingsAdminPage> createState() => _FareSettingsAdminPageState();
}

class _FareSettingsAdminPageState extends State<FareSettingsAdminPage> {
  // Controllers for the input fields
  final TextEditingController _distancePerKmController =
      TextEditingController(text: "0.4");
  final TextEditingController _durationPerMinuteController =
      TextEditingController(text: "0.3");
  final TextEditingController _baseFareController =
      TextEditingController(text: "2.0");
  final TextEditingController _weightFactorController =
      TextEditingController(text: "0.2");

  // Demo calculation inputs
  final TextEditingController _demoDistanceController =
      TextEditingController(text: "5.0");
  final TextEditingController _demoDurationController =
      TextEditingController(text: "15.0");
  final TextEditingController _demoWeightController =
      TextEditingController(text: "10.0");

  // Result variables
  double _totalDistanceFare = 0.0;
  double _totalDurationFare = 0.0;
  double _totalWeightFare = 0.0;
  double _totalFare = 0.0;

  bool _isLoading = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
    _calculateDemoFare();
  }

  @override
  void dispose() {
    _distancePerKmController.dispose();
    _durationPerMinuteController.dispose();
    _baseFareController.dispose();
    _weightFactorController.dispose();
    _demoDistanceController.dispose();
    _demoDurationController.dispose();
    _demoWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reference to the fare settings in Firebase
      DatabaseReference fareSettingsRef =
          FirebaseDatabase.instance.ref().child("fareSettings");

      // Get the current settings
      DataSnapshot snapshot = await fareSettingsRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _distancePerKmController.text =
              values['distancePerKmAmount'].toString();
          _durationPerMinuteController.text =
              values['durationPerMinuteAmount'].toString();
          _baseFareController.text = values['baseFareAmount'].toString();
          _weightFactorController.text = values['weightFactor'].toString();
        });

        _calculateDemoFare();
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error loading settings: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "";
    });

    try {
      // Parse values from controllers
      double distancePerKm = double.parse(_distancePerKmController.text);
      double durationPerMinute =
          double.parse(_durationPerMinuteController.text);
      double baseFare = double.parse(_baseFareController.text);
      double weightFactor = double.parse(_weightFactorController.text);

      // Reference to the fare settings in Firebase
      DatabaseReference fareSettingsRef =
          FirebaseDatabase.instance.ref().child("fareSettings");

      // Save the new settings
      await fareSettingsRef.set({
        'distancePerKmAmount': distancePerKm,
        'durationPerMinuteAmount': durationPerMinute,
        'baseFareAmount': baseFare,
        'weightFactor': weightFactor,
        'lastUpdated':  DateTime.now().toIso8601String(),
      });

      setState(() {
        _statusMessage = "Settings saved successfully!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error saving settings: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateDemoFare() {
    try {
      // Get values from controllers
      double distancePerKm = double.parse(_distancePerKmController.text);
      double durationPerMinute =
          double.parse(_durationPerMinuteController.text);
      double baseFare = double.parse(_baseFareController.text);
      double weightFactor = double.parse(_weightFactorController.text);

      // Get demo values
      double distance = double.parse(_demoDistanceController.text); // km
      double duration = double.parse(_demoDurationController.text); // minutes
      double weight = double.parse(_demoWeightController.text); // kg

      // Create a mock DirectionDetails object
      DirectionDetails mockDirectionDetails = DirectionDetails();
      mockDirectionDetails.distanceValueDigits =
          (distance * 1000); // Convert km to meters
      mockDirectionDetails.durationValueDigits =
          (duration * 60); // Convert minutes to seconds

      // Calculate fare components
      double totalDistanceFare =
          (mockDirectionDetails.distanceValueDigits! / 1000) * distancePerKm;
      double totalDurationFare =
          (mockDirectionDetails.durationValueDigits! / 60) * durationPerMinute;
      double totalWeightFare = weight * weightFactor;
      double totalFare =
      (baseFare + totalDistanceFare + totalDurationFare + totalWeightFare)*10; // are different cause the other is more precise in the user app and derivers app cause it give with the right distance

      setState(() {
        _totalDistanceFare = totalDistanceFare;
        _totalDurationFare = totalDurationFare;
        _totalWeightFare = totalWeightFare;
        _totalFare = totalFare;
      });
    } catch (e) {
      print("Error calculating demo fare: $e");
    }
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String suffix,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              onChanged: (_) => _calculateDemoFare(),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(),
                suffixText: suffix,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fare Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5C02),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fare Parameters",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          _buildInputField("Distance Rate",
                              _distancePerKmController, "per km"),
                          _buildInputField("Duration Rate",
                              _durationPerMinuteController, "per minute"),
                          _buildInputField(
                              "Base Fare", _baseFareController, "flat rate"),
                          _buildInputField("Weight Factor",
                              _weightFactorController, "per kg"),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF5C02),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text("SAVE SETTINGS",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          if (_statusMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _statusMessage,
                                style: TextStyle(
                                  color: _statusMessage.contains("Error")
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Demo Calculation",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          _buildInputField(
                              "Distance", _demoDistanceController, "km"),
                          _buildInputField(
                              "Duration", _demoDurationController, "minutes"),
                          _buildInputField(
                              "Package Weight", _demoWeightController, "kg"),
                          SizedBox(height: 16),
                          Divider(),
                          SizedBox(height: 16),
                          Text(
                            "Fare Breakdown",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          _buildResultRow("Base Fare",
                              double.parse(_baseFareController.text)),
                          _buildResultRow("Distance Cost", _totalDistanceFare),
                          _buildResultRow("Duration Cost", _totalDurationFare),
                          _buildResultRow("Weight Cost", _totalWeightFare),
                          Divider(),
                          _buildResultRow("TOTAL FARE", _totalFare,
                              isTotal: true),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${value.toStringAsFixed(2)+ " Dhs"}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Color(0xFFFF5C02) : null,
            ),
          ),
        ],
      ),
    );
  }
}
