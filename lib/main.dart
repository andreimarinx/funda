// ignore_for_file: must_be_immutable

import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

// Function to get data from the API
Future<HouseData> fetchHouse() async {
  //Request data
  final response = await http.get(Uri.parse(
      'http://partnerapi.funda.nl/feeds/Aanbod.svc/json/detail/ac1b0b1572524640a0ecc54de453ea9f/koop/bc9cd17f-b0a9-41d3-b814-3be096a5a054/'));

  if (response.statusCode == 200) {
    // If there is a positive response, send the data to HouseData
    return HouseData.fromJson(jsonDecode(response.body));
  } else {
    // Otherwise throw exception
    throw Exception('Failed to load HouseData');
  }
}

//HouseData Class
class HouseData {
  //House variables
  final String adres, description, ownerName;
  final double locX, locY;
  final List media;
  final int livingArea, plotSize, price;

  const HouseData(
      {required this.adres,
      required this.media,
      required this.description,
      required this.locX,
      required this.locY,
      required this.livingArea,
      required this.plotSize,
      required this.price,
      required this.ownerName});

  //Map the Json
  factory HouseData.fromJson(Map<String, dynamic> json) {
    // Atribute the values
    return HouseData(
        livingArea: json['WoonOppervlakte'],
        plotSize: json['PerceelOppervlakte'],
        media: json['Media'],
        adres: json['Adres'],
        description: json['VolledigeOmschrijving'],
        locX: json['WGS84_X'],
        locY: json['WGS84_Y'],
        price: json['Koopprijs'],
        ownerName: json['Makelaar']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Funda',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch().copyWith(primary: const Color(0xfffb922a)),
      ),
      home: const MyHomePage(title: 'Funda'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // AppBar Logo
          title: Image.asset(
            'assets/funda_logo.png',
            width: 120,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  //FutureBuilder to request the data and send it to House class
                  child: FutureBuilder<HouseData>(
                    future: fetchHouse(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return House(
                            snapshot.data!.adres,
                            snapshot.data!.media,
                            snapshot.data!.description,
                            snapshot.data!.locX,
                            snapshot.data!.locY,
                            snapshot.data!.livingArea,
                            snapshot.data!.plotSize,
                            snapshot.data!.price,
                            snapshot.data!.ownerName);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // Loading spinner by default.
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// House StatelessWidget displays the body of the page
class House extends StatelessWidget {
  //Basic decoration to use it more than once
  Decoration decorationContainer = BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    color: const Color(0xfffb922a),
  );
  // Define all the variables we need to display the house
  String name = '', description = '', ownerName = '';
  double locX = 0.0, locY = 0.0;
  int livingArea = 0, plotSize = 0, price = 0;
  List pictures = [];

  // House constructor
  // ignore: no_leading_underscores_for_local_identifiers
  House(_name, _media, _description, _locX, _locY, _liningArea, _plotSize,
      _price, _ownerName,
      {super.key}) {
    name = _name;
    description = _description;
    locX = _locX;
    locY = _locY;
    livingArea = _liningArea;
    plotSize = _plotSize;
    price = _price;
    ownerName = _ownerName;

    //Loop through media to get all the images
    List<dynamic> entitlements = _media;
    for (var entitlement in entitlements) {
      //if the image doesnt have the specific size, skip it
      try {
        pictures.add(entitlement['MediaItems'][3]["Url"]);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Image slider
        Container(
            margin: const EdgeInsets.only(top: 10),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 250,
                autoPlay: false,
                enlargeCenterPage: true,
              ),
              items: List<Widget>.generate(
                pictures.length,
                (index) {
                  return MyImageView(pictures[index]);
                },
              ),
            )),

        // Box with all the rest of the details
        Container(
            padding: const EdgeInsets.only(top: 10),
            margin: const EdgeInsets.only(top: 15),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 10)
              ],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                // Top box of information
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Name of the House / Adress
                              Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Living area box
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      decoration: decorationContainer,
                                      child: Row(
                                        children: <Widget>[
                                          //living area text
                                          Text(
                                            livingArea.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            "  m² living area",
                                            style: TextStyle(
                                                color: Colors.grey[100],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        ],
                                      )),
                                  //Plot size box
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      decoration: decorationContainer,
                                      child: Row(
                                        children: <Widget>[
                                          // Plot size text
                                          Text(
                                            plotSize.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            "  m² plot size",
                                            style: TextStyle(
                                                color: Colors.grey[100],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        ],
                                      )),
                                ],
                              ),

                              // Price box
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color(0xff0069A6)),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "€ $price",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Text(
                                        " K.K.",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  )),
                            ],
                          ),

                          // Map button
                          GestureDetector(
                              //On tap open google maps with the coordonates
                              onTap: () async {
                                String googleUrl =
                                    'https://www.google.com/maps/search/?api=1&query=$locY,$locX';
                                if (await canLaunchUrl(Uri.parse(googleUrl))) {
                                  await launchUrl(Uri.parse(googleUrl));
                                } else {
                                  throw 'Could not open the map.';
                                }
                              },
                              child: Column(
                                children: <Widget>[
                                  //Map icon
                                  Image.asset(
                                    'assets/map.png',
                                    width: 70,
                                  ),
                                  //Text
                                  const Text(
                                    "Map",
                                    style: TextStyle(
                                        color: Color(0xff0069A6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ))
                        ])),
                // Description Box
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xfffb922a),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: const Text(
                              "Description",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )),

                        // Expandable textbox
                        ExpandText(
                          indicatorIconColor: Colors.white,
                          maxLines: 7,
                          description,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    )),

                // Seller information
                Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 25, right: 25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border:
                          Border.all(width: 2, color: const Color(0xfffb922a))),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Icon (couldn't find it in the data so i just saved it locally)
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(3.0),
                                bottomLeft: Radius.circular(3.0)),
                            child: Image.asset(
                              'assets/owner.jpg',
                              width: 70,
                            )),
                        Container(
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Name
                                Text(
                                  ownerName,
                                  style: const TextStyle(
                                      color: Color(0xff0069A6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                // Available time (hardcoded again)
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    Text(
                                      ' Available tomorrow from 9:00',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                // Phone number
                                Row(
                                  children: const <Widget>[
                                    Icon(
                                      Icons.phone,
                                      color: Color(0xff0069A6),
                                      size: 20,
                                    ),
                                    Text(
                                      ' Show phone number',
                                      style: TextStyle(
                                          color: Color(0xff0069A6),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ))
                      ]),
                )
              ],
            ))
      ],
    );
  }
}

// MyImageView used for the image slideshow
class MyImageView extends StatelessWidget {
  String imgPath;

  MyImageView(this.imgPath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: SizedBox(
            width: double.infinity,
            height: 50,
            child: SizedBox.expand(
                child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(
                imgPath,
              ),
            ))));
  }
}
