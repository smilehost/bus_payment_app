import 'package:flutter/material.dart';

class FareDisplay extends StatelessWidget {
  final double? currentPrice;
  final String serial;
  final String? lastLoadedUrl;

  const FareDisplay({
    super.key,
    required this.currentPrice,
    required this.serial,
    required this.lastLoadedUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ค่าโดยสาร',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Fare',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // หรือ left/right ตามต้องการ
            crossAxisAlignment:
                CrossAxisAlignment.center, // ให้ไอคอนอยู่แนวเดียวกับเลข
            children: [
              Text(
                currentPrice != null
                    ? currentPrice!.toStringAsFixed(2)
                    : "Loading",
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '฿',
                style: TextStyle(
                  fontSize: 64, // ปรับขนาดให้สมดุลกับตัวเลข
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          // Expanded(
          const Spacer(), //ดันลงล่างสุด
          Align(
            alignment: Alignment.bottomRight,
            // child: Padding(
            // padding: const EdgeInsets.all(16), // เพิ่มระยะห่างจากขอบเล็กน้อย
            child: Text(
              serial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            // ),
          ),
        ],
      ),
    );
  }
}
