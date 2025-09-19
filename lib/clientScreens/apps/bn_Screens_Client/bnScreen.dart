
import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/History.dart';
import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/booking.dart';
import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/Home.dart';
import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/message.dart';
import 'package:easy_drive_car_rental/clientScreens/apps/bn_Screens_Client/profile.dart';
import 'package:flutter/material.dart';


class BnscreenClients extends StatefulWidget {
  const BnscreenClients({super.key});

  @override
  State<BnscreenClients> createState() => BnscreenClientsState();
}

class BnscreenClientsState extends State<BnscreenClients> {
  int _cureentIndex = 0 ;
  // ignore: unused_field
  final List<Widget> _body = [
     Home(),
    const Booking(),
    const History(),
    const Message(),
    const Profile()

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
          const Booking(),
          const History(),
          Navigator(
            key:_profileNavigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(builder: (_) => const Message());
            },
          ),
          Profile()
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
            BottomNavigationBarItem(icon: Icon(Icons.car_rental,), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.message,), label: 'Message'),
            BottomNavigationBarItem(icon: Icon(Icons.person,), label: 'Profile'),


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
