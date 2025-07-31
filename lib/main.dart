import 'package:bus_payment_app/pages/unified_fare_page.dart';
import 'package:flutter/material.dart';
// import 'pages/promptpay_page.dart';
// import 'pages/member_card_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const FarePaymentApp());
}

class FarePaymentApp extends StatelessWidget {
  const FarePaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fare Payment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        focusColor: const Color(0xFF0D1B2A),
      ),
      home: const MainTabPage(),
    );
  }
}

class MainTabPage extends StatelessWidget {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(90),
        //   child: AppBar(
        //     automaticallyImplyLeading: false,
        //     backgroundColor: const Color(0xFF0D1B2A),
        //     flexibleSpace: Padding(
        //       padding: const EdgeInsets.only(top: 16), // ดัน TabBar ลงมา
        //       child: Center(
        //         child: Container(
        //           margin: const EdgeInsets.symmetric(horizontal: 16),
        //           decoration: BoxDecoration(
        //             color: const Color(0xFF0D1B2A),
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: TabBar(
        //             indicator: BoxDecoration(
        //               color: Colors.white,
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             labelColor: Colors.black,
        //             unselectedLabelColor: Colors.white,
        //             labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        //             unselectedLabelStyle: const TextStyle(
        //               fontWeight: FontWeight.normal,
        //             ),
        //             indicatorSize: TabBarIndicatorSize.tab,
        //             tabs: [
        //               SizedBox(
        //                 height: 60,
        //                 child: Row(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: const [
        //                     Icon(Icons.qr_code, size: 24),
        //                     SizedBox(width: 12),
        //                     Text('PromptPay', style: TextStyle(fontSize: 18)),
        //                   ],
        //                 ),
        //               ),
        //               SizedBox(
        //                 height: 60,
        //                 child: Row(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: const [
        //                     Icon(Icons.credit_card, size: 24),
        //                     SizedBox(width: 12),
        //                     Text('บัตรสมาชิก', style: TextStyle(fontSize: 18)),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // body: const TabBarView(children: [PromptPayPage(), MemberCardPage()]),
        body: const UnifiedFarePage(),
      ),
    );
  }
}
