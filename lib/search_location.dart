import 'package:check_in/controllers/locatio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSearchDialog extends StatelessWidget {
  final GoogleMapController? mapController;
  const LocationSearchDialog({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(top: 150),
      padding: const EdgeInsets.all(5),
      alignment: Alignment.topCenter,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: SizedBox(
            width: 350,
            child: TypeAheadField<Prediction>(
              controller: controller,
              suggestionsCallback: (pattern) async {
                return await Get.find<LocationController>()
                    .searchLocation(context, pattern);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    hintText: 'search_location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(style: BorderStyle.none, width: 0),
                    ),
                    hintStyle:
                        Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 16,
                              color: Theme.of(context).disabledColor,
                            ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                      ),
                );
              },
              itemBuilder: (context, Prediction suggestion) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    const Icon(Icons.location_on),
                    Expanded(
                      child: Text(suggestion.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 20,
                              )),
                    ),
                  ]),
                );
              },
              onSelected: (Prediction suggestion) {
                print("My location is ${suggestion.description!}");
                //Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description!, mapController);
                Get.back();
              },
            )),
      ),
    );
  }
}
