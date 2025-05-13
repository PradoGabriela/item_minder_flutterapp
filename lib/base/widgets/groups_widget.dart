import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:item_minder_flutterapp/base/hiveboxes/group.dart';
import 'package:item_minder_flutterapp/base/managers/box_manager.dart';
import 'package:item_minder_flutterapp/base/managers/categories_manager.dart';
import 'package:item_minder_flutterapp/base/managers/group_manager.dart';
import 'package:item_minder_flutterapp/base/res/media.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/categories_widget.dart';
import 'package:item_minder_flutterapp/base/widgets/group_card.dart';
import 'package:item_minder_flutterapp/base/widgets/join_pop_widget.dart';

class GroupsWidget extends StatefulWidget {
  const GroupsWidget({super.key});

  @override
  State<GroupsWidget> createState() => _GroupsWidgetState();
}

class _GroupsWidgetState extends State<GroupsWidget> {
  List<AppGroup> currentGroups = [];

  void _onGroupChanged() {
    setState(() {
      currentGroups = GroupManager().getHiveGroups();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onGroupChanged();
    BoxManager().groupBox.listenable().addListener(_onGroupChanged);
    // debugPrint(BoxManager().groupBox.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 380,
          height: 500,
          margin: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(89, 116, 114, 114),
                offset: Offset(5, 5),
                blurRadius: 1,
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.black, width: 3),
            ),
            elevation: 0,
            color: Colors.white,
            child: FutureBuilder<List<dynamic>>(
              future: Future.value(currentGroups),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text("Groups",
                          style:
                              AppStyles().catTitleStyle.copyWith(fontSize: 24)),
                      const SizedBox(height: 20),
                      rowButtons()
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Text("Groups",
                          style:
                              AppStyles().catTitleStyle.copyWith(fontSize: 24)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 24, vertical: 14),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GroupCard(
                              groupId: snapshot.data![index].groupID,
                              groupName: snapshot.data![index].groupName,
                              groupIconUrl: snapshot.data![index].groupIconUrl,
                              members: snapshot.data![index].members,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      rowButtons(),
                      const SizedBox(height: 20),
                    ],
                  );
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Row rowButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              GroupManager().createGroup("Family", "Gabriela",
                  AppMedia().familyIcon, AppCategories().categoriesDB);
              debugPrint(BoxManager().groupBox.values.toString());
              debugPrint("Creating Group");
            },
            style: AppStyles().raisedButtonStyle,
            child: Column(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            )),
        SizedBox(width: 14),
        Text(
          'OR',
          style: TextStyle(
            fontSize: 16,
            color: AppStyles().getPrimaryColor(),
          ),
        ),
        SizedBox(width: 14),
        ElevatedButton(
            onPressed: () {
              JoinCustomPopup.show(context: context);
            },
            style: AppStyles().raisedButtonStyle,
            child: Column(
              children: [
                Icon(
                  Icons.person_add_alt_outlined,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  'Join',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  @override
  void dispose() {
    BoxManager().groupBox.listenable().removeListener(_onGroupChanged);
    super.dispose();
  }
}
