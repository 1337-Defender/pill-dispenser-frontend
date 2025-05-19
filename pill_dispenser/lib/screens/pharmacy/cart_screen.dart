import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'payment_screen.dart'; // 👈 Import your payment screen

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(LucideIcons.chevronLeft, color: Colors.black),
                      onPressed: () => Navigator.pop(
                          context), // ✅ Goes back to PlaceOrderScreen
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.bell, color: Colors.black),
                        onPressed: () {},
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(LucideIcons.user, color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),

              SizedBox(height: 16),

              // Title
              Text(
                'Checkout',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 16),

              // Product Card
              Container(
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
                            'Panadol',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Paracetamol • 500mg',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(LucideIcons.minus),
                        ),
                        Text(
                          '1',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(LucideIcons.plus),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(LucideIcons.trash2, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Discount Section
              Text(
                'Discount',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellowAccent,
                      foregroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

              SizedBox(height: 24),

              // Order Details
              Text(
                'Order Details',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),

              _buildOrderDetailRow('Order Total', 'AED 05.00'),
              _buildOrderDetailRow('VAT (5%)', 'AED 05.00'),
              _buildOrderDetailRow('Shipping', 'AED 05.00'),
              _buildOrderDetailRow('Discount', 'AED 05.00'),
              _buildOrderDetailRow('Total Amount', 'AED 05.00', isBold: true),

              Spacer(),

              // Proceed to Payment Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ Navigate to Payment Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String title, String amount,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
