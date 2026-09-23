import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/address.dart';
import '../../logic/address/address_cubit.dart';
import '../../logic/auth/auth_cubit.dart';
import 'address_card.dart';
import '../../core/l10n/l10n.dart';

/// Add or edit an address. Pops with the saved [Address].
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  static Future<Address?> open(BuildContext context, {Address? address}) =>
      Navigator.push<Address>(context, MaterialPageRoute(builder: (_) => AddressFormScreen(address: address)));

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.address?.fullName ?? context.read<AuthCubit>().state.user?.name,
  );
  late final _phone = TextEditingController(text: widget.address?.phone);
  late final _street = TextEditingController(text: widget.address?.street);
  late final _city = TextEditingController(text: widget.address?.city);
  late final _country = TextEditingController(text: widget.address?.country ?? 'Palestine');
  late String _label = widget.address?.label ?? 'Home';
  late bool _default = widget.address?.isDefault ?? context.read<AddressCubit>().state.isEmpty;

  bool get _editing => widget.address != null;

  @override
  void dispose() {
    for (final c in [_name, _phone, _street, _city, _country]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final address = Address(
      id: widget.address?.id ?? AddressCubit.newId(),
      label: _label,
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      street: _street.text.trim(),
      city: _city.text.trim(),
      country: _country.text.trim(),
      isDefault: _default,
    );
    context.read<AddressCubit>().save(address);
    showAppSnack(context, _editing ? 'Address updated' : 'Address added', icon: Icons.check_circle_rounded);
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr(_editing ? 'Edit address' : 'New address'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Tr('Save as', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: ['Home', 'Work', 'Other'].map((l) {
                final sel = l == _label;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _label = l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: sel ? AppColors.primaryGradient : null,
                        color: sel ? null : scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sel ? Colors.transparent : scheme.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(addressIcon(l), size: 18, color: sel ? Colors.white : scheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            context.tr(l),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'Full name',
              hint: 'Recipient name',
              icon: Icons.person_outline_rounded,
              controller: _name,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone number',
              hint: '+970 59 123 4567',
              icon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7 ? 'Enter a valid phone' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Street address',
              hint: 'Street, building, apartment',
              icon: Icons.signpost_outlined,
              controller: _street,
              validator: Validators.required('Street'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'City',
                    hint: 'Gaza',
                    icon: Icons.location_city_outlined,
                    controller: _city,
                    validator: Validators.required('City'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Country',
                    hint: 'Country',
                    icon: Icons.public_rounded,
                    controller: _country,
                    validator: Validators.required('Country'),
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outline),
              ),
              child: SwitchListTile(
                value: _default,
                onChanged: (v) => setState(() => _default = v),
                title: const Tr('Set as default address', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Tr('Used automatically at checkout'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(label: _editing ? 'Save changes' : 'Save address', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
