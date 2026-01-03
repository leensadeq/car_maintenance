import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/modification.dart';
import '../../../providers/vehicle_provider.dart';
import 'add_mod_screen.dart';

class ModsScreen extends StatelessWidget {
  const ModsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicleProvider = context.watch<VehicleProvider>();
    final selectedVehicle = vehicleProvider.selectedVehicle;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifications'),
        actions: [
          if (selectedVehicle != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddModScreen()),
                );
              },
            ),
        ],
      ),
      body: selectedVehicle == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 80.sp,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No vehicle selected',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select or add a vehicle first',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  color: colors.tertiaryContainer,
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: colors.tertiary),
                      SizedBox(width: 12.w),
                      Text(
                        selectedVehicle.displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: colors.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Modification>>(
                    stream: firestoreService.getModificationsStream(
                      selectedVehicle.id!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final mods = snapshot.data ?? [];

                      if (mods.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.speed_outlined,
                                size: 80.sp,
                                color: colors.onSurfaceVariant,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No modifications yet',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Track your performance upgrades',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddModScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Modification'),
                              ),
                            ],
                          ),
                        );
                      }

                      final groupedMods = <ModCategory, List<Modification>>{};
                      for (final mod in mods) {
                        groupedMods
                            .putIfAbsent(mod.category, () => [])
                            .add(mod);
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: mods.length,
                        itemBuilder: (context, index) {
                          final mod = mods[index];
                          return _ModCard(
                            mod: mod,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddModScreen(mod: mod),
                                ),
                              );
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Modification'),
                                  content: const Text(
                                    'Are you sure you want to delete this modification?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await firestoreService.deleteModification(
                                  mod.id!,
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: selectedVehicle != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddModScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ModCard extends StatelessWidget {
  final Modification mod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModCard({
    required this.mod,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  mod.category.icon,
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mod.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${mod.category.displayName} • ${dateFormat.format(mod.date)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (mod.notes.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        mod.notes,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${mod.cost.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.tertiary,
                  ),
                ),
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
