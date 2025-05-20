// lib/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Hardcoded orders for now
  List<Map<String, dynamic>> allOrders = [
    {
      'id': 1,
      'medication_name': 'Panadol',
      'status': 'Completed',
      'order_date': '2025-05-10',
      'delivery_date': '2025-05-13',
      'total_amount': 15.0,
    },
    {
      'id': 2,
      'medication_name': 'Amoxicillin',
      'status': 'Pending',
      'order_date': '2025-05-11',
      'delivery_date': '2025-05-16',
      'total_amount': 28.0,
    },
    {
      'id': 3,
      'medication_name': 'Vitamin D',
      'status': 'Active',
      'order_date': '2025-05-12',
      'delivery_date': '2025-05-20',
      'total_amount': 22.5,
    },
    {
      'id': 4,
      'medication_name': 'Paracetamol',
      'status': 'Completed',
      'order_date': '2025-04-29',
      'delivery_date': '2025-05-02',
      'total_amount': 10.0,
    },
    {
      'id': 5,
      'medication_name': 'Ibuprofen',
      'status': 'Active',
      'order_date': '2025-05-13',
      'delivery_date': '2025-05-20',
      'total_amount': 12.0,
    },
  ];

  String filterOption = 'All'; // Default filter

  List<Map<String, dynamic>> get filteredOrders {
    if (filterOption == 'All') return allOrders;
    if (filterOption == 'Active')
      return allOrders.where((o) => o['status'] == 'Active').toList();
    return allOrders.where((o) => o['status'] == 'Completed').toList();
  }

  void _showOptionsMenu(BuildContext context, Offset offset,
      String medicationName, int index) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      items: [
        const PopupMenuItem<String>(value: 'view', child: Text('View Details')),
        const PopupMenuItem<String>(
            value: 'cancel', child: Text('Cancel Order')),
      ],
    );
    if (selected == null) return;
    switch (selected) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Viewing details for $medicationName")),
        );
        break;
      case 'cancel':
        setState(() {
          allOrders.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order for $medicationName canceled")),
        );
        break;
    }
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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (moved from appBar, matches subscription screen)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon:
                            Icon(LucideIcons.chevronLeft, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop();
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
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Your Orders",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: [
                      // Filter Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // All, Active, Completed tabs aligned to the left
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => filterOption = 'All'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: filterOption == 'All'
                                          ? const Color.fromARGB(
                                              255, 239, 255, 61)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      'All',
                                      style: GoogleFonts.inter(
                                        color: filterOption == 'All'
                                            ? Colors.black
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => filterOption = 'Active'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: filterOption == 'Active'
                                          ? const Color.fromARGB(
                                              255, 239, 255, 61)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: GoogleFonts.inter(
                                        color: filterOption == 'Active'
                                            ? Colors.black
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => filterOption = 'Completed'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: filterOption == 'Completed'
                                          ? const Color.fromARGB(
                                              255, 239, 255, 61)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: GoogleFonts.inter(
                                        color: filterOption == 'Completed'
                                            ? Colors.black
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Orders List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final status = order['status'] as String;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      // color: Colors.yellowAccent,
                                      // borderRadius: BorderRadius.circular(12),
                                      ),
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
                                        order['medication_name'],
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Ordered on " + order['order_date'],
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Expected Delivery: " +
                                            order['delivery_date'],
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "AED " +
                                            order['total_amount']
                                                .toStringAsFixed(2),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: status == 'Completed'
                                              ? const Color.fromARGB(
                                                  255, 143, 255, 143)
                                              : status == 'Active'
                                                  ? const Color.fromARGB(
                                                      255, 255, 193, 7)
                                                  : const Color.fromARGB(
                                                      255, 239, 61, 61),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
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
                                        minWidth: 32, minHeight: 32),
                                    icon: const Icon(LucideIcons.ellipsis,
                                        size: 20),
                                    onPressed: () async {
                                      final RenderBox button = context
                                          .findRenderObject() as RenderBox;
                                      final Offset offset =
                                          button.localToGlobal(Offset.zero);
                                      _showOptionsMenu(context, offset,
                                          order['medication_name'], index);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (filteredOrders.isEmpty)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 24, bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.black, size: 20),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "No Orders Found",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "You don't have any orders yet.",
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
                        ),
                    ],
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
