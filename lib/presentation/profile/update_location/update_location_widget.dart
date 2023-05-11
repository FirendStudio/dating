import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/package/google_places_flutter.dart';
import 'package:hookup4u/package/model/prediction.dart';

import '../controllers/profile.controller.dart';

class UploadLocationWidget extends GetView<ProfileController> {
  UploadLocationWidget({super.key});

  TextEditingController controllerText = TextEditingController();

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
            // if ((controller.newAddress.value ?? {}).isEmpty) {
            //   controller.newAddress.value = await Global().getLocationCoordinates() ?? {};
            // } else {
            //   controller.updateAddress(controller.newAddress.value ?? {});
            //   // Navigator.pop(context, controller.newAddress.value);
            // }
            controller.newAddress.value = await Global().getLocationCoordinates() ?? {};
            controller.updateAddress(controller.newAddress.value ?? {}, true);
            globalController.isFromLocationChange.value=true;
            globalController.addDistance.value=0;
          },
        ),
      ),
      body: placesAutoCompleteTextField(context),
    );
  }

  placesAutoCompleteTextField(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
          textEditingController: controllerText,

          /// api key 1
          googleAPIKey: "AIzaSyCE59nAV3-CoNPZBgosM6KTtIMwLaOC46E",
          inputDecoration: InputDecoration(hintText: "Search your location"),
          debounceTime: 800,
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) async {
            Map<String, dynamic>? newLocation = await Global().coordinatesToAddress(
              latitude: double.parse(prediction.lat.toString()),
              longitude: double.parse(prediction.lng.toString()),
            );
            Map<String, dynamic> obj = {};
            Map<String, dynamic>? location = await Global().getLocationCoordinates();
            if (location!['countryName'] == prediction.description) {
              obj['PlaceName'] = prediction.description ?? "";
              obj['latitude'] =   location['latitude'];
              obj['longitude'] =   location['longitude'];
              obj['countryName'] = location['countryName'];
              obj['countryID'] = location['countryID'];

            } else {
              obj['PlaceName'] = prediction.description ?? "";
              obj['latitude'] =   location['latitude'];
              obj['longitude'] =   location['longitude'];
              // obj['latitude'] =   double.parse(prediction.lat.toString());
              // obj['longitude'] =  double.parse(prediction.lng.toString());
              obj['countryName'] = newLocation!['countryName'];
              obj['countryID'] = newLocation['countryID'];
            }
            debugPrint("on tap location change =====>${prediction.description}");

            controller.newAddress.value = obj;

            Navigator.pop(context, obj);
            controller.updateAddress(obj, false);
            print("location change ====>   ${prediction.lat} ${prediction.lng}");
            globalController.isFromLocationChange.value=true;
            globalController.addDistance.value=0;
          },
          itmClick: (Prediction prediction) async {
            controllerText.text = prediction.description!;
            controllerText.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
          }
          // default 600 ms ,
          ),
    );
  }

  Container buildClientBody(BuildContext context) {
    return Container(
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
          controller.updateAddress(controller.newAddress.value ?? {}, false);
        },
      ),
    );
  }
}
