import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'cart_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({Key? key}) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cartItems = []; // Track selected medications
  int? _selectedProductId; // Track selected tile

  void _onItemTapped(int index) async {
    final item = products[index];
    final productId = item['id'];
    setState(() {
      _selectedProductId = productId;
    });
    final productDetails = await Supabase.instance.client
        .from('products')
        .select()
        .eq('id', productId)
        .single();
    // Always start with quantity 1 when opening the bottom sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int tempQuantity = 1; // Always default to 1
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productDetails['name'],
                        style: GoogleFonts.inter(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${productDetails['description']} • ${productDetails['strength']}',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      if (productDetails['details'] != null)
                        Text(
                          productDetails['details'],
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.grey[800]),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: tempQuantity > 1
                                ? () async {
                                    setModalState(() => tempQuantity--);
                                    await _updateCartQuantityInDatabase(
                                        productId, tempQuantity);
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$tempQuantity',
                                style: GoogleFonts.inter(fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              setModalState(() => tempQuantity++);
                              await _updateCartQuantityInDatabase(
                                  productId, tempQuantity);
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellowAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () async {
                              setState(() {
                                final idx = cartItems
                                    .indexWhere((c) => c['id'] == productId);
                                if (idx != -1) {
                                  cartItems[idx]['quantity'] = tempQuantity;
                                } else {
                                  final newItem =
                                      Map<String, dynamic>.from(productDetails);
                                  newItem['quantity'] = tempQuantity;
                                  cartItems.add(newItem);
                                }
                              });
                              await _updateCartQuantityInDatabase(
                                  productId, tempQuantity);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'ADD  AED ' +
                                  ((productDetails['price'] is num
                                              ? productDetails['price']
                                              : double.tryParse(
                                                      productDetails['price']
                                                          .toString()) ??
                                                  0.0) *
                                          tempQuantity)
                                      .toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    setState(() {
      _selectedProductId = null;
    });
  }

  Future<void> _updateCartQuantityInDatabase(
      int productId, int quantity) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('cart').update({
          'quantity': quantity,
        }).match({
          'user_id': userId,
          'product_id': productId,
        });
      }
    } catch (e) {
      print("Error updating cart quantity: $e");
    }
  }

  Future<void> _insertCartItemInDatabase(Map<String, dynamic> product) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('cart').insert({
          'user_id': userId,
          'product_id': product['id'],
          'quantity': 1,
        });
      }
    } catch (e) {
      print("Error inserting cart item: $e");
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await Supabase.instance.client.from('products').select();
      setState(() {
        products = response.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
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
                // children: [
                //   CircleAvatar(
                //     backgroundColor: Colors.white,
                //     child: IconButton(
                //       icon: Icon(LucideIcons.chevronLeft, color: Colors.black),
                //       onPressed: () => Navigator.pop(context),
                //     ),
                //   ),
                //   Row(
                //     children: [
                //       IconButton(
                //         icon: Icon(LucideIcons.bell, color: Colors.black),
                //         onPressed: () {},
                //       ),
                //       SizedBox(width: 8),
                //       CircleAvatar(
                //         backgroundColor: Colors.white,
                //         child: Icon(LucideIcons.user, color: Colors.black),
                //       ),
                //     ],
                //   ),
                // ],
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
                      context.push('/cart', extra: cartItems);
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
                        context.push('/subscriptions');
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
                        context.push('/order_history');
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
                    final isSelected = _selectedProductId == item['id'];

                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: _ProductTile(
                        name: item['name'],
                        subtitle:
                            '${item['description']} • ${item['strength']}',
                        price: 'AED ${item['price'].toStringAsFixed(2)}',
                        isSelected: isSelected,
                      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12), // Space between icon and title
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
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
  final bool isSelected;

  const _ProductTile({
    Key? key,
    required this.name,
    required this.subtitle,
    required this.price,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.yellowAccent : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.pill, size: 20),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
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
