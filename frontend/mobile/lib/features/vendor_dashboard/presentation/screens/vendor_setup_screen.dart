import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/vendor_dashboard_bloc.dart';

class VendorSetupScreen extends StatefulWidget {
  final void Function(String vendorId) onCreated;
  const VendorSetupScreen({super.key, required this.onCreated});

  @override
  State<VendorSetupScreen> createState() => _VendorSetupScreenState();
}

class _VendorSetupScreenState extends State<VendorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Harare');
  final _latController = TextEditingController(text: '-17.8252');
  final _lngController = TextEditingController(text: '31.0335');

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<VendorDashboardBloc>().add(CreateVendorProfile(
          ownerUserId: '', // filled by auth token on backend
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          city: _cityController.text.trim(),
          latitude: double.tryParse(_latController.text.trim()) ?? -17.8252,
          longitude: double.tryParse(_lngController.text.trim()) ?? 31.0335,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Complete Vendor Setup',
          style: TextStyle(
            color: AppColors.warmGrey900,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocListener<VendorDashboardBloc, VendorDashboardState>(
        listener: (context, state) {
          if (state is VendorCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vendor profile created!')),
            );
            widget.onCreated(state.vendorId);
          }
          if (state is VendorDashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
          builder: (context, state) {
            final isLoading = state is VendorDashboardLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set up your vendor profile before you can start selling on ZimBite.',
                      style: TextStyle(
                        color: AppColors.warmGrey500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildField(
                      controller: _nameController,
                      label: 'Business Name',
                      hint: "e.g. Tino's Kitchen",
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _descController,
                      label: 'Description (optional)',
                      hint: 'What makes your breakfast special?',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: '+263771234567',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Harare',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _latController,
                            label: 'Latitude',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _lngController,
                            label: 'Longitude',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Vendor Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
