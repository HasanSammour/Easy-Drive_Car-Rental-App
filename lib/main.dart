import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/bnScreen.dart';
import 'package:flutter/material.dart';

import 'adminScreens/apps/bn_Screens/bnScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:Scaffold(

      ),
      initialRoute: 'bn_screen_Clients',
        routes: {
          'bn_screen' : (context) => const Bnscreen(),
          'bn_screen_Clients' : (context) => const BnscreenClients(),

        }
        );
  }
}

