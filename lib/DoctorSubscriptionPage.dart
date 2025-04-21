import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DoctorProvider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class DoctorSubscriptionPage extends StatefulWidget {
  const DoctorSubscriptionPage({super.key});

  @override
  State<DoctorSubscriptionPage> createState() => _DoctorSubscriptionPageState();
}

class _DoctorSubscriptionPageState extends State<DoctorSubscriptionPage> {
  int _selectedPlan = 1; // Default to 1 month
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final hasSubscription = doctorProvider.hasActiveSubscription;
    final subscriptionAmount =
        doctorProvider.doctorData['subscriptionAmount'] ?? 2000.0;
    String expiryDate = 'No active subscription';

    if (hasSubscription &&
        doctorProvider.doctorData['subscriptionExpiry'] != null) {
      final expiry = DateTime.parse(
        doctorProvider.doctorData['subscriptionExpiry'],
      );
      expiryDate = DateFormat('MMMM dd, yyyy').format(expiry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptionHeader(hasSubscription, expiryDate),
            const SizedBox(height: 24),
            if (!hasSubscription) ...[
              const Text(
                'Select a Subscription Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionPlans(subscriptionAmount),
              const SizedBox(height: 32),
              _buildSubscribeButton(subscriptionAmount),
            ] else ...[
              _buildActiveSubscriptionInfo(expiryDate),
              const SizedBox(height: 24),
              _buildCancelButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionHeader(bool hasSubscription, String expiryDate) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 26,
                  child: Icon(
                    hasSubscription ? Icons.star : Icons.star_border,
                    color: Colors.blue.shade800,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasSubscription ? 'Premium Account' : 'Basic Account',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hasSubscription
                            ? 'Subscription active until $expiryDate'
                            : 'Upgrade to access premium features',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Premium Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('Unlimited access to AI Medical Assistant'),
            _buildFeatureItem('Advanced patient analytics'),
            _buildFeatureItem('Custom reminders and notifications'),
            _buildFeatureItem('Priority support'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(double baseAmount) {
    return Column(
      children: [
        _buildPlanCard(1, baseAmount, false),
        _buildPlanCard(3, (baseAmount * 3 * 0.9), true), // 10% discount
        _buildPlanCard(6, (baseAmount * 6 * 0.8), true), // 20% discount
        _buildPlanCard(12, (baseAmount * 12 * 0.7), true), // 30% discount
      ],
    );
  }

  Widget _buildPlanCard(int months, double amount, bool hasDiscount) {
    final isSelected = _selectedPlan == months;
    final formattedAmount = amount.toInt().toString();

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade800 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = months;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.blue.shade800
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? Colors.blue.shade800 : Colors.white,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$months ${months == 1 ? 'Month' : 'Months'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        'Best value: ${(months == 3
                            ? '10%'
                            : months == 6
                            ? '20%'
                            : '30%')} off',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$formattedAmount DA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    months > 1
                        ? '${(amount / months).toInt()} DA/month'
                        : 'Monthly price',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(double baseAmount) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(baseAmount),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Subscribe Now',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _navigateToPayment(double baseAmount) {
    // Calculate the amount based on the selected plan
    double amount;
    switch (_selectedPlan) {
      case 1:
        amount = baseAmount;
        break;
      case 3:
        amount = baseAmount * 3 * 0.9; // 10% discount
        break;
      case 6:
        amount = baseAmount * 6 * 0.8; // 20% discount
        break;
      case 12:
        amount = baseAmount * 12 * 0.7; // 30% discount
        break;
      default:
        amount = baseAmount;
    }

    // Navigate to payment processing page
    Navigator.pushNamed(
      context,
      '/payment_processing',
      arguments: {'months': _selectedPlan, 'amount': amount},
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isProcessing ? null : () => _confirmCancelSubscription(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isProcessing
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.red.shade300,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Cancel Subscription',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildActiveSubscriptionInfo(String expiryDate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Current Subscription',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade800),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      expiryDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade800),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Type',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Premium Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your subscription will automatically expire on the date shown above. You can renew your subscription at any time.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelSubscription() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Subscription'),
            content: const Text(
              'Are you sure you want to cancel your subscription? You will lose access to premium features immediately.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No, Keep It'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelSubscription();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }

  void _cancelSubscription() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate cancellation processing
    Future.delayed(const Duration(seconds: 1), () {
      Provider.of<DoctorProvider>(context, listen: false).cancelSubscription();

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your subscription has been cancelled.')),
      );
    });
  }
}
