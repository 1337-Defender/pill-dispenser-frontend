import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import screens for navigation (if needed)
// import 'cart_screen.dart';
import 'cart_screen.dart'; // Ensure this is correctly imported
import 'subscription_screen.dart';
import 'order_history_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({Key? key}) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _selectedIndex = 3;
  List<Map<String, dynamic>> products = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await Supabase.instance.client.from('products').select();

      if (response is List) {
        setState(() {
          products = response.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(LucideIcons.chevronLeft, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(LucideIcons.bell, color: Colors.black),
                  //       onPressed: () {},
                  //     ),
                  //     SizedBox(width: 8),
                  //     CircleAvatar(
                  //       backgroundColor: Colors.white,
                  //       child: Icon(LucideIcons.user, color: Colors.black),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            // Title and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Place Order',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(LucideIcons.search, size: 28),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellowAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Action cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: LucideIcons.cloudUpload,
                      title: 'Upload Prescription',
                      subtitle: 'Upload prescription image',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ActionCard(
                      icon: LucideIcons.repeat,
                      title: 'Recurring Orders',
                      subtitle: 'Subscribe and Get 10% Off',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ActionCard(
                      icon: LucideIcons.list,
                      title: 'Order History',
                      subtitle: 'Your active and past orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            Divider(thickness: 1),

            // Product list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final name = item['name'];
                    final description =
                        '${item['description']} • ${item['strength']}';
                    final price = 'AED ${item['price']}';

                    return _ProductTile(
                      name: name,
                      subtitle: description,
                      price: price,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// == ACTION CARD WIDGET ==
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
              ],
            ),
            SizedBox(height: 12), // Space between icon and title
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// == PRODUCT TILE WIDGET ==
class _ProductTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;

  const _ProductTile({
    Key? key,
    required this.name,
    required this.subtitle,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.pill, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
