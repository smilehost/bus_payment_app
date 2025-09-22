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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.scanboxFunc == 0 ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.scanboxFunc == 0 ? 'ค่าโดยสาร' : 'ซื้อบัตรใหม่',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.scanboxFunc == 0 ? 'Fare' : 'Buy tickets',
            style: const TextStyle(
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
                    widget.currentPrice != null
                        ? widget.currentPrice!.toStringAsFixed(2)
                        : "Loading",
                    key: ValueKey(widget.currentPrice),
                    style: const TextStyle(
                      fontSize: 100,
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
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.serial,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  'Powered By Bussing Transit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),

                // ⬇️ Text ที่กดได้แทน FilledButton
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await VersionUpdater.checkAndMaybeUpdate(context);
                  },
                  child: Text(
                    _version.isNotEmpty ? 'v$_version • $_buildDate' : 'loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
