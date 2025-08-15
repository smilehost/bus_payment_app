// ส่วน import library และ widgets ที่เราแยกไว้
import 'dart:async';
import 'dart:io';

import 'package:bus_payment_app/models/card_use_response.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../services/card_service.dart'; // เรียกใช้งาน API สำหรับบัตร
import '../services/fare_service.dart'; // ใช้โหลดข้อมูล scanbox
import '../utils/device_name_util.dart'; // สำหรับดึงชื่ออุปกรณ์
import '../widgets/fare_display.dart'; // UI แสดงค่าโดยสาร
import '../widgets/promptpay_webview.dart'; // UI แสดง QR code
import '../widgets/result_dialog.dart'; // Dialog แสดงผลการใช้บัตร
import 'package:geolocator/geolocator.dart';
import '../models/card_group.dart';

class UnifiedFarePage extends StatefulWidget {
  const UnifiedFarePage({super.key});

  @override
  State<UnifiedFarePage> createState() => _UnifiedFarePageState();
}

class _UnifiedFarePageState extends State<UnifiedFarePage> {
  WebViewController? _qrController; // ตัวควบคุม WebView QR
  int? remainingTrips; // จำนวนรอบการใช้งานที่เหลือของบัตร
  int? cardType; // ประเภทของบัตร 0 รอบ 1 เงิน
  DateTime? expireDate; // ประเภทของบัตร 0 รอบ 1 เงิน
  final FocusNode _focusNode =
      FocusNode(); // ใช้จับการพิมพ์จาก keyboard scanner
  final TextEditingController _controller =
      TextEditingController(); // รับค่าจาก scanner
  Timer? debounceTimer; // กัน input ซ้ำตอนสแกน
  Timer? serialTimer; // Timer สำหรับ polling ข้อมูล Scanbox
  Timer? cooldownTimer; // Cooldown timer ป้องกันการยิงซ้ำ

  String serial = "Loading..."; // serial ของเครื่อง
  bool isLoading = false; // ใช้แสดง loading overlay ตอนกำลังเช็คบัตร
  bool isCooldown = false; // สถานะ cooldown หลังสแกน
  int cooldownSeconds = 0; // ตัวแปรแสดงวินาที cooldown ที่เหลือ

  double? currentFare; // 🆕 ค่าโดยสารจาก scanbox
  double? newCardPrice; // 🆕 ราคาซื้อบัตรใหม่จาก activate
  int? cardGroupId;
  String promptpayUrl = ""; // URL ของ QR PromptPay
  int scanboxComId = 0;
  int scanboxBusId = 0;
  int scanboxBusroundLatest = 0;
  int scanboxFunc = 0;
  int scanboxPaymentMethodId = 0;
  String? _lastLoadedUrl;

  Timer? scanTimeoutTimer;

  @override
  void initState() {
    super.initState();

    _qrController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    fetchModel();
    fetchSerial();
    startScanboxPolling();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void startScanboxPolling() {
    // ดึงข้อมูล Scanbox ซ้ำทุก 5 วินาที
    serialTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadScanboxData();
    });
  }

  Future<void> fetchSerial() async {
    // ดึง serial ของอุปกรณ์ Android หรือ iOS
    final deviceInfo = DeviceInfoPlugin();
    String? newSerial;

    if (Platform.isAndroid) {
      final deviceName = await DeviceNameUtil.getDeviceName();
      newSerial = deviceName;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      newSerial = iosInfo.identifierForVendor;
    }

    // ถ้า serial เปลี่ยน ให้โหลดข้อมูลใหม่
    if (newSerial != null && newSerial != serial) {
      setState(() {
        serial = newSerial!;
      });
      loadScanboxData(); // โหลดข้อมูลทันทีเมื่อได้ serial
    }
  }

  Future<void> fetchModel() async {
    // แค่แสดงชื่อเครื่องใน console (ไม่ใช้ใน UI)
    final deviceName = await DeviceNameUtil.getDeviceName();
    print("📱 ชื่อเครื่อง: $deviceName");
  }

  // 🆕 แยกการเลือกว่าจะใช้ราคาใด
  double getPriceToUse() {
    if (scanboxFunc == 1 && newCardPrice != null) {
      return newCardPrice!;
    } else if (scanboxFunc == 0 && currentFare != null) {
      return currentFare!;
    } else {
      return 0.0;
    }
  }

  Future<void> loadScanboxData() async {
    // โหลดข้อมูล scanbox จาก serial
    final scanbox = await ScanboxService.getScanboxBySerial(serial); // from API

    if (scanbox != null) {
      // เช็คราคาว่ามีการเปลี่ยนแปลงหรือไม่
      final isPriceChanged = scanbox.currentPrice != currentFare; // 🆕
      final isModeChanged = scanbox.scanboxFunc != scanboxFunc;

      if (isPriceChanged || isModeChanged) {
        setState(() {
          currentFare = scanbox.currentPrice; // 🆕 ใช้ currentFare
          promptpayUrl = scanbox.promptpayUrl;
          scanboxComId = scanbox.comId;
          scanboxBusId = scanbox.scanboxBusId;
          scanboxBusroundLatest = scanbox.scanboxBusroundLatest;
          scanboxFunc = scanbox.scanboxFunc;
          newCardPrice = null; // 🆕 reset บัตรใหม่เมื่อเปลี่ยนโหมด
          scanboxPaymentMethodId = scanbox.scanboxPaymentMethodId;
        });

        if (_qrController != null && promptpayUrl.isNotEmpty) {
          final uri = Uri.parse(promptpayUrl);
          final updatedUri = uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              'price': getPriceToUse().toStringAsFixed(2), // 🆕
              'device_id': serial,
              'com_id': scanboxComId.toString(),
              'busno': scanboxBusId.toString(),
              'busround': scanboxBusroundLatest.toString(),
              'method_id': scanboxPaymentMethodId.toString(),
              'scanbox_func': scanboxFunc.toString(),
              'cardgroup_id': cardGroupId.toString(),
            },
          );

          final newUrl = updatedUri.toString();
          if (_lastLoadedUrl != newUrl) {
            _qrController!.loadRequest(updatedUri);
            _lastLoadedUrl = newUrl;
          }
        }
      } else {
        print("ℹ️ Price not changed. No reload.");
      }
    } else {
      print("❌ ไม่พบข้อมูล Scanbox");
    }
  }

  void startCooldown() {
    //โหลดกันยิงซ้ำของ card
    setState(() {
      isCooldown = true;
      cooldownSeconds = 1;
    });

    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => isCooldown = false);
      } else {
        setState(() => cooldownSeconds--);
      }
    });
  }

  Future<void> handleCardScan(String hash) async {
    if (isLoading || isCooldown) return;

    setState(() => isLoading = true);

    try {
      final position = await getPositionWithFallback();
      final lat = position.latitude.toString();
      final long = position.longitude.toString();

      if (scanboxFunc == 1) {
        // 🔸 เคส ซื้อบัตรใหม่
        final result = await CardService.activateCard(
          hash,
          scanboxBusroundLatest,
        );

        if (result['status'] == 'success') {
          final CardGroup group = result['data'];
          setState(() {
            newCardPrice = group.cardGroupPrice;
            cardGroupId = group.cardGroupId;
          });

          // 🆕 trigger reload URL หลังจากได้ราคาใหม่
          if (_qrController != null && promptpayUrl.isNotEmpty) {
            final uri = Uri.parse(promptpayUrl);
            final updatedUri = uri.replace(
              queryParameters: {
                ...uri.queryParameters,
                'price': getPriceToUse().toStringAsFixed(2),
                'device_id': serial,
                'com_id': scanboxComId.toString(),
                'busno': scanboxBusId.toString(),
                'busround': scanboxBusroundLatest.toString(),
                'method_id': scanboxPaymentMethodId.toString(),
                'scanbox_func': scanboxFunc.toString(),
                'cardgroup_id': cardGroupId.toString(),
              },
            );

            final newUrl = updatedUri.toString();
            if (_lastLoadedUrl != newUrl) {
              _qrController!.loadRequest(updatedUri);
              _lastLoadedUrl = newUrl;
            }
          }

          showResultDialog(
            context,
            "เปิดใช้งานบัตรแล้ว",
            remainingTrips: null,
            // cardType: 1,
            expireDate: null,
            onDismiss: () {},
          );
        } else {
          showResultDialog(
            context,
            (result['message'] != null &&
                    result['message'].toString().trim().isNotEmpty)
                ? result['message'].toString()
                : "ไม่สามารถเปิดใช้งานบัตรได้",
            isError: true,
            onDismiss: () {},
          );
        }
      } else {
        // 🔹 เคส ใช้บัตรเดินทาง scanboxFunc == 0
        final result =
            await CardService.useCard(
              hash,
              getPriceToUse(),
              scanboxBusId,
              scanboxBusroundLatest,
              lat,
              long,
            ).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                return CardUseResponse(
                  status: 'success',
                  message: 'ใช้บัตรสำเร็จ (timeout)',
                  remainingBalance: null,
                  cardType: null,
                  expireDate: null,
                );
              },
            );

        if (result.status == 'success') {
          // setState(() {
          //   remainingTrips = result.remainingBalance;
          //   cardType = result.cardType;
          //   expireDate = result.expireDate;
          // });
          setState(() {
            remainingTrips = result.remainingBalance ?? 0;
            cardType = result.cardType ?? 0;
            expireDate = result.expireDate;
          });
          showResultDialog(
            context,
            result.message,
            remainingTrips: remainingTrips,
            cardType: cardType,
            expireDate: expireDate,
            onDismiss: () => setState(() => remainingTrips = null),
          );
        } else {
          showResultDialog(
            context,
            result.message,
            isError: true,
            onDismiss: () => setState(() => remainingTrips = null),
          );
        }
      }
    } catch (e) {
      showResultDialog(
        context,
        "เกิดข้อผิดพลาด",
        isError: true,
        onDismiss: () => setState(() => remainingTrips = null),
      );
    } finally {
      setState(() => isLoading = false);
      startCooldown();
    }
  }

  Widget buildPromptPaySection() {
    if (promptpayUrl.isEmpty) {
      return const Expanded(
        flex: 5,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (scanboxFunc == 1 && newCardPrice == null) {
      // 🆕 แสดงสถานะรอราคา
      return const Expanded(
        flex: 5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'กำลังโหลดราคาบัตร...',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ กรณีพร้อมแสดง QR แล้ว
    final uri = Uri.parse(promptpayUrl);
    final updatedUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'price': getPriceToUse().toStringAsFixed(2),
        'device_id': serial,
        'com_id': scanboxComId.toString(),
        'busno': scanboxBusId.toString(),
        'busround': scanboxBusroundLatest.toString(),
        'method_id': scanboxPaymentMethodId.toString(),
        'scanbox_func': scanboxFunc.toString(),
        'cardgroup_id': cardGroupId.toString(),
      },
    );

    print("method URL xxx=>: $updatedUri");

    return Expanded(
      flex: 5,
      child: PromptPayWebView(
        key: ValueKey(updatedUri.toString()),
        controller: _qrController!,
        url: updatedUri.toString(),
        zoomScale: 1.0,
      ),
    );
  }

  // Future<String> getCurrentLatitude() async {
  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.medium, // Balanced ระหว่างความเร็วและความแม่นยำ
  //       timeLimit: const Duration(seconds: 3), // ป้องกันค้าง
  //     );
  //     return position.latitude.toString();
  //   } catch (_) {
  //     final lastPosition = await Geolocator.getLastKnownPosition();
  //     return lastPosition?.latitude.toString() ?? '';
  //   }
  // }

  //   Future<String> getCurrentLongitude() async {
  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.medium, // Balanced ระหว่างความเร็วและความแม่นยำ
  //       timeLimit: const Duration(seconds: 3), // ป้องกันค้าง
  //     );
  //     return position.longitude.toString();
  //   } catch (_) {
  //     final lastPosition = await Geolocator.getLastKnownPosition();
  //     return lastPosition?.longitude.toString() ?? '';
  //   }
  // }

  Future<Position> getPositionWithFallback() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );
    } catch (_) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      rethrow;
    }
  }

  @override
  void dispose() {
    serialTimer?.cancel();
    debounceTimer?.cancel();
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false, // ✅ ปิดการแสดงขอบ focus
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (isLoading || isCooldown) return;

          if (event.character != null && event.character!.isNotEmpty) {
            _controller.text += event.character!;
            final asciiOnly = _controller.text.replaceAll(
              RegExp(r'[^A-Za-z0-9]'),
              '',
            );

            // ตัดให้ไม่เกิน 64 ตัวอักษร
            if (asciiOnly.length > 64) {
              _controller.text = asciiOnly.substring(0, 64);
              return;
            }

            //  Reset timeout ทุกครั้งที่มีตัวอักษรเข้ามา
            scanTimeoutTimer?.cancel();
            scanTimeoutTimer = Timer(const Duration(seconds: 1), () {
              if (asciiOnly.length < 64) {
                _controller.clear();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop(); // ปิดเองใน 2 วิ
                    });

                    return AlertDialog(
                      backgroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 32,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 96,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'ไม่สามารถอ่านข้อมูลบัตรได้',
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'กรุณาสแกนใหม่อีกครั้ง',
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            });

            //  กรณีครบ 64 ตัวอักษรพอดี → เคลียร์และยิง handler
            debounceTimer?.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 300), () {
              if (asciiOnly.length == 64) {
                _controller.clear();
                scanTimeoutTimer?.cancel(); // ❌ ยกเลิก timeout ถ้าสำเร็จ
                handleCardScan(asciiOnly);
              }
            });
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // 🔹 ฝั่งแสดงค่าโดยสาร
                    Expanded(
                      flex: 5,
                      child: FareDisplay(
                        currentPrice: getPriceToUse(), // 🆕
                        serial: serial,
                        lastLoadedUrl: _lastLoadedUrl,
                        scanboxFunc: scanboxFunc,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // 🔹 ฝั่งแสดง QR PromptPay
                    buildPromptPaySection(),
                  ],
                ),
              ),
              if (isLoading || isCooldown)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading) ...[
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          const Text(
                            'กำลังตรวจสอบบัตร...',
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                        ] else if (isCooldown) ...[
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'กรุณารอสแกนอีก $cooldownSeconds วินาที',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
