import 'package:admin_web_panel/dashboard/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/fare_settings_admin_page.dart'; // Import the new page
import 'package:admin_web_panel/pages/trips_page.dart';
import 'package:admin_web_panel/pages/users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

//common users
//drivers
//admins

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer>
{
  Widget chosenScreen = Dashboard();

  sendAdminTo(selectedPage)
  {
    switch(selectedPage.route)
    {
      case DriversPage.id:
        setState(() {
          chosenScreen = DriversPage();
        });
        break;

      case UsersPage.id:
        setState(() {
          chosenScreen = UsersPage();
        });
        break;

      case TripsPage.id:
        setState(() {
          chosenScreen = TripsPage();
        });
        break;

      case FareSettingsAdminPage.id:
        setState(() {
          chosenScreen = FareSettingsAdminPage();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF5C02),
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "Drivers",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Users",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Fare Settings",
            route: FareSettingsAdminPage.id,
            icon: CupertinoIcons.money_dollar_circle,
          ),
        ],
        selectedRoute: DriversPage.id,
        onSelected: (selectedPage)
        {
          sendAdminTo(selectedPage);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: Color(0xFFFF5C02),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: Color(0xFFFF5C02),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.computer,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}