import 'package:disaster_relief_application/Request/request_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class RequestLocationPage extends StatefulWidget {
  final Map<String, int> selectedSupplies;
  final bool isFromRequestInventory;

  const RequestLocationPage({
    super.key,
    required this.selectedSupplies,
    required this.isFromRequestInventory,
  });

  @override
  State<RequestLocationPage> createState() => _RequestLocationPageState();
}

class _RequestLocationPageState extends State<RequestLocationPage> {
  static const kInitialPosition = LatLng(25.3343, 55.3908);

  @override
  Widget build(BuildContext context) {
    return PlacePicker(
      apiKey: dotenv.env['mapsApiKey']!,
      onPlacePicked: (result) async {
        // Now navigate to the next page with all the information
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestConfirmationPage(
              selectedSupplies: widget.selectedSupplies,
              isFromRequestInventory: widget.isFromRequestInventory,
              address: result.formattedAddress,
              latitude: result.geometry!.location.lat,
              longitude: result.geometry!.location.lng,
            ),
          ),
        );
      },
      autoCompleteDebounceInMilliseconds: 100,
      selectText: 'Confirm Location',
      hintText: 'Search for a Specific Location',
      enableMapTypeButton: false,
      initialPosition: kInitialPosition,
      useCurrentLocation: true,
      resizeToAvoidBottomInset: false,
    );
  }

}
