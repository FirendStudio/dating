import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';
import 'package:hookup4u/presentation/profile/controllers/profile.controller.dart';

import '../../../infrastructure/dal/util/Global.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

import '../../../infrastructure/dal/util/general.dart';

class UploadLocationWidget extends GetView<ProfileController> {
  const UploadLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: ListTile(
          title: Text(
            "Use current location",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            (controller.newAddress.value ?? {}).isNotEmpty
                ? controller.newAddress.value!['PlaceName']
                : 'Unable to load...',
          ),
          leading: Icon(
            Icons.location_searching_rounded,
            color: Colors.white,
          ),
          onTap: () async {
            if ((controller.newAddress.value ?? {}).isEmpty) {
              controller.newAddress.value =
                  await Global().getLocationCoordinates() ?? {};
            } else {
              controller.updateAddress(controller.newAddress.value ?? {});
              // Navigator.pop(context, controller.newAddress.value);
            }
          },
        ),
      ),
      body: Container(
        color: primaryColor,
        height: MediaQuery.of(context).size.height * .6,
        child: MapBoxAutoCompleteWidget(
          language: 'en',
          closeOnSelect: false,
          apiKey: mapboxApi,
          limit: 10,
          hint: 'Enter your city name',
          onSelect: (place) {
            Map obj = {};
            obj['PlaceName'] = place.placeName;
            obj['latitude'] = place.geometry?.coordinates?[1] ?? 0;
            obj['longitude'] = place.geometry?.coordinates?[0] ?? 0;
            Navigator.pop(context, obj);
            controller.updateAddress(controller.newAddress.value ?? {});
          },
        ),
      ),
    );
  }
}
