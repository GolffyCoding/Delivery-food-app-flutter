import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';
import 'package:merchant_app/features/dashboard/pages/merchant_home_page.dart';

class CreateRestaurantPage extends StatefulWidget {
  const CreateRestaurantPage({super.key});
  static const String route = '/setup-restaurant';

  @override
  State<CreateRestaurantPage> createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  // Defaults to a Bangkok coordinate — swap for a real map picker once
  // packages/location/packages/maps are wired into this app.
  final _latController = TextEditingController(text: '13.7563');
  final _lngController = TextEditingController(text: '100.5018');

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantSessionBloc, RestaurantSessionState>(
      listener: (context, state) {
        if (state is RestaurantSessionReady) {
          context.go(MerchantHomePage.route);
        } else if (state is RestaurantSessionError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: const AppAppBar(title: 'Set Up Your Restaurant'),
        body: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text('One last step before orders can come in.', style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline)),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(label: 'Restaurant Name', controller: _nameController, validator: Validators.required),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'Cuisine', hint: 'Italian, Thai, ...', controller: _cuisineController, validator: Validators.required),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone, validator: Validators.phone),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'Address', controller: _addressController, validator: Validators.required),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Latitude',
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: Validators.required,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: AppTextField(
                        label: 'Longitude',
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: Validators.required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Opening hours default to 09:00–21:00 every day — you can change this later in Store Settings.',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline),
                ),
                const SizedBox(height: 32),
                BlocBuilder<RestaurantSessionBloc, RestaurantSessionState>(
                  builder: (context, state) {
                    return AppButton(
                      text: 'Create Restaurant',
                      isLoading: state is RestaurantSessionCreating,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<RestaurantSessionBloc>().add(CreateRestaurant(
                                name: _nameController.text.trim(),
                                cuisine: _cuisineController.text.trim(),
                                phone: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                                latitude: double.tryParse(_latController.text.trim()) ?? 13.7563,
                                longitude: double.tryParse(_lngController.text.trim()) ?? 100.5018,
                              ));
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
