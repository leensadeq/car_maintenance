import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.inputName,
    required this.inputHint,
    this.inputController,
    this.keyboardType,
    this.hasInfoIcon = false,
    this.isMultiline = false,
  });

  final String inputName;
  final String inputHint;
  final TextEditingController? inputController;
  final TextInputType? keyboardType;
  final bool hasInfoIcon;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    inputName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: colors.onSurface,
                    ),
                    softWrap: true,
                  ),
                ),
                if (hasInfoIcon)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: Icon(
                      Icons.info_outline,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          TextField(
            minLines: isMultiline ? 5 : 1,
            maxLines: isMultiline ? null : 1,
            controller: inputController,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: inputHint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
