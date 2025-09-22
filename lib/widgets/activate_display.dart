import 'package:flutter/material.dart';

class ActivateDisplay extends StatelessWidget {
  const ActivateDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.document_scanner_outlined, size: 140, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'โปรดนำบัตรมาแสกน เพื่อเปิดใช้งาน',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
