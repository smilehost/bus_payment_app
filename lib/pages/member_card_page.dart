// import 'dart:async';

// import 'package:flutter/material.dart';
// import '../services/card_service.dart';
// import 'package:flutter/services.dart';

// class MemberCardPage extends StatefulWidget {
//   const MemberCardPage({super.key});

//   @override
//   State<MemberCardPage> createState() => _MemberCardPageState();
// }

// class _MemberCardPageState extends State<MemberCardPage> {
//   int? remainingTrips;
//   String message = "สแกนด้วยบัตรสมาชิก\nSCAN MEMBER CARD";
//   Color messageColor = Colors.white;

//   void showMessage(String th, String en, {bool isError = false}) {
//     setState(() {
//       message = "$th\n$en";
//       messageColor = isError ? Colors.redAccent : Colors.greenAccent;
//     });

//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           message = "สแกนด้วยบัตรสมาชิก\nSCAN MEMBER CARD";
//           messageColor = Colors.white;
//         });
//       }
//     });
//   }

//   void openScanModal() {
//     final FocusNode _focusNode = FocusNode();
//     final TextEditingController _controller = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         bool isLoading = false;
//         String? scannedHash;

//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             Timer? debounceTimer;
//             Future<void> handleCardScan(String hash) async {
//               setStateDialog(() {
//                 isLoading = true;
//                 scannedHash = hash;
//               });

//               try {
//                 final result = await CardService.useCard(hash);

//                 if (result.status == 'success') {
//                   Navigator.of(context).pop(); // ✅ ปิด dialog ก่อน

//                   // ✅ อัปเดตค่าหลัก
//                   setState(() {
//                     remainingTrips = result.remainingBalance;
//                   });

//                   showMessage("ใช้บัตรสำเร็จ", "Card used successfully");

//                   // ✅ Reset หลัง 5 วิ
//                   Future.delayed(const Duration(seconds: 5), () {
//                     if (mounted) {
//                       setState(() {
//                         remainingTrips = null;
//                       });
//                     }
//                   });
//                 } else {
//                   Navigator.of(context).pop(); // ✅ ปิด modal

//                   // ✅ แสดง alert เตือน
//                   await showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: const Text('ไม่สามารถใช้งานบัตรได้'),
//                         content: Text(result.message),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             child: const Text('ตกลง'),
//                           ),
//                         ],
//                       );
//                     },
//                   );

//                   // ✅ แจ้งข้อความหลักหน้าจอด้วย
//                   showMessage(result.message, "", isError: true);
//                 }
//               } catch (e) {
//                 setStateDialog(() {
//                   isLoading = false;
//                 });
//                 showMessage(
//                   "เกิดข้อผิดพลาด",
//                   "An error occurred",
//                   isError: true,
//                 );
//               }
//             }

//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               FocusScope.of(context).requestFocus(_focusNode);
//             });
//             return AlertDialog(
//               backgroundColor: const Color(0xFF1B263B),
//               content: SizedBox(
//                 width: 400,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'ใช้งานบัตรสมาชิก',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     if (!isLoading)
//                       TextField(
//                         controller: _controller,
//                         focusNode: _focusNode,
//                         obscureText: true, //  ซ่อนค่า
//                         obscuringCharacter: '●', //  แสดงเป็น ● แทนตัวอักษรจริง
//                         keyboardType: TextInputType
//                             .none, //  ปิด soft keyboard แต่ยังรับ input จาก scanner ได้
//                         enableInteractiveSelection:
//                             false, //  ป้องกัน long press/select
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: 'รอสแกนบัตร...',
//                           hintStyle: TextStyle(color: Colors.grey.shade500),
//                           filled: true,
//                           fillColor: Colors.black12,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           final asciiOnly = value.replaceAll(
//                             RegExp(r'[^A-Za-z0-9]'),
//                             '',
//                           );

//                           debounceTimer?.cancel();

//                           debounceTimer = Timer(
//                             const Duration(milliseconds: 500),
//                             () {
//                               if (asciiOnly.isNotEmpty &&
//                                   asciiOnly.length >= 8) {
//                                 _controller.clear();
//                                 handleCardScan(asciiOnly);
//                               }
//                             },
//                           );
//                         },
//                       )
//                     else ...[
//                       const CircularProgressIndicator(),
//                       const SizedBox(height: 16),
//                       Text(
//                         // 'กำลังใช้งานบัตร...\n$scannedHash',
//                         'กำลังใช้งานบัตร...',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               actions: [
//                 if (!isLoading)
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text(
//                       'ยกเลิก',
//                       style: TextStyle(color: Colors.redAccent),
//                     ),
//                   ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _hideKeyboard(BuildContext context) {
//     FocusScope.of(
//       context,
//     ).requestFocus(FocusNode()); // เอา focus ออกจาก field ใด ๆ
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       color: const Color(0xFF0D1B2A),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               remainingTrips != null
//                   ? 'เหลือ $remainingTrips รอบ'
//                   : 'ยังไม่เริ่มใช้งานบัตร',
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.lightGreenAccent,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 20, color: messageColor),
//             ),
//             const SizedBox(height: 32),
//             GestureDetector(
//               onTap: openScanModal,
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white, width: 3),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: const [
//                     Icon(Icons.credit_card, size: 100, color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       'กดเพื่อใช้งานบัตร\nและวางบัตรที่จุดสแกน',
//                       style: TextStyle(fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
