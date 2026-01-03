import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../global_widgets/app_button.dart';
import '../../../global_widgets/custom_textfiled.dart';
import '../../../models/maintenance_record.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vehicle_provider.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final MaintenanceRecord? record;

  const AddMaintenanceScreen({super.key, this.record});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _firestoreService = FirestoreService();

  late MaintenanceType _selectedType;
  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.record?.type ?? MaintenanceType.oilChange;
    _selectedDate = widget.record?.date ?? DateTime.now();
    _mileageController.text = widget.record?.mileage.toString() ?? '';
    _costController.text = widget.record?.cost.toString() ?? '';
    _notesController.text = widget.record?.notes ?? '';
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    final userId = authProvider.currentUser?.uid ?? '';
    final vehicleId = vehicleProvider.selectedVehicle?.id ?? '';

    final record = MaintenanceRecord(
      id: widget.record?.id,
      vehicleId: vehicleId,
      userId: userId,
      type: _selectedType,
      date: _selectedDate,
      mileage: int.tryParse(_mileageController.text) ?? 0,
      cost: double.tryParse(_costController.text) ?? 0,
      notes: _notesController.text.trim(),
    );

    try {
      if (isEditing) {
        await _firestoreService.updateMaintenance(widget.record!.id!, record);
      } else {
        await _firestoreService.addMaintenance(record);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Record updated!' : 'Record added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save record'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Maintenance' : 'Add Maintenance'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintenance Type',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: MaintenanceType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = type);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.icon),
                          SizedBox(width: 4.w),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isSelected
                                  ? Colors.white
                                  : colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              Text(
                'Date',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(_selectedDate),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Mileage',
                inputHint: 'Current mileage',
                inputController: _mileageController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Cost (\$)',
                inputHint: 'Total cost',
                inputController: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Notes (Optional)',
                inputHint: 'Any additional notes',
                inputController: _notesController,
                isMultiline: true,
              ),
              SizedBox(height: 32.h),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      buttonText: isEditing ? 'Update Record' : 'Add Record',
                      onPressed: _handleSubmit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
