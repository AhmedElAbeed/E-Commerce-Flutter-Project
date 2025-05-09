import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _stockController;

  // Color scheme
  final Color _primaryColor = Colors.indigo.shade800;
  final Color _secondaryColor = Colors.blueAccent.shade400;
  final Color _errorColor = Colors.red.shade400;
  final Color _successColor = Colors.green.shade400;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '0.0');
    _imageController = TextEditingController(text: widget.product?.image ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(color: _primaryColor),
      floatingLabelStyle: TextStyle(color: _secondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add New Product' : 'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('Product Title'),
                validator: (val) => val!.isEmpty ? 'Title is required' : null,
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Description', hintText: 'Enter product details...'),
                maxLines: 3,
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: _buildInputDecoration('Price (\$)', hintText: '0.00'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val!.isEmpty) return 'Price is required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageController,
                decoration: _buildInputDecoration('Image URL', hintText: 'https://example.com/image.jpg'),
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _stockController,
                decoration: _buildInputDecoration('Stock Quantity', hintText: '0'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val!.isEmpty) return 'Stock is required';
                  if (int.tryParse(val) == null) return 'Enter a whole number';
                  return null;
                },
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 30),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
                    ),
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'SAVE PRODUCT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newProduct = ProductModel(
                          id: widget.product?.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          price: double.parse(_priceController.text),
                          image: _imageController.text,
                          stock: int.parse(_stockController.text),
                        );

                        try {
                          if (widget.product == null) {
                            await provider.addProduct(newProduct);
                          } else {
                            await provider.updateProduct(newProduct);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.product == null
                                      ? 'Product added successfully!'
                                      : 'Product updated successfully!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _successColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.toString()}',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _errorColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              if (widget.product != null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: _errorColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}