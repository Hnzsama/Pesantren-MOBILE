class PaymentChannelsResponse {
  final int adminFee;
  final List<PaymentChannel> channels;

  PaymentChannelsResponse({required this.adminFee, required this.channels});

  factory PaymentChannelsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PaymentChannelsResponse(
      adminFee: (data['admin_fee'] as num).toInt(),
      channels: (data['channels'] as List)
          .map((e) => PaymentChannel.fromJson(e))
          .toList(),
    );
  }
}

class PaymentChannel {
  final String code;
  final String name;
  final String type; // 'virtual_account', 'e_wallet', etc.
  final int feeFlat;
  final double feePercent;
  final String? iconUrl;

  PaymentChannel({
    required this.code,
    required this.name,
    required this.type,
    required this.feeFlat,
    required this.feePercent,
    this.iconUrl,
  });

  factory PaymentChannel.fromJson(Map<String, dynamic> json) {
    return PaymentChannel(
      code: json['code'],
      name: json['name'],
      type: json['type'],
      feeFlat: (json['fee_flat'] as num).toInt(),
      feePercent: (json['fee_percent'] as num).toDouble(),
      iconUrl: json['icon_url'],
    );
  }
}
