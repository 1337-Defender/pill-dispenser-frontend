// lib/screens/pharmacy/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Hardcoded subscriptions for now
  List<Map<String, dynamic>> subscriptions = [
    {
      'medication_name': 'Panadol',
      'status': 'Active',
      'next_delivery': '2025-06-10',
      'price': 5.0,
      'quantity': 30,
    },
    {
      'medication_name': 'Amoxicillin',
      'status': 'Paused',
      'next_delivery': 'N/A',
      'price': 7.0,
      'quantity': 20,
    },
    {
      'medication_name': 'Vitamin D',
      'status': 'Active',
      'next_delivery': '2025-06-15',
      'price': 4.5,
      'quantity': 15,
    },
  ];

  void _showOptionsMenu(BuildContext context, Offset offset,
      String medicationName, int index) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      items: [
        const PopupMenuItem<String>(value: 'pause', child: Text('Pause')),
        const PopupMenuItem<String>(
            value: 'skip', child: Text('Skip Delivery')),
        const PopupMenuItem<String>(
            value: 'cancel', child: Text('Cancel Subscription')),
        const PopupMenuItem<String>(
            value: 'edit', child: Text('Edit Quantity')),
      ],
    );
    if (selected == null) return;
    switch (selected) {
      case 'pause':
        setState(() => subscriptions[index]['status'] = 'Paused');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$medicationName paused")));
        break;
      case 'skip':
        setState(() => subscriptions[index]['next_delivery'] = 'Skipped');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Next delivery skipped")));
        break;
      case 'cancel':
        setState(() => subscriptions.removeAt(index));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$medicationName canceled")));
        break;
      case 'edit':
        _showEditQuantityDialog(medicationName, index);
        break;
    }
  }

  void _showEditQuantityDialog(String medicationName, int index) {
    int newQuantity = subscriptions[index]['quantity'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Quantity for $medicationName",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter quantity",
                filled: true,
                fillColor: const Color.fromARGB(255, 248, 248, 248),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(64),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && int.tryParse(value) != null) {
                  newQuantity = int.parse(value);
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                setState(() => subscriptions[index]['quantity'] = newQuantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Quantity updated to $newQuantity")),
                );
              },
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 239, 255, 61),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Custom white popup menu theme
    final popupMenuTheme = PopupMenuThemeData(
      color: Colors.white, // White background
      textStyle: GoogleFonts.inter(
        color: Colors.black, // Black text
        fontSize: 14,
      ),
    );

    return PopupMenuTheme(
      data: popupMenuTheme,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 242, 243, 244),
        appBar: AppBar(
          title: Text(
            "Recurring Subscriptions",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Text(
                "Subscriptions",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ClipRect(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subscriptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0, // Shorter height
                  ),
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    final status = sub['status'] as String;
                    final nextDelivery = sub['next_delivery'] as String;
                    final price = sub['price'] as double;
                    final quantity = sub['quantity'] as int;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub['medication_name'],
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Next Delivery: $nextDelivery",
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Price: AED ${price.toStringAsFixed(2)} | Quantity: $quantity",
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'Active'
                                        ? const Color.fromARGB(
                                            255, 143, 255, 143)
                                        : const Color.fromARGB(
                                            255, 255, 193, 7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) => IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 24, minHeight: 24),
                              icon: const Icon(LucideIcons.ellipsis, size: 16),
                              onPressed: () async {
                                final RenderBox button =
                                    context.findRenderObject() as RenderBox;
                                final Offset offset =
                                    button.localToGlobal(Offset.zero);
                                _showOptionsMenu(context, offset,
                                    sub['medication_name'], index);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (subscriptions.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medication,
                          color: Colors.black, size: 20),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No Active Subscriptions",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "You don't have any active subscriptions yet.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
