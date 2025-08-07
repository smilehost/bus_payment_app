class Scanbox {
  final int scanboxId;
  final int comId;
  final String serial;
  final String promptpayUrl;
  final String adsUrl;
  final double currentPrice;
  final int scanboxBusId;
  final int scanboxBusroundLatest;
  final int scanboxPaymentMethodId;
  final int scanboxFunc;

  Scanbox({
    required this.scanboxId,
    required this.comId,
    required this.serial,
    required this.promptpayUrl,
    required this.adsUrl,
    required this.currentPrice,
    required this.scanboxBusId,
    required this.scanboxBusroundLatest,
    required this.scanboxPaymentMethodId,
    required this.scanboxFunc,
  });

  factory Scanbox.fromJson(Map<String, dynamic> json) {
    return Scanbox(
      scanboxId: json['scanbox_id'],
      comId: json['scanbox_com_id'],
      serial: json['scanbox_serial'],
      promptpayUrl: json['scanbox_promptpay_url'],
      adsUrl: json['scanbox_ads_url'],
      currentPrice: (json['scanbox_current_price'] ?? 0).toDouble(),
      scanboxBusId: json['scanbox_bus_id'],
      scanboxBusroundLatest: json['scanbox_busround_latest'],
      scanboxPaymentMethodId: json['scanbox_payment_method_id'],
      scanboxFunc: json['scanbox_func'],
    );
  }
}
