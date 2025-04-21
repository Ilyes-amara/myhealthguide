import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart';
import 'dart:math';

class UserPaymentProcessingPage extends StatefulWidget {
  final int months;
  final double amount;

  const UserPaymentProcessingPage({
    super.key,
    required this.months,
    required this.amount,
  });

  @override
  State<UserPaymentProcessingPage> createState() =>
      _UserPaymentProcessingPageState();
}

class _UserPaymentProcessingPageState extends State<UserPaymentProcessingPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;
  String _paymentMethod = 'Credit Card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // 90% chance of success
    final random = Random();
    final isSuccess = random.nextDouble() < 0.9;

    if (!mounted) return;

    if (isSuccess) {
      // Update subscription in provider
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).activateSubscription(widget.months);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your subscription is now active.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to subscription page
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      setState(() {
        _isProcessing = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Payment'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Patient Premium (${widget.months} month${widget.months > 1 ? 's' : ''})',
                          ),
                          Text('${widget.amount.toStringAsFixed(2)} DA'),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.amount.toStringAsFixed(2)} DA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment method selection
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text('Credit Card'),
                        ],
                      ),
                      value: 'Credit Card',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text('Bank Transfer'),
                        ],
                      ),
                      value: 'Bank Transfer',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_paymentMethod == 'Credit Card') ...[
                const Text(
                  'Card Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Card number field
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    if (value.replaceAll(' ', '').length != 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Card holder name
                TextFormField(
                  controller: _cardHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiry date and CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Format: MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter CVV';
                          }
                          if (value.length != 3) {
                            return 'CVV must be 3 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (_paymentMethod == 'Bank Transfer') ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Transfer Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text('Please transfer the exact amount to:'),
                        SizedBox(height: 8),
                        Text('Bank: HealthGuide National Bank'),
                        Text('Account Name: HealthGuide Inc.'),
                        Text('Account Number: 1234567890'),
                        Text('Reference: Your email address'),
                        SizedBox(height: 12),
                        Text(
                          'Your subscription will be activated within 24 hours after payment confirmation.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Payment button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isProcessing
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Processing...'),
                            ],
                          )
                          : const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
