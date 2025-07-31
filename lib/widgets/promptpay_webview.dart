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

class PromptPayWebView extends StatelessWidget {
  final WebViewController? controller;
  final double zoomScale;

  const PromptPayWebView({
    super.key,
    required this.controller,
    this.zoomScale = 1.5, //ขยาย (1.0 = ปกติ)
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AbsorbPointer(
        // บล็อกการสัมผัสทั้งหมด
        child: controller != null
            ? Transform.scale(
                scale: zoomScale,
                alignment: Alignment.center,
                child: WebViewWidget(controller: controller!),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
