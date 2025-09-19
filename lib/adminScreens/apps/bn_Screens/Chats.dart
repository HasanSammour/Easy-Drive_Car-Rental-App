import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

  final List<Map<String, dynamic>> _products = [
    {
      'imagePath': 'Images/Brown Stone Bracelet edited.png',
      'title': "Brown Stone Bracelet",
      'currentPrice': "USD24",
      'prevPrice': "USD40",
      'visible' : false
    },
    {
      'imagePath': 'Images/Black Stainless Cuff edited .png',
      'title': "Black Stainless Cuff",
      'currentPrice': "USD23",
      'prevPrice': "USD43",
      'visible' : false
    },
    {
      'imagePath': 'Images/Blue Steel Watch edited.png',
      'title': "Blue Steel Watch",
      'currentPrice': "USD240",
      'prevPrice': "USD365",
      'visible' : false
    },
  ];


  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10,left: 30),
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
                PopupMenuButton<String>(
                    color:Colors.white,
                    iconColor: const Color(0xFF586BCA),
                    iconSize: 24,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    position: PopupMenuPosition.under,


                    itemBuilder: (context) =>[
                      PopupMenuItem(
                        height: 30,
                        child: Text("Sort by price",
                          // style: GoogleFonts.poppins(
                          //     color: const Color(0xFF1B2A3B),
                          //     fontWeight: FontWeight.w500,
                          //     fontSize: 12
                          // ),
                        ),

                      ),
                      PopupMenuItem(
                          height: 1,
                          child: Divider(
                            color: Colors.black.withOpacity(0.1),)
                      ),
                      PopupMenuItem(
                        height: 30,
                        child: Text("Sort by date",
                          // style: GoogleFonts.poppins(
                          //     color: const Color(0xFF1B2A3B),
                          //     fontWeight: FontWeight.w500,
                          //     fontSize: 12
                          // ),
                        ),

                      ),
                      PopupMenuItem(
                          height: 1,
                          child: Divider(
                            color: Colors.black.withOpacity(0.1),)
                      ),
                      PopupMenuItem(
                        height: 30,
                        child: Text("Remove all items",
                          // style: GoogleFonts.poppins(
                          //     color: const Color(0xFFF45959),
                          //     fontWeight: FontWeight.w500,
                          //     fontSize: 12
                          // ),
                        ),

                      )
                    ]

                ),


              ],
            ),
          ),

          //here we will implement dissmissble widgets

          Expanded(
            child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context,index){
                  final _product = _products[index];
                  return Dismissible(
                    key: UniqueKey(),
                    // child: ProductList(
                    //   imagePath: _product['imagePath']!,
                    //   title: _product['title']!,
                    //   currentPrice: _product['currentPrice']!,
                    //   prevPrice: _product['prevPrice']!,
                    //   visible: _product[false] ?? false,
                    // ),
                    child: Container(color: Colors.amber,),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: const Color(0xFFF45959),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete, color: Colors.white, size: 24,),

                          const SizedBox(height: 5,),
                          Text('Remove',
                          //   style: GoogleFonts.poppins(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.w600,
                          //     color: Colors.white
                          // ),
                          ),
                          Text('from Cart',
                          //   style: GoogleFonts.poppins(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.w600,
                          //     color: Colors.white
                          // ),
                          )
                        ],),
                    ),

                    onDismissed: (direction) {
                      setState(() {
                        _products.removeAt(index);
                      });

                    },
                  );
                }),
          ),




          Text("Total Items: ${_products.length} Items",
            // style: GoogleFonts.poppins(
            //     color: const Color(0xFF8FA1B4),
            //     fontWeight: FontWeight.w600,
            //     fontSize: 14
            // ),
          ),
          const SizedBox(height: 10,),
          Text("Total Price: \$266",
            // style: GoogleFonts.poppins(
            //     fontSize: 16,
            //     color: const Color(0xFF0D213F),
            //     fontWeight: FontWeight.bold
            // ),
          ),

          if (_products.length <= 3) const SizedBox(height: 250) else const Spacer(),





        ],

      ),
    );
  }

// here is the function which we need it in the item icon (options), when we click it .






}


