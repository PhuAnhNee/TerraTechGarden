import 'package:flutter/material.dart';

class OtpDialog extends StatelessWidget {
  final String email;
  final Function(String) onVerify;
  final List<TextEditingController> otpControllers;
  final bool isLoading;

  const OtpDialog({
    Key? key,
    required this.email,
    required this.onVerify,
    required this.otpControllers,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your code was sent to you via email'),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 40,
                child: TextFormField(
                  controller: otpControllers[index],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Didn't receive code? Request again"),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  final otp = otpControllers.map((c) => c.text).join();
                  onVerify(otp);
                },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white))
              : const Text('Verify'),
        ),
      ],
    );
  }
}
