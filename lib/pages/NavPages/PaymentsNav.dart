import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Model classes for data
class PaymentCard {
  final String cardType;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cardBackground;

  PaymentCard({
    required this.cardType,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cardBackground,
  });
}

class Invoice {
  final String invoiceId;
  final String serviceType;
  final double amount;
  final String paymentDate;
  final String paymentMethod;

  Invoice({
    required this.invoiceId,
    required this.serviceType,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
  });
}

class Paymentsnav extends StatefulWidget {
  const Paymentsnav({super.key});

  @override
  State<Paymentsnav> createState() => _PaymentsnavState();
}

class _PaymentsnavState extends State<Paymentsnav> {
  int _currentCardIndex = 0;

  // Dummy data directly defined in the class
  final List<PaymentCard> paymentCards = [
    PaymentCard(
      cardType: 'Visa',
      cardNumber: '**** **** **** 4567',
      expiryDate: '12/25',
      cardHolderName: 'John Doe',
      cardBackground: 'https://images.unsplash.com/photo-1639322537228-f710d846310a?q=80&w=500',
    ),
    PaymentCard(
      cardType: 'Mastercard',
      cardNumber: '**** **** **** 8901',
      expiryDate: '06/26',
      cardHolderName: 'John Doe',
      cardBackground: 'https://images.unsplash.com/photo-1639322537504-6427a16b0a28?q=80&w=500',
    ),
  ];

  final List<Invoice> paidInvoices = [
    Invoice(
      invoiceId: 'INV-2025-001',
      serviceType: 'Oil Change',
      amount: 45.99,
      paymentDate: '27/03/2025',
      paymentMethod: 'Visa *4567',
    ),
    Invoice(
      invoiceId: 'INV-2025-002',
      serviceType: 'Tire Rotation',
      amount: 35.50,
      paymentDate: '14/03/2025',
      paymentMethod: 'Mastercard *8901',
    ),
    Invoice(
      invoiceId: 'INV-2025-003',
      serviceType: 'Air Filter Replacement',
      amount: 25.75,
      paymentDate: '27/02/2025',
      paymentMethod: 'Visa *4567',
    ),
    Invoice(
      invoiceId: 'INV-2025-004',
      serviceType: 'Brake Pad Replacement',
      amount: 150.00,
      paymentDate: '12/02/2025',
      paymentMethod: 'Mastercard *8901',
    ),
    Invoice(
      invoiceId: 'INV-2025-005',
      serviceType: 'Full Service',
      amount: 199.99,
      paymentDate: '28/01/2025',
      paymentMethod: 'Visa *4567',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Payment Methods",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            // Payment Cards Carousel
            Column(
              children: [
                CarouselSlider.builder(
                  itemCount: paymentCards.length,
                  itemBuilder: (context, index, realIndex) {
                    PaymentCard card = paymentCards[index];
                    return PaymentCardWidget(card: card);
                  },
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.85,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCardIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Dot indicators for the cards carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    paymentCards.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentCardIndex == index
                            ? const Color(0xFF944EF8)
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Paid Invoices Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Payment History",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // Invoices List
            Expanded(
              child: ListView.builder(
                itemCount: paidInvoices.length,
                itemBuilder: (context, index) {
                  Invoice invoice = paidInvoices[index];
                  return InvoiceListItem(invoice: invoice);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new payment method page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new payment method')),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PaymentCardWidget extends StatelessWidget {
  final PaymentCard card;

  const PaymentCardWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          // Card Background
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              card.cardBackground,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF944EF8),
                  height: double.infinity,
                  width: double.infinity,
                );
              },
            ),
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.cardType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      card.cardType == 'Visa' ? Icons.credit_card : Icons.credit_card,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "EXPIRES",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              card.expiryDate,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CARD HOLDER",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              card.cardHolderName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;

  const InvoiceListItem({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          invoice.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Invoice ID: ${invoice.invoiceId}'),
            const SizedBox(height: 2),
            Text('Paid on: ${invoice.paymentDate}'),
            const SizedBox(height: 2),
            Text('Method: ${invoice.paymentMethod}'),
          ],
        ),
        trailing: Text(
          '\$${invoice.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF944EF8),
          ),
        ),
        onTap: () {
          // View invoice details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View invoice ${invoice.invoiceId} details')),
          );
        },
      ),
    );
  }
}