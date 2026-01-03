import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../global_widgets/app_button.dart';
import '../../../global_widgets/custom_textfiled.dart';
import '../../../models/modification.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vehicle_provider.dart';

class AddModScreen extends StatefulWidget {
  final Modification? mod;

  const AddModScreen({super.key, this.mod});

  @override
  State<AddModScreen> createState() => _AddModScreenState();
}

class _AddModScreenState extends State<AddModScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _firestoreService = FirestoreService();

  late ModCategory _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get isEditing => widget.mod != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.mod?.category ?? ModCategory.turbo;
    _selectedDate = widget.mod?.date ?? DateTime.now();
    _nameController.text = widget.mod?.name ?? '';
    _costController.text = widget.mod?.cost.toString() ?? '';
    _notesController.text = widget.mod?.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final mod = Modification(
      id: widget.mod?.id,
      vehicleId: vehicleId,
      userId: userId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      date: _selectedDate,
      cost: double.tryParse(_costController.text) ?? 0,
      notes: _notesController.text.trim(),
    );

    try {
      if (isEditing) {
        await _firestoreService.updateModification(widget.mod!.id!, mod);
      } else {
        await _firestoreService.addModification(mod);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Modification updated!' : 'Modification added!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save modification'),
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
        title: Text(isEditing ? 'Edit Modification' : 'Add Modification'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                inputName: 'Modification Name',
                inputHint: 'e.g., Garrett GTX3076R Turbo',
                inputController: _nameController,
              ),
              SizedBox(height: 24.h),
              Text(
                'Category',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: ModCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.tertiary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? colors.tertiary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.icon),
                          SizedBox(width: 4.w),
                          Text(
                            category.displayName,
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
                'Installation Date',
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
                        color: colors.tertiary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Cost (\$)',
                inputHint: 'Total cost including installation',
                inputController: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                inputName: 'Notes (Optional)',
                inputHint: 'Part numbers, shop name, etc.',
                inputController: _notesController,
                isMultiline: true,
              ),
              SizedBox(height: 32.h),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      buttonText: isEditing
                          ? 'Update Modification'
                          : 'Add Modification',
                      onPressed: _handleSubmit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
