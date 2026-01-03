import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../global_widgets/app_button.dart';
import '../../../global_widgets/custom_textfiled.dart';
import '../../../models/vehicle.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _nicknameController;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _nicknameController = TextEditingController(
      text: widget.vehicle?.nickname ?? '',
    );
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      userId: userId,
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      nickname: _nicknameController.text.trim(),
    );

    bool success;
    if (isEditing) {
      success = await vehicleProvider.updateVehicle(
        widget.vehicle!.id!,
        vehicle,
      );
    } else {
      success = await vehicleProvider.addVehicle(vehicle);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Vehicle updated!' : 'Vehicle added!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vehicleProvider.error ?? 'Failed to save vehicle'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 50.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              CustomTextField(
                inputName: 'Make',
                inputHint: 'e.g., Toyota, Ford, BMW',
                inputController: _makeController,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Model',
                inputHint: 'e.g., Camry, Mustang, M3',
                inputController: _modelController,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Year',
                inputHint: 'e.g., 2024',
                inputController: _yearController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Nickname (Optional)',
                inputHint: 'e.g., Daily Driver, Project Car',
                inputController: _nicknameController,
              ),
              SizedBox(height: 32.h),
              vehicleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      buttonText: isEditing ? 'Update Vehicle' : 'Add Vehicle',
                      onPressed: _handleSubmit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
