import 'package:flutter/material.dart';
import 'package:sdp_app/data/Invoices/PendingInvoiceData.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paynowpage extends StatefulWidget {
  final PendingInvoice invoice;

  const Paynowpage({
    super.key,
    required this.invoice,
  });

  @override
  State<Paynowpage> createState() => _PaynowpageState();
}

class _PaynowpageState extends State<Paynowpage> {
  String _selectedPaymentMethod = 'Pay Here';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay Invoice ${widget.invoice.invoiceId}'),
        backgroundColor: const Color(0xFF944EF8),
        foregroundColor: Colors.white,
      ),
      body: _isProcessing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF944EF8)),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice details section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Invoice ID', widget.invoice.invoiceId),
                    _buildDetailRow('Vehicle', '${widget.invoice.vehicleNo} - ${widget.invoice.model}'),
                    _buildDetailRow('Parts Cost', '\$${widget.invoice.partsCost.toStringAsFixed(2)}'),
                    _buildDetailRow('Labor Cost', '\$${widget.invoice.labourCost.toStringAsFixed(2)}'),
                    _buildDetailRow('Total Amount', '\$${widget.invoice.total.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Payment method selection
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            // Pay Here option
            _buildPaymentOption(
              'Pay Here',
              'Pay online with credit/debit card',
              Icons.credit_card,
            ),

            SizedBox(height: 12),

            // Cash option
            _buildPaymentOption(
              'Cash',
              'Pay at the cashier counter',
              Icons.money,
            ),

            SizedBox(height: 32),

            // Pay Now button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF944EF8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedPaymentMethod == 'Pay Here' ? 'Pay Now' : 'Confirm Cash Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? const Color(0xFF944EF8) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == title
                ? const Color(0xFF944EF8)
                : Colors.grey.shade300,
            width: 2,
          ),
          color: _selectedPaymentMethod == title
              ? const Color(0xFFF5F0FF)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: _selectedPaymentMethod == title
                  ? const Color(0xFF944EF8)
                  : Colors.grey.shade600,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedPaymentMethod == title
                          ? const Color(0xFF944EF8)
                          : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: title,
              groupValue: _selectedPaymentMethod,
              activeColor: const Color(0xFF944EF8),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (_selectedPaymentMethod == 'Pay Here') {
      // Handle online payment
      setState(() {
        _isProcessing = true;
      });

      // Simulate payment processing
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Payment Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Your payment of \$${widget.invoice.total.toStringAsFixed(2)} has been processed successfully.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true); // Return true to indicate payment success
                },
                child: Text('Done'),
              ),
            ],
          ),
        );
      });
    } else {
      // Handle cash payment with API call
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cash Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info,
                color: Colors.blue,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Please proceed to the cashier immediately to complete your payment.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Amount to pay: \$${widget.invoice.total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading indicator
                setState(() {
                  _isProcessing = true;
                });

                try {
                  // Get token from SharedPreferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString('token');

                  if (token == null) {
                    throw Exception("Authentication token is missing");
                  }

                  // Make API call with authentication token
                  final response = await DioInstance.putRequest(
                    '/api/customers/pay-invoice-cash/${widget.invoice.invoiceId}',
                    {},
                    options: Options(
                      headers: {
                        "Authorization": "Bearer $token",
                        "Content-Type": "application/json",
                      },
                    ),
                  );

                  setState(() {
                    _isProcessing = false;
                  });

                  if (response != null && response.statusCode == 200) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment recorded successfully')),
                    );
                    Navigator.of(context).pop(true); // Return true to indicate payment success
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to record payment. Please try again.')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isProcessing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF944EF8),
              ),
              child: Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
}
