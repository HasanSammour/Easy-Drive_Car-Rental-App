
import 'package:flutter/material.dart';

class Clients extends StatelessWidget {
  const Clients({super.key});

  @override
  Widget build(BuildContext context) {
    return  SafeArea(

      child: Container(
        color: const Color(0xFFFAFAFA),
        child: ListView(

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  IconButton(
                      padding: const EdgeInsets.all(0)
                      ,
                      onPressed: () {  },
                      icon: const Icon(
                        Icons.arrow_back_ios,

                        size: 16,
                        color: Color(0xFF586BCA),)),
                  Transform.translate(offset: const Offset(-20, 0)
                    ,child: TextButton(
                        onPressed: (){


                        }, child: Text("Back",
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 16
                    // ),
                    )) ,),
                  const Spacer(),
                  IconButton(onPressed: (){},
                      icon: const Icon(Icons.edit,color: Color(0xFF586BCA),
                        size: 20,)),


                ],
              ),
            ),

            Column(
              children: [
                SizedBox(
                  height: 100,width: 100,
                  child: CircleAvatar(
                    child: Image.asset("Images/Profile Picture.png",),

                  ),
                ),

                const SizedBox(height: 20,),
                Text("Tanya Robinson",
                //   style: GoogleFonts.poppins(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold
                // ),
                )

                ,
                const SizedBox(height: 70,),

                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                        child: ListTile(leading: const Icon(Icons.add_alert,
                          color: Color(0xff586BCA),size: 24,),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Notifications",
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w600
                            // ),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                            size: 15,
                            color: Color(0xFF586BCA),),
                        ),
                      ),
                      Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),),
                      Padding(
                        padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                        child: ListTile(leading: const Icon(Icons.list_alt_sharp,
                          color: Color(0xff586BCA),size: 24,),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("My Orders",
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w600
                            // ),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                            size: 15,
                            color: Color(0xFF586BCA),),
                        ),
                      ),
                      Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),),
                      // InkWell(
                      //   onTap: (){
                      //     final bnscreenState = context.findAncestorStateOfType<BnscreenState>();
                      //     bnscreenState?.switchToHomeAndPushAddress(const Address());
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                      //     child: ListTile(leading: const Icon(Icons.send,
                      //       color: Color(0xff586BCA),size: 24,),
                      //       title: Padding(
                      //         padding: const EdgeInsets.only(left: 8.0),
                      //         child: Text("Address",
                      //         //   style: GoogleFonts.poppins(
                      //         //     fontSize: 16,
                      //         //     fontWeight: FontWeight.w600
                      //         // ),
                      //         ),
                      //       ),
                      //       trailing: const Icon(Icons.arrow_forward_ios,
                      //         size: 15,
                      //         color: Color(0xFF586BCA),),
                      //     ),
                      //   ),
                      // ),
                      // Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),),
                      // InkWell(
                      //   onTap: (){
                      //
                      //     final bnscreenState = context.findAncestorStateOfType<BnscreenState>();
                      //     bnscreenState?.switchToHomeAndPushAddress(const Paymentmethod());
                      //
                      //
                      //
                      //
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                      //     child: ListTile(leading: const Icon(Icons.credit_card_outlined,
                      //       color: Color(0xff586BCA),size: 24,),
                      //       title: Padding(
                      //         padding: const EdgeInsets.only(left: 8.0),
                      //         child: Text("Payment",
                      //         //   style: GoogleFonts.poppins(
                      //         //     fontSize: 16,
                      //         //     fontWeight: FontWeight.w600
                      //         // ),
                      //         ),
                      //       ),
                      //       trailing: const Icon(Icons.arrow_forward_ios,
                      //         size: 15,
                      //         color: Color(0xFF586BCA),),
                      //     ),
                      //   ),
                      // ),
                      Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),),
                      Padding(
                        padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                        child: ListTile(leading: const Icon(Icons.favorite,
                          color: Color(0xff586BCA),size: 24,),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Favourites",
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w600
                            // ),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                            size: 15,
                            color: Color(0xFF586BCA),),
                        ),
                      ),
                      Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),),
                      Padding(
                        padding: const EdgeInsets.only(left: 25,right: 20,bottom: 5),
                        child: ListTile(leading: const Icon(Icons.settings,
                          color: Color(0xff586BCA),size: 24,),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Settings",
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w600
                            // ),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                            size: 15,
                            color: Color(0xFF586BCA),),
                        ),
                      ),
                      Divider(endIndent: 30,indent: 30,color: const Color(0xFF000000).withOpacity(0.1),)


                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
