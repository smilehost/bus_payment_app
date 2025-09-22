// // lib/services/scanbox_socket_service.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:bus_payment_app/models/scanbox_response.dart';

// typedef ScanboxHandler = void Function(Scanbox);

// /// โหมดการเชื่อมต่อ ช่วยให้สลับ baseOrigin/path ง่าย
// class ScanboxSocketConfig {
//   final String baseOrigin;   // e.g. http://192.168.1.50:8000 หรือ https://api.bussing.app
//   final String socketPath;   // e.g. /api/socket.io (ให้ตรงกับ server)
//   final Duration connectTimeout;
//   final bool forceWebsocket;

//   const ScanboxSocketConfig({
//     required this.baseOrigin,
//     this.socketPath = '/api/socket.io',
//     this.connectTimeout = const Duration(seconds: 8),
//     this.forceWebsocket = true,
//   });

//   /// สำหรับโปรดักชัน
//   factory ScanboxSocketConfig.prod() => const ScanboxSocketConfig(
//         baseOrigin: 'https://api.bussing.app',
//         socketPath: '/api/socket.io',
//         forceWebsocket: true,
//       );

//   /// สำหรับ dev (มือถือจริงต้องเป็น IP คอม)
//   factory ScanboxSocketConfig.localLAN(String hostIp, {int port = 8000}) =>
//       ScanboxSocketConfig(
//         baseOrigin: 'http://$hostIp:$port',
//         socketPath: '/api/socket.io',
//         forceWebsocket: true,
//       );
// }

// class ScanboxSocketService {
//   final ScanboxSocketConfig cfg;
//   IO.Socket? _socket;
//   String? _boundSerial;

//   ScanboxSocketService(this.cfg);

//   /// ใช้เชื่อมแบบยึด serial เดียว (reconnect-safe)
//   void connect({
//     required String serial,
//     required ScanboxHandler onPriceUpdated,
//     required ScanboxHandler onFuncUpdated,
//     Duration initialAckTimeout = const Duration(seconds: 5),
//   }) {
//     _ensureConnected(serial);

//     final s = _socket!;
//     // กันซ้ำของ handler
//     s
//       ..off('price_updated')
//       ..off('func_updated');

//     s.on('price_updated', (data) {
//       debugPrint('🔔 price_updated(raw): $data');
//       final scanbox = _pickScanboxForSerial(data, serial);
//       if (scanbox != null) {
//         debugPrint('✅ price_updated -> onPriceUpdated()');
//         onPriceUpdated(scanbox);
//       } else {
//         debugPrint('⛔ filtered out: expect=$serial got=${data?['scanbox']?['scanbox_serial']}');
//       }
//     });

//     s.on('func_updated', (data) {
//       debugPrint('🔔 func_updated(raw): $data');
//       final scanbox = _pickScanboxForSerial(data, serial);
//       if (scanbox != null) {
//         debugPrint('✅ func_updated -> onFuncUpdated()');
//         onFuncUpdated(scanbox);
//       } else {
//         debugPrint('⛔ filtered out (func_updated): expect=$serial got=${data?['scanbox']?['scanbox_serial']}');
//       }
//     });

//     // ดึงค่าแรกด้วย ack (กันกรณี server ยังไม่ emit)
//     _requestInitial(serial, timeout: initialAckTimeout).then((first) {
//       if (first != null) {
//         debugPrint('✅ initial via ack -> onPriceUpdated()');
//         onPriceUpdated(first);
//       } else {
//         debugPrint('ℹ️ no initial via ack');
//       }
//     });
//   }

//   Future<Scanbox?> getScanboxBySerialOnce(
//     String serial, {
//     Duration timeout = const Duration(seconds: 5),
//   }) async {
//     await _waitUntilConnected(timeout: timeout);

//     // ลองผ่าน ack ก่อน
//     final viaAck = await _requestInitial(serial, timeout: timeout);
//     if (viaAck != null) return viaAck;

//     final completer = Completer<Scanbox?>();
//     late void Function(dynamic) oneOff;
//     Timer? timer;

//     oneOff = (data) {
//       debugPrint('🧲 one-off caught price_updated');
//       final s = _pickScanboxForSerial(data, serial);
//       if (s != null && !completer.isCompleted) {
//         _socket?.off('price_updated', oneOff);
//         timer?.cancel();
//         completer.complete(s);
//       }
//     };

//     _socket!.on('price_updated', oneOff);
//     timer = Timer(timeout, () {
//       _socket?.off('price_updated', oneOff);
//       if (!completer.isCompleted) completer.complete(null);
//     });

//     return completer.future;
//   }

//   void dispose() {
//     try {
//       _socket?.dispose();
//     } catch (_) {}
//     _socket = null;
//     _boundSerial = null;
//   }

//   // ---------- Internal ----------

//   void _ensureConnected(String serial) {
//     final sameSerial = (_boundSerial == serial);

//     if (sameSerial && _socket != null) return;

//     _boundSerial = serial;

//     try {
//       _socket?.dispose();
//     } catch (_) {}
//     _socket = null;

//     final path = cfg.socketPath;
//     debugPrint('🔌 connecting to ${cfg.baseOrigin}$path serial=$serial');

//     final opts = IO.OptionBuilder()
//         .setPath(path)
//         .enableForceNew() // เปิด forceNew เพื่อให้ลูปชีวิตของ socket ใหม่นิ่งเมื่อสลับ serial
//         .enableReconnection()
//         .setReconnectionAttempts(double.maxFinite.toInt())
//         .setReconnectionDelay(500)
//         .setReconnectionDelayMax(3000)
//         .setTimeout(cfg.connectTimeout.inMilliseconds)
//         .setQuery({'serial': serial});

//     if (cfg.forceWebsocket) {
//       opts.setTransports(['websocket']);
//     } else {
//       opts.setTransports(['websocket', 'polling']);
//     }

//     // NOTE: withCredentials ไม่จำเป็นบนแอปมือถือส่วนใหญ่ แต่ถ้าต้องการ cookie ก็ใช้ .setExtraHeaders ได้
//     _socket = IO.io(cfg.baseOrigin, opts.build());

//     _socket!
//       ..onConnect((_) {
//         final transport = _socket!.io.engine?.transport?.name;
//         debugPrint('🟢 connected id=${_socket!.id} transport=$transport');
//       })
//       ..onDisconnect((_) => debugPrint('🔴 disconnected'))
//       ..onConnectError((e) => debugPrint('⚠️ connect_error: $e'))
//       ..onError((e) => debugPrint('⚠️ error: $e'))
//       ..onAny((event, data) => debugPrint('📥 onAny: $event $data'));
//   }

//   Future<void> _waitUntilConnected({Duration timeout = const Duration(seconds: 8)}) async {
//     if (_socket?.connected == true) return;

//     final completer = Completer<void>();
//     void onOk(_) {
//       _socket?.off('connect', onOk);
//       if (!completer.isCompleted) completer.complete();
//     }

//     void onErr(e) {
//       _socket?.off('connect', onOk);
//       _socket?.off('connect_error', onErr);
//       if (!completer.isCompleted) {
//         completer.completeError(Exception('connect_error: $e'));
//       }
//     }

//     _socket?.on('connect', onOk);
//     _socket?.on('connect_error', onErr);

//     final t = Timer(timeout, () {
//       _socket?.off('connect', onOk);
//       _socket?.off('connect_error', onErr);
//       if (!completer.isCompleted) {
//         completer.completeError(TimeoutException('connect timeout'));
//       }
//     });

//     try {
//       await completer.future;
//     } finally {
//       t.cancel();
//     }
//   }

//   Future<Scanbox?> _requestInitial(
//     String serial, {
//     Duration timeout = const Duration(seconds: 5),
//   }) async {
//     final s = _socket;
//     if (s == null) return null;

//     try {
//       await _waitUntilConnected(timeout: timeout);

//       final completer = Completer<dynamic>();
//       s.emitWithAck(
//         'scanbox_request',
//         {'serial': serial},
//         ack: (data) {
//           if (!completer.isCompleted) completer.complete(data);
//         },
//       );
//       final res = await completer.future.timeout(timeout);

//       Map<String, dynamic>? obj;
//       if (res is Map) {
//         obj = Map<String, dynamic>.from(res);
//       } else if (res is List && res.isNotEmpty) {
//         final last = res.last;
//         if (last is Map) obj = Map<String, dynamic>.from(last);
//         if (last is String) obj = Map<String, dynamic>.from(jsonDecode(last));
//       } else if (res is String) {
//         obj = Map<String, dynamic>.from(jsonDecode(res));
//       }
//       if (obj == null) return null;

//       Map<String, dynamic>? scanboxMap;
//       if (obj['scanbox'] is Map) {
//         scanboxMap = Map<String, dynamic>.from(obj['scanbox']);
//       } else if (obj.containsKey('scanbox_serial')) {
//         scanboxMap = obj;
//       }

//       return (scanboxMap != null) ? Scanbox.fromJson(scanboxMap) : null;
//     } catch (e, st) {
//       debugPrint('❌ _requestInitial error: $e\n$st');
//       return null;
//     }
//   }

//   Scanbox? _pickScanboxForSerial(dynamic data, String expectSerial) {
//     try {
//       final scanboxJson = data?['scanbox'];
//       if (scanboxJson == null) return null;
//       final gotSerial =
//           (scanboxJson['scanbox_serial'] ?? scanboxJson['serial'] ?? '').toString();
//       if (gotSerial != expectSerial) return null;
//       return Scanbox.fromJson(Map<String, dynamic>.from(scanboxJson));
//     } catch (e) {
//       debugPrint('⚠️ parse event error: $e');
//       return null;
//     }
//   }

//   Future<void> debugPing() async {
//     try {
//       await _waitUntilConnected(timeout: const Duration(seconds: 8));
//       final c = Completer<void>();
//       _socket!.emitWithAck(
//         'ping_check',
//         {},
//         ack: (data) {
//           debugPrint('✅ ping_check ack: $data');
//           if (!c.isCompleted) c.complete();
//         },
//       );
//       await c.future.timeout(const Duration(seconds: 5));
//     } catch (e) {
//       debugPrint('❌ ping_check failed: $e');
//     }
//   }
// }
