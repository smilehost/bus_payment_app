// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PromptPayWebView extends StatelessWidget {
//   final WebViewController? controller;

//   const PromptPayWebView({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: controller != null
//           ? WebViewWidget(controller: controller!)
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PromptPayWebView extends StatefulWidget {
  final WebViewController controller;
  final String url; // 🆕 URL ของ WebView
  final double zoomScale;

  const PromptPayWebView({
    super.key,
    required this.controller,
    required this.url,
    this.zoomScale = 1.0,
  });

  @override
  State<PromptPayWebView> createState() => _PromptPayWebViewState();
}

class _PromptPayWebViewState extends State<PromptPayWebView> {
  String? _lastLoadedUrl;
  bool isWebViewReady = false; // 🆕 ใช้ควบคุม animation

  @override
  void initState() {
    super.initState();
    _loadWebView(widget.url);
  }

  @override
  void didUpdateWidget(covariant PromptPayWebView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_lastLoadedUrl != widget.url) {
      setState(() {
        isWebViewReady = false; // 🆕 ซ่อน WebView ก่อนโหลดใหม่
      });
      _loadWebView(widget.url);
    }
  }

  void _loadWebView(String url) async {
    await widget.controller.loadRequest(Uri.parse(url));
    _lastLoadedUrl = url;

    // รอให้โหลดเสร็จแบบ delay เพื่อให้ animation ลื่น
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        isWebViewReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isWebViewReady
            ? Transform.scale(
                scale: widget.zoomScale,
                alignment: Alignment.center,
                child: AbsorbPointer(
                  // ✅ ครอบตรงนี้
                  child: WebViewWidget(
                    key: ValueKey(_lastLoadedUrl),
                    controller: widget.controller,
                  ),
                ),
              )
            : const SizedBox(
                key: ValueKey("loading"),
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'กำลังโหลด QR Code...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
