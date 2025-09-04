class Address {
  final int addressId;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double? latitude;
  final double? longitude;
  final String? note;
  final String? tagName;
  final int? userId;
  final String? provinceCode;
  final String? districtCode;
  final String? wardCode;
  final bool? isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    required this.addressId,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    this.latitude,
    this.longitude,
    this.note,
    this.tagName,
    this.userId,
    this.provinceCode,
    this.districtCode,
    this.wardCode,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      // Handle both 'id' and 'addressId' field names
      addressId: json['addressId'] ?? json['id'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      note: json['note'],
      tagName: json['tagName'],
      userId: json['userId'],
      provinceCode: json['provinceCode'],
      districtCode: json['districtCode'],
      wardCode: json['wardCode'],
      isDefault: json['isDefault'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Safe double parsing method that handles null, empty strings, and various data types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is String) {
      // Handle empty strings
      if (value.trim().isEmpty) return null;

      try {
        return double.parse(value.trim());
      } catch (e) {
        print('Warning: Could not parse "$value" as double: $e');
        return null;
      }
    }

    // Handle any other unexpected types
    try {
      return double.parse(value.toString());
    } catch (e) {
      print(
          'Warning: Could not convert $value (${value.runtimeType}) to double: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverAddress': receiverAddress,
      'latitude': latitude,
      'longitude': longitude,
      'note': note,
      'tagName': tagName,
      'userId': userId,
      'provinceCode': provinceCode,
      'districtCode': districtCode,
      'wardCode': wardCode,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Address(addressId: $addressId, receiverName: $receiverName, receiverAddress: $receiverAddress, latitude: $latitude, longitude: $longitude)';
  }
}
