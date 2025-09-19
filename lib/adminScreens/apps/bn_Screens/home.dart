import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  Home({super.key});

  // ignore: unused_field
  final List<Widget> _title=[
    const Text('Watches'),
    const Text('Bracelets'),
    const Text('Straps'),
    const Text('Set')
  ];




  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30,),
            child: Row(
              children: [
                Text("Select from categories",
                  // style: GoogleFonts.poppins(
                  //     color: const Color(0xFF1B2A3B),
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600
                  // ),
                ),
                const Spacer(),
                const Icon(Icons.search,
                  size: 18,
                  color: Color(0xFF586BCA),)
              ],
            ),
          ),
          const SizedBox(height: 16,),
          SizedBox(width: double.maxFinite,height: 55,
              child: ListView(

                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                children: const [
                 // HomeListView(title: "Watches",),
                 // HomeListView(title: "Bracelets",),
                 // HomeListView(title: "Straps",),
                 // HomeListView(title: "Set",),
                ],
              )
          ),

          const SizedBox(height: 20,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Most Selling" ,
                //   style: GoogleFonts.poppins(
                //     fontSize: 18,
                //     fontWeight: FontWeight.w600,
                //     color: const Color(0xFF1B2A3B)
                // ),
                ),


                TextButton(onPressed: (){},
                  child: Text("View All",
                  //   style: GoogleFonts.poppins(
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 14,
                  //     color: const Color(0xFF586BCA)
                  // ),
                  ),
                ),

              ],
            ),

          ),

          const SizedBox(height: 10,),

          SizedBox(
            height: 227,
            width: double.maxFinite,
            child: GridView(
              padding: const EdgeInsets.only(left: 30),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1),
              children: [
                InkWell(
                  onTap:(){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) =>  Container(color: Colors.amber,)
                      //Productdetails()
                      ),
                    );
                  }
                //   ,     child: const MostSellingCard(
                //   imagePath: 'Images/Black Rope Bracelet edited .png',
                //   title: 'Bracelets',
                //   itemName: 'Black Rope Bracelet',
                //   newPrice: 'USD29',
                //   prevPrice: 'USD38',
                //
                // ),
                ),

                InkWell(
                  onTap: (){

                  },
                  // child: const MostSellingCard(
                  //   imagePath: 'Images/Kinsale Black Watch edited.png',
                  //   title: 'Watches',
                  //   itemName: 'Kinsale Black Watch',
                  //   newPrice: 'USD185',
                  //   prevPrice: 'USD230',
                  //   like: false,
                  //
                  // ),
                  child: Container(color: Colors.amber,),
                ),

                InkWell(
                  onTap: (){

                  },
                  child: Container(color: Colors.amber,),
                  // child: const MostSellingCard(
                  //   imagePath: 'Images/Black Rope Bracelet edited .png',
                  //   title: 'Bracelets',
                  //   itemName: 'Black Rope Bracelet',
                  //   newPrice: 'USD29',
                  //   prevPrice: 'USD38',
                  //
                  // ),
                ),
              ],
            ),
          )
          ,

          Padding(
            padding: const EdgeInsets.only(left: 30,right:30,top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Added" ,
                //   style: GoogleFonts.poppins(
                //     fontSize: 18,
                //     fontWeight: FontWeight.w600,
                //     color: const Color(0xFF1B2A3B)
                // ),
                ),


                TextButton(onPressed: (){},
                  // child: Text("View All",style: GoogleFonts.poppins(
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 14,
                  //     color: const Color(0xFF586BCA)
                  // ),),
                  child: Text("data"),
                  ),

              ],
            ),

          ),
          const SizedBox(height: 10,),

          SizedBox(
            height: 227,
            width: double.maxFinite,
            child: GridView(
              padding: const EdgeInsets.only(left: 30),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 0),

              children: [
                Container(
                  color: Colors.amber,
                )
              ],
            ),
          )





        ],
      ),
    );
  }
}




