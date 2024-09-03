import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vivi_ride_app/auth/sign_in_page.dart';
import 'package:vivi_ride_app/global.dart';
import 'package:vivi_ride_app/methods/google_map_methods.dart';
import 'package:vivi_ride_app/pages/select_destination_page.dart';

import '../appInfo/app_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  double bottomMapPadding = 0 ;
  double searchContainerHeight = 220;
  /// to manage Drawer
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;



  getCurrentLocation() async
  {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
    );
    Position userPosition = await Geolocator.getCurrentPosition(locationSettings: locationSettings,);
    currentPositionOfUser = userPosition;

    LatLng userLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapsMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();
  }

  getUserInfoAndCheckBlockStatus() async
  {
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);

    await reference.once().then((dataSnap)
    {
      if(dataSnap.snapshot.value != null)
      {
        if((dataSnap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
           userName = (dataSnap.snapshot.value as Map)["name"];
           userPhone = (dataSnap.snapshot.value as Map)["phone"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInPage()));
          associateMethods.showSnackBarMsg("You are Blocked. For Contact Email : vivigroups.inc@gmail.com", context);
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInPage()));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 256,
        child: Drawer(
          child: ListView(
            children: [

              //header Drawer
              SizedBox(
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/IMG-20230702-WA0085.jpg",width: 60,height: 60,),

                      const SizedBox(width: 16,),

                       Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4,),

                          Text(
                            "profile",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
                ),
              ),

              // body Drawer
              GestureDetector(
                onTap: (){},
                child: const ListTile(
                  leading: Icon(Icons.history, color: Colors.black,),
                  title: Text("History", style: TextStyle(color: Colors.black),),
                ),
              ),

              GestureDetector(
                onTap: (){},
                child: const ListTile(
                  leading: Icon(Icons.info, color: Colors.black,),
                  title: Text("About", style: TextStyle(color: Colors.black),),
                ),
              ),

              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();
                  associateMethods.showSnackBarMsg("Logout successfully.", context);

                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.black,),
                  title: Text("Logout", style: TextStyle(color: Colors.black),),
                ),
              ),


            ],
          ),
        ),
      ),
      body: Stack(
        children: [

          /// google map setup and get current location
          GoogleMap(
            padding: EdgeInsets.only(top: 26,bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;

              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLocation();
            },
          ),

          /// Drawer Button
          Positioned(
            top: 37,
            left: 20,
            child: GestureDetector(
              onTap: ()
              {
                sKey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    Icons.menu,
                  ),
                ),
              ),
            ),
          ),


          /// homescreen container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 122),
              child: Container(
                // color: ,
                height: searchContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(21),
                    topLeft: Radius.circular(21),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [

                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,color: Colors.grey,),
                          const SizedBox(width: 13.0,),
                          GestureDetector(
                            onTap: ()
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const SelectDestinationPage()));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("From", style: TextStyle(fontSize: 12),),
                                 const SizedBox(height: 5,),
                                 Text(
                                  Provider.of<AppInfo>(context, listen: true).pickUpLocation == null
                                      ? "please wait..."
                                      : (Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName!),//.substring(0, 50) + "...",
                                  style: const TextStyle(
                                      fontSize: 12
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0,),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0,),

                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined,color: Colors.grey,),
                          const SizedBox(width: 13.0,),
                          GestureDetector(
                            onTap: ()
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const SelectDestinationPage()));
                            },
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("To", style: TextStyle(fontSize: 12),),
                                SizedBox(height: 5,),
                                Text("Where To go",
                                  style: TextStyle(
                                    fontSize: 12,
                            
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0,),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0,),

                      ElevatedButton(
                          onPressed: ()
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const SelectDestinationPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                          ),
                          child: const Text(
                            "Select Destination",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                      ),

                    ],
                  ),
                ),
              ),
            ),

          ),

        ],
      ),

    );
  }
}
