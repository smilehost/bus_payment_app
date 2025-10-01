import 'package:bus_payment_app/utils/version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FareDisplay extends StatefulWidget {
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
  State<FareDisplay> createState() => _FareDisplayState();
}

class _FareDisplayState extends State<FareDisplay> {
  String _version = '';
  static final String _buildDate = dotenv.env['APP_BUILD_DATE'] ?? '';

  // ⬇️ helper สำหรับสเกลฟอนต์ (อิงด้านสั้นของจอ)
  double _fs(
    BuildContext context,
    double base, {
    double min = .60,
    double max = 1.60,
  }) {
    final shortest = MediaQuery.of(context).size.shortestSide;

    // ใช้ baseline = 720 (tablet กลาง) → จอใหญ่กว่านี้จะ scale > 1
    // จอเล็กกว่า 720 จะลดลง แต่ไม่ต่ำกว่า min
    final scale = (shortest / 720).clamp(min, max);
    return base * scale;
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTicket = widget.scanboxFunc == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTicket ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TH title
          Text(
            isTicket ? 'ค่าโดยสาร' : 'ซื้อบัตรใหม่',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: _fs(context, 72), // เดิม 72
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // EN subtitle
          Text(
            isTicket ? 'Fare' : 'Buy tickets',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: _fs(context, 56), // เดิม 56
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          // ตัวเลขราคา + สัญลักษณ์สกุลเงิน
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    // ยังคง FittedBox เดิมไว้ ช่วย scale ลงถ้ายาว/ใหญ่เกิน
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.currentPrice != null
                          ? widget.currentPrice!.toStringAsFixed(2)
                          : "Loading",
                      key: ValueKey(widget.currentPrice),
                      style: TextStyle(
                        fontSize: _fs(context, 100), // เดิม 100
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '฿',
                  style: TextStyle(
                    fontSize: _fs(context, 64), // เดิม 64
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // มุมล่างขวา: serial / powered by / เวอร์ชัน
          SizedBox(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.serial,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: _fs(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Powered By Bussing Transit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: _fs(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await VersionUpdater.checkAndMaybeUpdate(context);
                    },
                    child: Text(
                      _version.isNotEmpty
                          ? 'v$_version • $_buildDate'
                          : 'loading...',
                      style: TextStyle(
                        fontSize: _fs(context, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
