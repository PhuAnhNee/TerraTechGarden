class Address {
  final int addressId;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;

  Address({
    required this.addressId,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
    );
  }
}
