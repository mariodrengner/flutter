import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthFooterLinks extends StatelessWidget {
  const AuthFooterLinks({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionPressed,
    this.secondaryActionText,
    this.onSecondaryActionPressed,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onActionPressed;
  final String? secondaryActionText;
  final Future<void> Function()? onSecondaryActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              promptText,
              style: GoogleFonts.robotoMono(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText,
                style: GoogleFonts.robotoMono(
                  color: const Color(0xFFe484ff),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (secondaryActionText != null && onSecondaryActionPressed != null)
          Column(
            children: [
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await onSecondaryActionPressed!();
                },
                child: Text(
                  secondaryActionText!,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
