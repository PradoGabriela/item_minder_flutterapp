import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: 20,
            color: Colors.amber.shade800,
            child: const Icon(Icons.menu),
          ),
          Column(
            children: [
              Container(
                height: 40,
                color: Colors.blue,
              ),
              Container(
                child: const Text("Shop Only What You Need"),
              )
            ],
          ),
          Container(
            height: 40,
            color: Colors.green,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Search here"),
                Icon(Icons.search),
              ],
            ),
          ),
          Container(
            height: 30,
            color: Colors.yellow,
            child: const Text("Categories"),
          ),
          Container(
            child: const Text("Scroll view of categories"),
          ),
        ],
      ),
    );
  }
}
