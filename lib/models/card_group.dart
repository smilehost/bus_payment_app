class CardGroup {
  final int cardGroupId;
  final int cardGroupComId;
  final String cardGroupPrefix;
  final String cardGroupName;
  final double cardGroupPrice;
  final String cardGroupWaitingTime;
  final int cardGroupStatus;

  CardGroup({
    required this.cardGroupId,
    required this.cardGroupComId,
    required this.cardGroupPrefix,
    required this.cardGroupName,
    required this.cardGroupPrice,
    required this.cardGroupWaitingTime,
    required this.cardGroupStatus,
  });

  factory CardGroup.fromJson(Map<String, dynamic> json) {
    return CardGroup(
      cardGroupId: json['card_group_id'],
      cardGroupComId: json['card_group_com_id'],
      cardGroupPrefix: json['card_group_prefix'],
      cardGroupName: json['card_group_name'],
      cardGroupPrice: (json['card_group_price'] as num).toDouble(),
      cardGroupWaitingTime: json['card_group_waiting_time'],
      cardGroupStatus: json['card_group_status'],
    );
  }
}
