import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<Map<String, dynamic>> cartItems;
  final TextEditingController _discountCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartItems = List<Map<String, dynamic>>.from(widget.cartItems);
  }

  void _updateQuantity(int index, int delta) async {
    setState(() {
      cartItems[index]['quantity'] += delta;
      if (cartItems[index]['quantity'] <= 0) {
        _removeFromCart(index);
      } else {
        _updateCartQuantityInDatabase(
          cartItems[index]['id'],
          cartItems[index]['quantity'],
        );
      }
    });
  }

  void _removeFromCart(int index) async {
    final productId = cartItems[index]['id'];
    setState(() {
      cartItems.removeAt(index);
    });
    await _removeCartItemFromDatabase(productId);
  }

  Future<void> _updateCartQuantityInDatabase(
    int productId,
    int quantity,
  ) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('cart')
            .update({'quantity': quantity})
            .match({'user_id': userId, 'product_id': productId});
      }
    } catch (e) {
      print("Error updating cart quantity: $e");
    }
  }

  Future<void> _removeCartItemFromDatabase(int productId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('cart').delete().match({
          'user_id': userId,
          'product_id': productId,
        });
      }
    } catch (e) {
      print("Error removing cart item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null, // Remove the AppBar
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (matches order history screen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
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
                          // Use GoRouter to navigate to pharmacy home screen
                          // context.push('/place_order');
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    // Calculate totals
                    double orderTotal = cartItems.fold(0.0, (sum, item) {
                      final price =
                          item['price'] is num
                              ? item['price']
                              : double.tryParse(item['price'].toString()) ??
                                  0.0;
                      final quantity = item['quantity'] ?? 1;
                      return sum + (price * quantity);
                    });
                    double vat = orderTotal * 0.05;
                    double shipping = orderTotal > 0 ? 10.0 : 0.0;
                    double discount = 0.0;
                    if (_discountCodeController.text.trim().toLowerCase() ==
                        'sale') {
                      discount = -5.0;
                    }
                    double totalAmount = orderTotal + vat + shipping + discount;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkout',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display Cart Items
                        if (cartItems.isNotEmpty) ...[
                          ...cartItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final name = item['name'];
                            final description = item['description'];
                            final price = item['price'].toStringAsFixed(2);
                            final quantity = item['quantity'] ?? 1;
                            return _CartItem(
                              name: name,
                              description: description,
                              price: price,
                              quantity: quantity,
                              onIncrement: () => _updateQuantity(index, 1),
                              onDecrement: () => _updateQuantity(index, -1),
                              onDelete: () => _removeFromCart(index),
                            );
                          }).toList(),
                          const SizedBox(height: 24),
                          // Discount Section
                          Text(
                            'Discount',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _discountCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Type Discount Code',
                                    hintStyle: GoogleFonts.inter(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setModalState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellowAccent,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'APPLY',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Order Details
                          Text(
                            'Order Details',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Order Total',
                            'AED ' + orderTotal.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            'VAT (5%)',
                            'AED ' + vat.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            'Shipping',
                            'AED ' + shipping.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            'Discount',
                            'AED ' + discount.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            'Total Amount',
                            'AED ' + totalAmount.toStringAsFixed(2),
                            isBold: true,
                          ),
                          const SizedBox(height: 24),
                          // Proceed to Payment Button
                          Center(
                            child: ElevatedButton(
                              onPressed:
                                  cartItems.isNotEmpty
                                      ? () {
                                        // Navigate to payment screen using GoRouter, passing totalAmount
                                        context.push(
                                          '/payment',
                                          extra: {'totalAmount': totalAmount},
                                        );
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellowAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Proceed to Payment',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: Text(
                              'No items in cart',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: GoogleFonts.inter(),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      style: GoogleFonts.inter(),
      keyboardType: isObscure ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// == CART ITEM WIDGET ==
class _CartItem extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItem({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  description,
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AED ${(double.tryParse(price) != null ? (double.parse(price) * quantity).toStringAsFixed(2) : price)}',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: Icon(Icons.remove, color: Colors.grey[700]),
              ),
              Text(
                '$quantity',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: Icon(Icons.add, color: Colors.grey[700]),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(LucideIcons.trash2, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
