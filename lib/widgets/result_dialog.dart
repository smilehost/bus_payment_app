import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

void showResultDialog(
  BuildContext context,
  String message, {
  bool isError = false,
  int? remainingTrips,
  int? cardType,
  DateTime? expireDate,
  VoidCallback? onDismiss,
}) {
  final unit = cardType == 0 ? 'รอบ' : 'บาท';
  final expireText = expireDate != null
      ? "หมดอายุ ${DateFormat('dd/MM/yyyy HH:mm').format(expireDate)}"
      : "";

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.close_rounded : Icons.check_circle_rounded,
              size: 96,
              color: isError ? Colors.redAccent : Colors.greenAccent,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isError ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 24),
            if (remainingTrips != null) ...[
              Text(
                "คงเหลือ $remainingTrips $unit",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                expireText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      if (onDismiss != null) onDismiss();
    }
  });
}
