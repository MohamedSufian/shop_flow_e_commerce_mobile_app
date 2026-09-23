import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/address.dart';
import '../../logic/address/address_cubit.dart';
import 'address_card.dart';
import 'address_form_screen.dart';
import '../../core/l10n/l10n.dart';

/// Manage addresses. In [selectMode] tapping an address pops with it.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, this.selectMode = false, this.selectedId});

  final bool selectMode;
  final String? selectedId;

  static Future<Address?> pick(BuildContext context, {String? selectedId}) => Navigator.push<Address>(
        context,
        MaterialPageRoute(builder: (_) => AddressesScreen(selectMode: true, selectedId: selectedId)),
      );

  Future<void> _delete(BuildContext context, Address a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Tr('Delete address?'),
        content: Text('"${a.label}" — ${a.oneLine}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Tr('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Tr('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<AddressCubit>().delete(a.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, List<Address>>(
      builder: (context, list) {
        return Scaffold(
          appBar: AppBar(title: Text(context.tr(selectMode ? 'Select address' : 'My addresses'))),
          body: list.isEmpty
              ? EmptyView(
                  icon: Icons.location_off_outlined,
                  title: 'No saved addresses',
                  subtitle: 'Add an address to speed up checkout.',
                  action: SizedBox(
                    width: 200,
                    child: GradientButton(
                      label: 'Add address',
                      onPressed: () async {
                        final a = await AddressFormScreen.open(context);
                        if (a != null && selectMode && context.mounted) Navigator.pop(context, a);
                      },
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = list[i];
                    return AddressCard(
                      address: a,
                      selected: selectMode && a.id == selectedId,
                      onTap: selectMode ? () => Navigator.pop(context, a) : () => AddressFormScreen.open(context, address: a),
                      trailing: selectMode
                          ? null
                          : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onSelected: (v) {
                                switch (v) {
                                  case 'edit':
                                    AddressFormScreen.open(context, address: a);
                                  case 'default':
                                    context.read<AddressCubit>().setDefault(a.id);
                                  case 'delete':
                                    _delete(context, a);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Tr('Edit')),
                                if (!a.isDefault) const PopupMenuItem(value: 'default', child: Tr('Set as default')),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Tr('Delete', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                    );
                  },
                ),
          floatingActionButton: list.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final a = await AddressFormScreen.open(context);
                    if (a != null && selectMode && context.mounted) Navigator.pop(context, a);
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Tr('Add new'),
                ),
        );
      },
    );
  }
}
