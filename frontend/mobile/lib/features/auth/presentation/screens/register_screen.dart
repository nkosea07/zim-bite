import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/zb_button.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

enum _RegisterRole { customer, vendor, rider }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bizNameController = TextEditingController();
  final _bizCityController = TextEditingController();
  bool _isLoading = false;
  _RegisterRole _role = _RegisterRole.customer;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bizNameController.dispose();
    _bizCityController.dispose();
    super.dispose();
  }

  String? get _apiRole {
    switch (_role) {
      case _RegisterRole.customer:
        return null;
      case _RegisterRole.vendor:
        return 'VENDOR_ADMIN';
      case _RegisterRole.rider:
        return 'RIDER';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().register(
            RegisterRequest(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              role: _apiRole,
            ),
          );
      if (mounted) {
        final label = _role == _RegisterRole.vendor
            ? 'Vendor'
            : _role == _RegisterRole.rider
                ? 'Rider'
                : 'Customer';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label account created! Please log in.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Role selector ───────────────────────────────
              Text(
                'I want to...',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_RegisterRole>(
                segments: const [
                  ButtonSegment(
                    value: _RegisterRole.customer,
                    label: Text('Order'),
                    icon: Icon(Icons.restaurant),
                  ),
                  ButtonSegment(
                    value: _RegisterRole.vendor,
                    label: Text('Sell'),
                    icon: Icon(Icons.storefront),
                  ),
                  ButtonSegment(
                    value: _RegisterRole.rider,
                    label: Text('Deliver'),
                    icon: Icon(Icons.delivery_dining),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
                style: SegmentedButton.styleFrom(
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: AppColors.brandOrange,
                ),
              ),
              const SizedBox(height: 24),

              // ── Common fields ───────────────────────────────
              TextFormField(
                key: const Key('register.firstName'),
                controller: _firstNameController,
                validator: (v) => Validators.required(v, 'First name'),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('register.lastName'),
                controller: _lastNameController,
                validator: (v) => Validators.required(v, 'Last name'),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('register.phoneNumber'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+263 7X XXX XXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('register.email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('register.password'),
                controller: _passwordController,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              // ── Vendor-specific fields ──────────────────────
              if (_role == _RegisterRole.vendor) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Business Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bizNameController,
                  validator: (v) => Validators.required(v, 'Business name'),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Business name',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bizCityController,
                  validator: (v) => Validators.required(v, 'City'),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'e.g. Harare',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll set up your menu and location after signing in.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGrey500,
                      ),
                ),
              ],

              const SizedBox(height: 32),
              ZbButton(
                label: _role == _RegisterRole.vendor
                    ? 'Create Vendor Account'
                    : _role == _RegisterRole.rider
                        ? 'Create Rider Account'
                        : 'Register',
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
