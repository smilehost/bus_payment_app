class CardUseResponse {
  final String status;
  final String message;
  final int? remainingBalance;
  final int? cardType;
  final DateTime? expireDate;

  CardUseResponse({
    required this.status,
    required this.message,
    this.remainingBalance,
    this.cardType,
    this.expireDate,
  });

  factory CardUseResponse.fromJson(Map<String, dynamic> json) {
    return CardUseResponse(
      status: json['status'],
      message: json['message'],
      remainingBalance: json['data']?['remaining_balance'],
      cardType: json['data']?['card_type'],
      expireDate: json['data']?['expire_date'] != null
          ? DateTime.parse(json['data']['expire_date'])
          : null,
    );
  }
}
