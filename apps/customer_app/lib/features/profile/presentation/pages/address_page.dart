import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/address/address_model.dart';
import 'package:customer_app/data/address/address_repository.dart';
import 'package:customer_app/di/injection.dart';

/// Lists saved addresses and lets the customer add a new one or pick one to
/// use for checkout. When opened from checkout (`context.push`), popping with
/// an [AddressModel] hands the selection straight back to the caller.
class AddressPage extends StatefulWidget {
  const AddressPage({super.key});
  static const String route = '/addresses';

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<AddressModel> _addresses = [];
  String? _defaultAddressId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = getIt<AddressRepository>();
    final addresses = await repository.list();
    final defaultAddress = await repository.getDefault();
    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _defaultAddressId = defaultAddress?.id;
      _isLoading = false;
    });
  }

  Future<void> _delete(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Remove "${address.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await getIt<AddressRepository>().delete(address.id);
    await _load();
  }

  Future<void> _setDefault(AddressModel address) async {
    await getIt<AddressRepository>().setDefault(address.id);
    await _load();
  }

  Future<void> _addAddress() async {
    final labelController = TextEditingController();
    final line1Controller = TextEditingController();
    final cityController = TextEditingController();
    final postalController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelController, decoration: const InputDecoration(labelText: 'Label (e.g. Home)')),
            TextField(controller: line1Controller, decoration: const InputDecoration(labelText: 'Street address')),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
            TextField(controller: postalController, decoration: const InputDecoration(labelText: 'Postal code')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true || line1Controller.text.trim().isEmpty) return;

    await getIt<AddressRepository>().add(
      label: labelController.text.trim().isEmpty ? 'Address' : labelController.text.trim(),
      line1: line1Controller.text.trim(),
      city: cityController.text.trim(),
      postalCode: postalController.text.trim(),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'My Addresses', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? const EmptyStateView(
                  icon: Icons.location_off_outlined,
                  title: 'No saved addresses',
                  subtitle: 'Add an address to get started',
                )
              : ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isDefault = address.id == _defaultAddressId;
                    return AppCard(
                      onTap: () => context.canPop() ? context.pop(address) : null,
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Row(
                          children: [
                            Text(address.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.brandAccent, borderRadius: AppRadius.smBorder),
                                child: const Text('Default', style: TextStyle(fontSize: 11, color: AppColors.brandPrimary)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(address.formatted),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') _delete(address);
                            if (value == 'default') _setDefault(address);
                          },
                          itemBuilder: (context) => [
                            if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as default')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(onPressed: _addAddress, child: const Icon(Icons.add)),
    );
  }
}
