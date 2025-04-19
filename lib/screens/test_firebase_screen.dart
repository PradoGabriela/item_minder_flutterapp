import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/widgets/test_firebase_widget.dart';

class TestFirebaseScreen extends StatelessWidget {
  const TestFirebaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppItem Sharing',
      home: Scaffold(
        appBar: AppBar(title: const Text('Share AppItems')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ItemSharingWidget(),
        ),
      ),
    );
  }
}
