import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/bottom_nav_bar.dart';

class GroupCard extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupIconUrl;
  final List<String> members;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupIconUrl,
    required this.members,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: AppStyles().getPrimaryColor(),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(89, 116, 114, 114), // Shadow color adjustment
            offset: Offset(5, 5), // Position the shadow to the right and bottom
            blurRadius: 1, // Control the blur effect
          ),
        ],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24), // Use the same border radius as the Card
        ),
        child: InkResponse(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BottomNavBar(currentGroupId: widget.groupId),
              ),
            ).then((result) {
              setState(() {});
            });
          },
          splashColor: Colors.grey, // Customize splash color
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.groupIconUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Column(
                  children: [
                    Text(widget.groupName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    Text('Members: ${widget.members.join(', ')}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
