import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';

class SupplyItem extends StatefulWidget {
  final String supplyName;
  final int availableQuantity;
  final Map<String, ValueNotifier<int>> selectedSupplies;
  final ValueNotifier<bool> globalNotifier;

  const SupplyItem({
    required this.supplyName,
    required this.availableQuantity,
    required this.selectedSupplies,
    required this.globalNotifier,
    super.key,
  });

  @override
  _SupplyItemState createState() => _SupplyItemState();
}

class _SupplyItemState extends State<SupplyItem> {
  @override
  void initState() {
    super.initState();
    widget.selectedSupplies.putIfAbsent(widget.supplyName, () => ValueNotifier<int>(0));
  }

  @override
  Widget build(BuildContext context) {
     // Create a path to the image using the supply name
    String imagePath = 'assets/${widget.supplyName}.png';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9.2),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Placeholder for the image on the left
          Container(
            width: MediaQuery.of(context).size.width * 0.40,
            height: MediaQuery.of(context).size.height * 0.1755,
            margin: const EdgeInsets.only(right: 16.0),
            
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, size: 40); // Fallback icon if the image is not found
              },
            ),
          ),

          // Text info and input quantity button on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item',
                  style: GoogleFonts.notoSansKhudawadi(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.supplyName,
                  style: GoogleFonts.rubik(fontSize: 16),
                ),
                Text(
                  'Available Stock',
                  style: GoogleFonts.notoSansKhudawadi(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${widget.availableQuantity}',
                  style: GoogleFonts.rubik(fontSize: 16),
                ),
                Text(
                  'Choose Quantity',
                  style: GoogleFonts.notoSansKhudawadi(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10.0,),
                ValueListenableBuilder<int>(
                  valueListenable: widget.selectedSupplies[widget.supplyName]!,
                  builder: (context, count, child) {
                    return InputQty.int(
                      decoration: const QtyDecorationProps(
                        iconColor: Color.fromARGB(255, 96, 88, 180),
                        isBordered: false,
                        borderShape: BorderShapeBtn.circle,
                        width: 15,
                        qtyStyle: QtyStyle.classic,
                      ),
                      initVal: count,
                      minVal: 0,
                      maxVal: widget.availableQuantity,
                      steps: 1,
                      onQtyChanged: (value) {
                        widget.selectedSupplies[widget.supplyName]!.value = value;
                        widget.globalNotifier.value =
                            widget.selectedSupplies.values.any((notifier) => notifier.value > 0);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
