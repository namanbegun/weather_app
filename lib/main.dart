import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature = 0;
  String location = 'San Francisco';
  int woeid = 2487956;
  String weather = 'clear';
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiurl = 'https://www.metaweather.com/api/location/';

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    fetchlocation();
  }

  void fetchweather(String input) async {
    var searchResult = await http.get(Uri.parse(
        'https://www.metaweather.com/api/location/search/?query=$input'));
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result["title"];
      woeid = result["woeid"];
    });
  }

  void fetchlocation() async {
    var locationResult = await http.get(Uri.parse(
        'https://www.metaweather.com/api/location/${woeid.toString()}'));
    var res = json.decode(locationResult.body);
    var consolidated_weather = res["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').tolowerCase();
    });
  }

  void onTextFieldSubmitted(String input) {
    fetchweather(input);
    fetchlocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover
            ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      temperature.toString() + '°' + 'C',
                      style: TextStyle(fontSize: 54, color: Colors.white),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 54, color: Colors.white),
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input) {
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                          hintText: 'Enter location',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 20),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          )),
                    ),
                  )
                ],
              )
            ],
          )),
    ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
