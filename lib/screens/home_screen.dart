import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Change this listview for static content
      body: ListView(
        children: [
          Column(
            children: [
              //Logo place Size 225x225 pixels, remember to fix pubspec.yaml to allow images
              Container(
                height: 225,
                width: 225,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo500t.png')),
                ),
              ),

              //add another container to fix icon text?
            ],
          ),
          Container(
            height: 70,
            color: Colors.green,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, //Separate the elements horizontally
              children: [
                Text("Search here"),
                Icon(Icons.search),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: 30,
                color: Colors.yellow,
                child: const Text("Categories"),
              ),
              Container(
                width: 200,
                height: 500,
                color: Colors.orange,
                //Scrollable list of items on vertical
                child: const Text("Scroll view of categories"),
              ),
            ],
            //Scrollable categories on horizontal
          ),
        ],
      ),
    );
  }
}
