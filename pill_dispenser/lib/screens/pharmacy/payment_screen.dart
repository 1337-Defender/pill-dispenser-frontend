import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum PaymentMethod { card, cod, wallet }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod selectedMethod = PaymentMethod.card;
  bool isFormValid = false; // Track form validity
  int? _selectedMonth;
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null,
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
                      onPressed: () => Navigator.pop(context),
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

              Text(
                'Select Payment Method',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),

              // Payment Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _PaymentOptionCard(
                      label: 'Cash on Delivery',
                      subtitle: 'Surcharge of AED 10 will be applied',
                      icon: LucideIcons.banknote,
                      isSelected: selectedMethod == PaymentMethod.cod,
                      onTap: () =>
                          setState(() => selectedMethod = PaymentMethod.cod),
                      minHeight: 120, // Set a fixed height for all tiles
                      alignLeft: true, // Move contents to left
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _PaymentOptionCard(
                      label: 'Digital Wallet',
                      subtitle: 'Pay with your own Digital Wallet',
                      icon: LucideIcons.wallet,
                      isSelected: selectedMethod == PaymentMethod.wallet,
                      onTap: () =>
                          setState(() => selectedMethod = PaymentMethod.wallet),
                      minHeight: 120,
                      alignLeft: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _PaymentOptionCard(
                      label: 'Card Payment',
                      subtitle: 'Pay with your Credit or Debit Card',
                      icon: LucideIcons.creditCard,
                      isSelected: selectedMethod == PaymentMethod.card,
                      onTap: () =>
                          setState(() => selectedMethod = PaymentMethod.card),
                      minHeight: 120,
                      alignLeft: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Card Details (Visible only for Card Payment)
              if (selectedMethod == PaymentMethod.card) ...[
                Text(
                  'Card Details',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 12),
                _buildTextField('Card Number', '1234 1234 1234 1234'),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Expiry Date', 'MM/YY')),
                    SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField('CVV', '***', isObscure: true)),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // Digital Wallet Balance (Visible only for Digital Wallet)
              if (selectedMethod == PaymentMethod.wallet)
                _buildInfoRow('Digital Wallet Balance', 'AED 05.00'),

              // Surcharge (Visible only for Cash on Delivery)
              if (selectedMethod == PaymentMethod.cod)
                _buildInfoRow('Surcharge', 'AED 10.00'),

              // Loyalty Points
              _buildInfoRow(
                'Loyalty Points',
                'AED 05.00',
                trailing: _YellowButton(text: 'Redeem Points'),
              ),

              // Total Amount
              _buildInfoRow('Total Amount', 'AED 05.00'),

              // Payable Amount
              _buildInfoRow(
                'Payable',
                selectedMethod == PaymentMethod.cod ? 'AED 15.00' : 'AED 05.00',
                isBold: true,
              ),

              Spacer(),

              // Pay/Confirm Button
              Center(
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {}
                      : null, // Disable button if form is not valid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 56),
                  ),
                  child: Text(
                    selectedMethod == PaymentMethod.card
                        ? 'Pay Now'
                        : 'Confirm Payment',
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

  Widget _buildTextField(String label, String hint, {bool isObscure = false}) {
    if (label == 'Expiry Date') {
      final now = DateTime.now();
      final months = List.generate(12, (i) => i + 1);
      final years = List.generate(20, (i) => now.year + i);
      return Container(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Month',
                  labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                ),
                value: _selectedMonth,
                items: months
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.toString().padLeft(2, '0'),
                              style: GoogleFonts.inter(fontSize: 18)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val;
                  });
                },
                style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Year',
                  labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                ),
                value: _selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString(),
                              style: GoogleFonts.inter(fontSize: 18)),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedYear = val;
                  });
                },
                style: GoogleFonts.inter(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    }
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 18),
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
      style: GoogleFonts.inter(fontSize: 18),
      keyboardType: isObscure ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Widget? trailing, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8),
                trailing,
              ]
            ],
          ),
        ],
      ),
    );
  }
}

// Payment Option Card Widget
class _PaymentOptionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double minHeight;
  final bool alignLeft;

  const _PaymentOptionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.minHeight = 100,
    this.alignLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellowAccent : Colors.white,
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
          crossAxisAlignment:
              alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 28, color: isSelected ? Colors.black : Colors.grey[700]),
            SizedBox(height: 8),
            Text(
              label,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
              textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Yellow Button Widget
class _YellowButton extends StatelessWidget {
  final String text;

  const _YellowButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellowAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
