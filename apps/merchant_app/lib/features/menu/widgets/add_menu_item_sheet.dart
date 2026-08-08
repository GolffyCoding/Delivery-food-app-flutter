import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/domain/models/menu_item_model.dart';
import 'package:merchant_app/features/menu/bloc/menu_bloc.dart';

class AddMenuItemSheet extends StatefulWidget {
  final String restaurantId;
  const AddMenuItemSheet({super.key, required this.restaurantId});

  @override
  State<AddMenuItemSheet> createState() => _AddMenuItemSheetState();
}

class _AddMenuItemSheetState extends State<AddMenuItemSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newItem = MenuItemModel(
        id: 'f_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        category: 'General',
      );
      context.read<MenuBloc>().add(AddMenuItem(widget.restaurantId, newItem));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add New Item', style: context.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(label: 'Item Name', controller: _nameCtrl, validator: Validators.required),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'Description', controller: _descCtrl, maxLines: 2),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Price (\$)',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.required(v, 'Price'),
                ),
                const SizedBox(height: 32),
                AppButton(text: 'Add to Menu', onPressed: _onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
