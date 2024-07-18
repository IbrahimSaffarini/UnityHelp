import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_relief_application/Request/request_location_page.dart';
import 'package:disaster_relief_application/Request/supply_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestFromInventoryPage extends StatefulWidget {
  final List<DocumentSnapshot> inventoryItems;

  const RequestFromInventoryPage({super.key, required this.inventoryItems});

  @override
  _RequestFromInventoryPageState createState() => _RequestFromInventoryPageState();
}

class _RequestFromInventoryPageState extends State<RequestFromInventoryPage> {
  final globalNotifier = ValueNotifier<bool>(false);
  final ScrollController _scrollController = ScrollController();
  Map<String, ValueNotifier<int>> selectedSupplies = {};
  String? lastItemId;

  @override
  void dispose() {
    // Dispose of all ValueNotifiers to avoid memory leaks
    for (final notifier in selectedSupplies.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSelectedSupplies(widget.inventoryItems);
  }

  void _initializeSelectedSupplies(List<DocumentSnapshot> items) {
    // Identify the last item's ID
    lastItemId = items.isNotEmpty ? items.last.id : null;

    // Initialize listeners for supply item selection
    for (var item in items) {
      final itemId = item.id;
      selectedSupplies[itemId] = ValueNotifier<int>(0);
      selectedSupplies[itemId]!.addListener(() {
        _updateVisibility(itemId);
      });
    }
  }

  // Update global visibility and scroll to end if the last item is selected
  void _updateVisibility(String selectedItemId) {
    // Check if any item has a positive count
    final anySelected = selectedSupplies.values.any((notifier) => notifier.value > 0);

    // Check if the last item is selected
    final lastItemSelected =
        selectedItemId == lastItemId && selectedSupplies[selectedItemId]?.value != 0;

    if (anySelected) {
      globalNotifier.value = true;
      if (lastItemSelected) {
        _scrollToEnd();
      }
    } else {
      globalNotifier.value = false;
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleProceed() {
    // Prepare the filtered supplies map
    Map<String, int> filteredSupplies = {
      for (var e in selectedSupplies.entries) e.key: e.value.value
    }..removeWhere((key, value) => value <= 0);

    // Navigate to the next page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestLocationPage(
          selectedSupplies: filteredSupplies,
          isFromRequestInventory: true,
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: const Text('Request From Inventory'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: globalNotifier,
            builder: (context, isVisible, child) {
              if (!isVisible) return Container();
              return IconButton(
                icon: const Icon(Icons.location_on_outlined),
                onPressed: _handleProceed,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 96, 88, 180),
              Color.fromARGB(255, 130, 120, 185),
            ],
          ),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: globalNotifier,
          builder: (context, isVisible, child) {
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 26.0, right: 26.0, bottom: 16.0),
              itemCount: widget.inventoryItems.length,
              itemBuilder: (context, index) {
                var item = widget.inventoryItems[index];
                return SupplyItem(
                  supplyName: item['Item Name'],
                  availableQuantity: item['Item Quantity'],
                  selectedSupplies: selectedSupplies,
                  globalNotifier: globalNotifier,
                );
              },
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
