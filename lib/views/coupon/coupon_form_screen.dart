import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon_model.dart';
import '../../providers/coupon_provider.dart';
import 'package:intl/intl.dart'; // Add this import at the top


class CouponFormScreen extends StatefulWidget {
  final CouponModel? coupon;

  const CouponFormScreen({Key? key, this.coupon}) : super(key: key);

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _discountController;
  late TextEditingController _expiryDateController;
  late bool _isActive;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
        text: widget.coupon?.code ?? '');
    _discountController = TextEditingController(
        text: widget.coupon?.discountPercentage.toString() ?? '');
    _expiryDate = widget.coupon?.expiryDate;
    _expiryDateController = TextEditingController(
        text: _expiryDate != null
            ? DateFormat('yyyy-MM-dd').format(_expiryDate!)
            : '');
    _isActive = widget.coupon?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coupon == null ? 'Create Coupon' : 'Edit Coupon'),
        actions: [
          if (widget.coupon != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _showDeleteDialog(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Coupon Code',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a coupon code';
                  }
                  if (value.length < 4) {
                    return 'Code must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Discount Percentage',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount percentage';
                  }
                  final discount = double.tryParse(value);
                  if (discount == null) {
                    return 'Please enter a valid number';
                  }
                  if (discount <= 0 || discount >= 100) {
                    return 'Discount must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _expiryDate = selectedDate;
                      _expiryDateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  }
                },
                validator: (value) {
                  if (_expiryDate == null) {
                    return 'Please select an expiry date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Coupon'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: const Icon(Icons.toggle_on),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveCoupon(context);
                    }
                  },
                  child: const Text('Save Coupon'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCoupon(BuildContext context) async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final coupon = CouponModel(
      id: widget.coupon?.id,
      code: _codeController.text.trim().toUpperCase(),
      discountPercentage: double.parse(_discountController.text),
      expiryDate: _expiryDate!,
      isActive: _isActive,
    );

    try {
      if (widget.coupon == null) {
        await couponProvider.addCoupon(coupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await couponProvider.updateCoupon(coupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete ${_codeController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final couponProvider =
                Provider.of<CouponProvider>(context, listen: false);
                await couponProvider.deleteCoupon(widget.coupon!.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_codeController.text} deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}