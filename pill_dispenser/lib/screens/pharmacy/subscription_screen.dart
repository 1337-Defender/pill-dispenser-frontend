import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'pharmacy_home_screen.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

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

  void _showOptionsMenu(
    BuildContext context,
    Offset offset,
    String medicationName,
    int index,
  ) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + 1,
        offset.dy + 1,
      ),
      items: [
        const PopupMenuItem<String>(value: 'pause', child: Text('Pause')),
        const PopupMenuItem<String>(
          value: 'skip',
          child: Text('Skip Delivery'),
        ),
        const PopupMenuItem<String>(
          value: 'cancel',
          child: Text('Cancel Subscription'),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit Quantity'),
        ),
      ],
    );
    if (selected == null) return;
    switch (selected) {
      case 'pause':
        setState(() => subscriptions[index]['status'] = 'Paused');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$medicationName paused")));
        break;
      case 'skip':
        setState(() => subscriptions[index]['next_delivery'] = 'Skipped');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Next delivery skipped")));
        break;
      case 'cancel':
        setState(() => subscriptions.removeAt(index));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$medicationName canceled")));
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
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Quantity for $medicationName",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter quantity",
                    hintStyle: GoogleFonts.inter(),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 248, 248, 248),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(64),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 24,
                    ),
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
                    setState(
                      () => subscriptions[index]['quantity'] = newQuantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Quantity updated to $newQuantity"),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    size: 16,
                  ), // Use Material Icons
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
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
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ), // Match home screen
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.chevronLeft,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.bell, color: Colors.black),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(LucideIcons.user, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Title and actions (match home screen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Match home screen
                child: Text(
                  'Recurring Subscriptions',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subscriptions List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // Match home screen
                  child:
                      subscriptions.isEmpty
                          ? Container(
                            margin: const EdgeInsets.only(top: 24, bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.pill,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          )
                          : ListView.builder(
                            itemCount: subscriptions.length,
                            itemBuilder: (context, index) {
                              final sub = subscriptions[index];
                              final status = sub['status'] as String;
                              final nextDelivery =
                                  sub['next_delivery'] as String;
                              final price = sub['price'] as double;
                              final quantity = sub['quantity'] as int;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ), // Match home screen
                                padding: const EdgeInsets.all(
                                  16,
                                ), // Match home screen
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        LucideIcons.pill,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub['medication_name'],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Next Delivery: $nextDelivery",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Price: AED ${price.toStringAsFixed(2)} | Quantity: $quantity",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      status == 'Active'
                                                          ? Colors.green[100]
                                                          : Colors.red[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  status == 'Active'
                                                      ? 'Active'
                                                      : 'Paused',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color:
                                                        status == 'Active'
                                                            ? Colors.green[800]
                                                            : Colors.red[800],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Builder(
                                      builder:
                                          (context) => IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            icon: const Icon(
                                              LucideIcons.ellipsis,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final RenderBox button =
                                                  context.findRenderObject()
                                                      as RenderBox;
                                              final Offset offset = button
                                                  .localToGlobal(Offset.zero);
                                              _showOptionsMenu(
                                                context,
                                                offset,
                                                sub['medication_name'],
                                                index,
                                              );
                                            },
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
