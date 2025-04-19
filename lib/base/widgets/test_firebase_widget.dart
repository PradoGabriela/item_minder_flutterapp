import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/categories.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/services/firebase_service.dart';
import 'package:item_minder_flutterapp/services/webrtc_service.dart';

class ItemSharingWidget extends ConsumerStatefulWidget {
  const ItemSharingWidget({super.key});

  @override
  ConsumerState<ItemSharingWidget> createState() => _ItemSharingWidgetState();
}

class _ItemSharingWidgetState extends ConsumerState<ItemSharingWidget> {
  final _peerIdController = TextEditingController();
  late AppItem _selectedItem;

  @override
  void initState() {
    super.initState();
    if (FirebaseService.userId == null) {
      // Initiate Firebase service if not already done
      FirebaseService.init().then((_) {
        setState(() {
          // Ensure the widget rebuilds with the initialized service
        });
      });
    }

    // Initialize with a default item
    _selectedItem = AppItem.custom(
      'Example Brand',
      'Example Description',
      AppMedia().otherIcon,
      (Categories.bathroom.toString()).replaceAll("Categories.", ""),
      'bathroom',
      9.99,
      'shampoo',
      3,
      1,
      5,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Connection UI
        Text('Your ID: ${FirebaseService.userId}'),
        TextField(
          controller: _peerIdController,
          decoration: const InputDecoration(labelText: 'Peer ID'),
        ),
        ElevatedButton(
          onPressed: () => ref
              .read(webRTCServiceProvider.notifier)
              .connectToPeer(_peerIdController.text),
          child: const Text('Connect'),
        ),

        // Item Selection UI
        DropdownButton<AppItem>(
          value: _selectedItem,
          items: _buildItemDropdownItems(),
          onChanged: (item) => setState(() => _selectedItem = item!),
        ),

        // Send Button
        ElevatedButton(
          onPressed: () => ref
              .read(webRTCServiceProvider.notifier)
              .sendAppItem(_selectedItem),
          child: const Text('Send Item'),
        ),

        // Received Items List
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<AppItem>('appItems').listenable(),
            builder: (context, Box<AppItem> box, _) {
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final item = box.getAt(index);
                  return ListTile(
                    title: Text(item?.brandName ?? 'No brand'),
                    subtitle: Text(item?.description ?? 'No description'),
                    trailing: Text('\$${item?.price.toStringAsFixed(2)}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<AppItem>> _buildItemDropdownItems() {
    return [
      DropdownMenuItem(
        value: AppItem.custom(
          'Brand A',
          'Shampoo',
          AppMedia().otherIcon,
          (Categories.bathroom.toString()).replaceAll("Categories.", ""),
          'bathroom',
          12.99,
          'shampoo',
          2,
          1,
          4,
          false,
        ),
        child: const Text('Shampoo'),
      ),
      DropdownMenuItem(
        value: AppItem.custom(
          'Brand B',
          'Toothpaste',
          AppMedia().otherIcon,
          (Categories.bathroom.toString()).replaceAll("Categories.", ""),
          'bathroom',
          4.99,
          'toothpaste',
          3,
          2,
          5,
          true,
        ),
        child: const Text('Toothpaste'),
      ),
      // Add more sample items as needed
    ];
  }
}
