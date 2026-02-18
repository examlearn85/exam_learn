import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _bankNameController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    final success = await walletProvider.requestWithdrawal(
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscCodeController.text.trim().toUpperCase(),
      accountHolderName: _accountHolderNameController.text.trim(),
      bankName: _bankNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Withdrawal request submitted successfully! It will be processed within 24-48 hours.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit withdrawal request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Withdrawal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance,
                        size: 60,
                        color: Color(0xFFCBFE1C),
                      ),
                      const SizedBox(height: 16),
                      Consumer<WalletProvider>(
                        builder: (context, wallet, _) {
                          return Text(
                            'Withdraw ${wallet.goldCoins} Gold Coins',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your bank details below',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _accountHolderNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 9 || value.length > 18) {
                    return 'Invalid account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ifscCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  prefixIcon: Icon(Icons.qr_code),
                  hintText: 'ABCD0123456',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IFSC code';
                  }
                  if (value.length != 11) {
                    return 'IFSC code must be 11 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<WalletProvider>(
                builder: (context, wallet, _) {
                  return ElevatedButton(
                    onPressed: wallet.isLoading ? null : _submitWithdrawal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: wallet.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SUBMIT REQUEST'),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Note: Withdrawal requests are processed within 24-48 hours. You will receive a confirmation email once processed.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

