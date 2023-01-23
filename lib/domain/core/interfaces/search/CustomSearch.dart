import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';

class CustomSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // action for app bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon of the left of app bar
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // sow some result based on the selection

    return Text("");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionSearches = query.isEmpty
        ? Get.find<NotifController>().listMatchUserAll
        : Get.find<NotifController>()
            .listMatchUserAll
            .where((p) => p['userName'].toLowerCase().startsWith(query))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () async {
          print("Test");
          await Get.find<NotifController>().addNewPartner(
              context2: context,
              userName: suggestionSearches[index]['userName'],
              imageUrl: suggestionSearches[index]['pictureUrl'] ?? "",
              Uid: suggestionSearches[index]['Matches']);
        },
        leading: Icon(Icons.person_add),
        title: RichText(
          text: TextSpan(
            text: suggestionSearches[index]['userName'],
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: suggestionSearches[index].name,
            //       style: TextStyle(color: Colors.grey)
            //   )
            // ]
          ),
        ),
      ),
      itemCount: suggestionSearches.length,
    );
  }
}
