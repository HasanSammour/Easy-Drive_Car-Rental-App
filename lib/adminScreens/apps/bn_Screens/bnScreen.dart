
import 'package:easy_drive_car_rental/adminScreens/apps/bn_Screens/Chats.dart';
import 'package:easy_drive_car_rental/adminScreens/apps/bn_Screens/Clients.dart';
import 'package:easy_drive_car_rental/adminScreens/apps/bn_Screens/home.dart';
import 'package:easy_drive_car_rental/adminScreens/apps/bn_Screens/rentalRequests.dart';
import 'package:flutter/material.dart';


class Bnscreen extends StatefulWidget {
  const Bnscreen({super.key});

  @override
  State<Bnscreen> createState() => BnscreenState();
}

class BnscreenState extends State<Bnscreen> {
  int _cureentIndex = 0 ;
  // ignore: unused_field
  final List<Widget> _body = [
     Home(),
    const RentalRequests(),
    const Chats(),
    const Clients()

  ];

  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // body: _body[_cureentIndex],

      body: IndexedStack(
        index: _cureentIndex,
        children: [
          // here only the Home() , we but it inside Navigator , because we will edit it .
          Navigator(
            key:_homeNavigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(builder: (_) => Home());
            },
          ),
          const RentalRequests(),
          const Chats(),
          Navigator(
            key:_profileNavigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(builder: (_) => const Clients());
            },
          ),
        ],

      ),

      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,

          onTap: (page){
            setState(() {
              _cureentIndex = page ;
            });
          },
          elevation: 0,
          currentIndex: _cureentIndex,


          selectedItemColor: const Color(0xFF586BCA),
          unselectedItemColor: const Color(0xFFC0C0C0),
          // unselectedLabelStyle: GoogleFonts.poppins(
          //     color: const Color(0xFFC0C0C0),
          //     fontSize: 12,
          //     fontWeight: FontWeight.w400
          // ),

          // selectedLabelStyle:GoogleFonts.poppins(
          //     color: const Color(0xFF586BCA),
          //     fontSize: 12,
          //     fontWeight: FontWeight.w400
          // ),
          iconSize: 22,
          items:const [
            BottomNavigationBarItem(icon: Icon(Icons.home,), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.pending_actions_rounded,), label: 'RentalRequests'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person,), label: 'Clients'),


          ]),

    );
  }
  void switchToHome() {
    setState(() {
      _cureentIndex = 0;
    });

  }

  void switchToHomeAndPushAddress(Widget page) {
    setState(() {
      _cureentIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => page),
      );
    });

  }

  void pushReplacementToEmptyCart(){
    Navigator.pushReplacementNamed(context, 'emptyChart_screen');
  }
}
