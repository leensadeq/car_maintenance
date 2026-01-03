import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/maintenance_record.dart';
import '../../../models/modification.dart';
import '../../../models/vehicle.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../maintenance/screens/maintenance_screen.dart';
import '../../mods/screens/mods_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardTab(),
    VehiclesScreen(),
    MaintenanceScreen(),
    ModsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId != null) {
      context.read<VehicleProvider>().loadVehicles(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Mods',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(fontSize: 14.sp, color: colors.onSurfaceVariant),
            ),
            Text(
              authProvider.currentUser?.displayName ?? 'User',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await vehicleProvider.loadVehicles(userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleSelector(),
              SizedBox(height: 24.h),
              _StatsSection(),
              SizedBox(height: 24.h),
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _RecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicleProvider = context.watch<VehicleProvider>();
    final vehicles = vehicleProvider.vehicles;
    final selectedVehicle = vehicleProvider.selectedVehicle;

    if (vehicles.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 40.sp, color: colors.primary),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No vehicles yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Add your first vehicle to get started',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Vehicle',
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
              PopupMenuButton<Vehicle>(
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                onSelected: (vehicle) {
                  vehicleProvider.selectVehicle(vehicle);
                },
                itemBuilder: (context) => vehicles
                    .map(
                      (v) =>
                          PopupMenuItem(value: v, child: Text(v.displayName)),
                    )
                    .toList(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.directions_car, size: 48.sp, color: Colors.white),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedVehicle?.displayName ?? 'Select a vehicle',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (selectedVehicle != null)
                      Text(
                        '${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicleProvider = context.watch<VehicleProvider>();
    final selectedVehicle = vehicleProvider.selectedVehicle;

    if (selectedVehicle == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: vehicleProvider.getVehicleStats(selectedVehicle.id!),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.build,
                label: 'Maintenance',
                value: '${stats['maintenanceCount'] ?? 0}',
                color: colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.speed,
                label: 'Mods',
                value: '${stats['modsCount'] ?? 0}',
                color: colors.tertiary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money,
                label: 'Total',
                value: '\$${(stats['totalCost'] ?? 0).toStringAsFixed(0)}',
                color: colors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicleProvider = context.watch<VehicleProvider>();
    final selectedVehicle = vehicleProvider.selectedVehicle;

    if (selectedVehicle == null) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'Add a vehicle to see activity',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      );
    }

    return StreamBuilder<List<MaintenanceRecord>>(
      stream: _firestoreService.getMaintenanceStream(selectedVehicle.id!),
      builder: (context, maintenanceSnapshot) {
        return StreamBuilder<List<Modification>>(
          stream: _firestoreService.getModificationsStream(selectedVehicle.id!),
          builder: (context, modsSnapshot) {
            final maintenance = maintenanceSnapshot.data ?? [];
            final mods = modsSnapshot.data ?? [];

            if (maintenance.isEmpty && mods.isEmpty) {
              return Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48.sp,
                        color: colors.onSurfaceVariant,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No activity yet',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            final List<dynamic> allItems = [...maintenance, ...mods];
            allItems.sort((a, b) {
              final dateA = a is MaintenanceRecord
                  ? a.date
                  : (a as Modification).date;
              final dateB = b is MaintenanceRecord
                  ? b.date
                  : (b as Modification).date;
              return dateB.compareTo(dateA);
            });

            return Column(
              children: allItems.take(5).map((item) {
                if (item is MaintenanceRecord) {
                  return _ActivityTile(
                    icon: Icons.build,
                    title: item.type.displayName,
                    subtitle:
                        '${item.mileage} miles • \$${item.cost.toStringAsFixed(0)}',
                    date: item.date,
                    color: colors.primary,
                  );
                } else {
                  final mod = item as Modification;
                  return _ActivityTile(
                    icon: Icons.speed,
                    title: mod.name,
                    subtitle:
                        '${mod.category.displayName} • \$${mod.cost.toStringAsFixed(0)}',
                    date: mod.date,
                    color: colors.tertiary,
                  );
                }
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime date;
  final Color color;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(date),
            style: TextStyle(fontSize: 12.sp, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}
