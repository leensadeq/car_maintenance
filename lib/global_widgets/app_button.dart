import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const AppButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.blueAccent),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        onPressed: () {
          onPressed();
        },
      ),
    );
  }
}
