import 'package:flutter/material.dart';

class FareDisplay extends StatelessWidget {
  final double? currentPrice;
  final String serial;
  final String? lastLoadedUrl;
  final int scanboxFunc;

  const FareDisplay({
    super.key,
    required this.currentPrice,
    required this.serial,
    required this.lastLoadedUrl,
    required this.scanboxFunc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // color: Colors.green,
        color: scanboxFunc == 0 ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            scanboxFunc == 0 ? 'ค่าโดยสาร' : 'ซื้อบัตรใหม่',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            scanboxFunc == 0 ? 'Fare' : 'Buy tickets',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🆕 AnimatedSwitcher ตรงนี้
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currentPrice != null
                        ? currentPrice!.toStringAsFixed(2)
                        : "Loading",
                    key: ValueKey(currentPrice), // 🧠 สำคัญ
                    style: const TextStyle(
                      fontSize: 100, // ยังคงกำหนดค่าเริ่มต้น
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '฿',
                style: TextStyle(
                  fontSize: 64,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  serial,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Powered By Bussing Transit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Text(
          //   lastLoadedUrl ?? '',
          //   style: const TextStyle(
          //     fontSize: 10,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.white70,
          //   ),
          // ),
        ],
      ),
    );
  }
}
