import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/data/address/address_model.dart';
import 'package:customer_app/data/address/address_repository.dart';
import 'package:customer_app/data/coupon/coupon_repository.dart';
import 'package:customer_app/data/order/order_repository.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/domain/models/coupon_model.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/order/presentation/pages/order_tracking_page.dart';
import 'package:customer_app/features/profile/presentation/pages/address_page.dart';

enum _PaymentMethod {
  cash('cash', 'Cash on Delivery', Icons.payments_outlined),
  card('card', 'Credit / Debit Card', Icons.credit_card_outlined);

  const _PaymentMethod(this.backendValue, this.label, this.icon);
  final String backendValue;
  final String label;
  final IconData icon;
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  static const String route = '/checkout';

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Generated once per checkout attempt (not per tap) so that a network
  // retry or a double-tap reuses the same key — the backend then rejects
  // the duplicate instead of creating two orders.
  final String _idempotencyKey = const Uuid().v4();
  bool _isPlacingOrder = false;
  bool _isLoadingAddress = true;
  AddressModel? _address;
  _PaymentMethod _paymentMethod = _PaymentMethod.cash;
  CouponPreview? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final address = await getIt<AddressRepository>().getDefault();
    if (!mounted) return;
    setState(() {
      _address = address;
      _isLoadingAddress = false;
    });
  }

  Future<void> _pickAddress(BuildContext context) async {
    final result = await context.push<AddressModel>(AddressPage.route);
    if (result != null && mounted) {
      setState(() => _address = result);
    }
  }

  Future<void> _pickPaymentMethod(BuildContext context) async {
    final selected = await showModalBottomSheet<_PaymentMethod>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final method in _PaymentMethod.values)
              ListTile(
                leading: Icon(method.icon),
                title: Text(method.label),
                trailing: method == _paymentMethod ? const Icon(Icons.check_circle, color: AppColors.brandPrimary) : null,
                onTap: () => Navigator.of(sheetContext).pop(method),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _paymentMethod = selected);
    }
  }

  Future<void> _openCouponPicker(BuildContext context, CartLoaded cart) async {
    final listResult = await getIt<CouponRepository>().listActive();
    if (!context.mounted) return;
    final coupons = listResult.when(success: (c) => c, failure: (_) => const <CouponModel>[]);

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CouponPickerSheet(
        coupons: coupons,
        subtotal: cart.total,
        onApplied: (preview) => setState(() => _appliedCoupon = preview),
      ),
    );
  }

  double _discountFor(CartLoaded cart) {
    final coupon = _appliedCoupon;
    if (coupon == null || !coupon.eligible) return 0;
    // A coupon validated against an earlier subtotal can become invalid if
    // the cart changes afterward (e.g. below min purchase again) — the
    // server re-validates for real at order creation regardless, but don't
    // keep showing a discount here past the point it stopped applying.
    if (cart.total < coupon.minPurchase) return 0;
    return coupon.discount;
  }

  // The single most-requested fix from real user reviews of the app this
  // project is modeled on: an accidental tap (or a mis-tap while holding the
  // phone) went straight to a charged order with no way to back out. A
  // confirmation step here is a deliberate extra tap in exchange for making
  // "I didn't mean to order that" structurally impossible.
  Future<void> _confirmAndPlaceOrder(BuildContext context, CartLoaded cart) async {
    if (cart.items.isEmpty || _isPlacingOrder) return;
    final address = _address;
    if (address == null) {
      context.showSnackBar('Please add a delivery address first.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Your Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in cart.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${item.quantity}x ${item.food.name}'),
              ),
            const Divider(height: 24),
            Text('Deliver to: ${address.formatted}', style: context.textTheme.bodySmall),
            Text('Pay with: ${_paymentMethod.label}', style: context.textTheme.bodySmall),
            if (_discountFor(cart) > 0) Text('Coupon: -\$${_discountFor(cart).toStringAsFixed(2)}', style: context.textTheme.bodySmall?.copyWith(color: AppColors.success)),
            const SizedBox(height: 8),
            Text('Total: \$${(cart.total - _discountFor(cart)).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Confirm & Pay')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _submitOrder(context, cart, address);
  }

  Future<void> _submitOrder(BuildContext context, CartLoaded cart, AddressModel address) async {
    setState(() => _isPlacingOrder = true);

    final result = await getIt<OrderRepository>().createOrder(
      restaurantId: cart.items.first.food.restaurantId,
      items: cart.items,
      paymentMethod: _paymentMethod.backendValue,
      deliveryAddress: address.formatted,
      deliveryLat: address.lat,
      deliveryLng: address.lng,
      couponCode: _discountFor(cart) > 0 ? _appliedCoupon?.code : null,
      idempotencyKey: _idempotencyKey,
    );

    if (!context.mounted) return;
    setState(() => _isPlacingOrder = false);

    result.when(
      success: (order) {
        context.read<CartBloc>().add(const CartClear());
        context.go('${OrderTrackingPage.route}/${order.id}');
      },
      failure: (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartLoaded>(
      builder: (context, state) {
        return Scaffold(
          appBar: const AppAppBar(title: 'Checkout', showBackButton: true),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                text: 'Place Order  •  \$${(state.total - _discountFor(state)).toStringAsFixed(2)}',
                isLoading: _isPlacingOrder,
                onPressed: _address == null ? null : () => _confirmAndPlaceOrder(context, state),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  onTap: () => _pickAddress(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.brandAccent, borderRadius: AppRadius.mdBorder),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.brandPrimary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery Address', style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.outline)),
                            const SizedBox(height: 4),
                            if (_isLoadingAddress)
                              const Text('Loading…')
                            else if (_address == null)
                              const Text('Add a delivery address', style: TextStyle(fontWeight: FontWeight.w600))
                            else ...[
                              Text(_address!.line1, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${_address!.city} ${_address!.postalCode}',
                                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.outline)),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Payment Method', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  onTap: () => _pickPaymentMethod(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: AppRadius.mdBorder),
                        child: Icon(_paymentMethod.icon, color: AppColors.info),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(_paymentMethod.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Coupon', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  onTap: () => _openCouponPicker(context, state),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: AppRadius.mdBorder),
                        child: const Icon(Icons.local_offer_outlined, color: AppColors.success),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _appliedCoupon != null && _discountFor(state) > 0 ? '${_appliedCoupon!.code} applied (-\$${_discountFor(state).toStringAsFixed(2)})' : 'Apply a coupon',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Order Summary', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    children: [
                      ...state.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity}x ${item.food.name}'),
                              Text('\$${item.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }),
                      if (_discountFor(state) > 0) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Coupon discount'),
                            Text('-\$${_discountFor(state).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CouponPickerSheet extends StatefulWidget {
  final List<CouponModel> coupons;
  final double subtotal;
  final ValueChanged<CouponPreview> onApplied;

  const _CouponPickerSheet({required this.coupons, required this.subtotal, required this.onApplied});

  @override
  State<_CouponPickerSheet> createState() => _CouponPickerSheetState();
}

class _CouponPickerSheetState extends State<_CouponPickerSheet> {
  String? _validatingCode;
  final Map<String, CouponPreview> _previews = {};

  Future<void> _tryCoupon(CouponModel coupon) async {
    setState(() => _validatingCode = coupon.code);
    final result = await getIt<CouponRepository>().validate(coupon.code, widget.subtotal);
    if (!mounted) return;
    setState(() => _validatingCode = null);

    result.when(
      success: (preview) {
        setState(() => _previews[coupon.code] = preview);
        if (preview.eligible) {
          widget.onApplied(preview);
          Navigator.of(context).pop();
        }
        // If not eligible, stay on the sheet and show the reason + min
        // purchase inline (below) — this is the whole point: the customer
        // sees exactly why *before* getting to the payment screen.
      },
      failure: (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Coupons', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (widget.coupons.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text('No coupons available right now', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline)),
              )
            else
              for (final coupon in widget.coupons) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_offer_outlined, color: AppColors.success),
                  title: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${coupon.summary}${coupon.minPurchase > 0 ? ' · Min. order \$${coupon.minPurchase.toStringAsFixed(0)}' : ''}'),
                  trailing: _validatingCode == coupon.code
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(onPressed: () => _tryCoupon(coupon), child: const Text('Apply')),
                ),
                if (_previews[coupon.code]?.eligible == false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      widget.subtotal < coupon.minPurchase
                          ? 'Add \$${(coupon.minPurchase - widget.subtotal).toStringAsFixed(2)} more to use this coupon'
                          : _previews[coupon.code]!.reason ?? 'Not eligible',
                      style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}
