// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PromptPayPage extends StatefulWidget {
//   const PromptPayPage({super.key});

//   @override
//   State<PromptPayPage> createState() => _PromptPayPageState();
// }

// class _PromptPayPageState extends State<PromptPayPage> {
//   WebViewController? _qrController;
//   WebViewController? _adsController;

//   @override
//   void initState() {
//     super.initState();

//     final qrCtrl = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(
//         Uri.parse('https://tts.bussing.app/t20/?scanb_sn=B44T020C02000119'),
//       );

//     final adsCtrl = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse('https://bussing.app/'));
//     // ..loadRequest(
//     //   Uri.parse('https://bussing.app/'), // เปลี่ยนลิงก์โฆษณาที่เหมาะสม
//     // );

//     setState(() {
//       _qrController = qrCtrl;
//       _adsController = adsCtrl;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: const Color(0xFF0D1B2A),
//       // color: const Color.fromARGB(255, 33, 193, 169),
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'ค่าโดยสาร Fare',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 // const SizedBox(height: 5),
//                 const Text(
//                   '30.00',
//                   style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
//                 ),
//                 // const SizedBox(height: 16),
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: _qrController != null
//                         ? WebViewWidget(controller: _qrController!)
//                         : const Center(child: CircularProgressIndicator()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             flex: 4,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: _adsController != null
//                   ? WebViewWidget(controller: _adsController!)
//                   : const Center(child: CircularProgressIndicator()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
