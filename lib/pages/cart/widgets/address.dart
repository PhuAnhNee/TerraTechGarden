import 'package:flutter/material.dart';

class Address {
  final int id;
  final String? tagName;
  final int userId;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String provinceCode;
  final String districtCode;
  final String wardCode;
  final String latitude;
  final String longitude;
  final bool isDefault;

  Address({
    required this.id,
    this.tagName,
    required this.userId,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.provinceCode,
    required this.districtCode,
    required this.wardCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      tagName: json['tagName'],
      userId: json['userId'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      districtCode: json['districtCode'] ?? '',
      wardCode: json['wardCode'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagName': tagName,
      'userId': userId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverAddress': receiverAddress,
      'provinceCode': provinceCode,
      'districtCode': districtCode,
      'wardCode': wardCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}

class AddressService {
  static Future<List<Address>> getAddresses() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Hardcoded address data
    final List<Map<String, dynamic>> addressData = [
      {
        "id": 7,
        "tagName": "Nhà",
        "userId": 15,
        "receiverName": "Hải",
        "receiverPhone": "0856686130",
        "receiverAddress":
            "20D, Phường Long Thạnh Mỹ, Thành phố Thủ Đức, Thành phố Hồ Chí Minh",
        "provinceCode": "79",
        "districtCode": "769",
        "wardCode": "26833",
        "latitude": "",
        "longitude": "",
        "isDefault": true
      },
      {
        "id": 14,
        "tagName": "công ti",
        "userId": 15,
        "receiverName": "phuc",
        "receiverPhone": "0912384384",
        "receiverAddress":
            "số nhà 3923, Phường Phúc Tân, Quận Hoàn Kiếm, Thành phố Hà Nội",
        "provinceCode": "01",
        "districtCode": "002",
        "wardCode": "00037",
        "latitude": "",
        "longitude": "",
        "isDefault": false
      },
      {
        "id": 22,
        "tagName": "a",
        "userId": 15,
        "receiverName": "a",
        "receiverPhone": "a",
        "receiverAddress":
            "a, Phường Quang Trung, Thành phố Hà Giang, Tỉnh Hà Giang",
        "provinceCode": "02",
        "districtCode": "024",
        "wardCode": "00688",
        "latitude": "",
        "longitude": "",
        "isDefault": false
      }
    ];

    return addressData.map((json) => Address.fromJson(json)).toList();
  }

  static Future<Address> addAddress(Address address) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real app, this would make an API call to add the address
    // For now, just return the address with a new ID
    return Address(
      id: DateTime.now().millisecondsSinceEpoch, // Generate fake ID
      tagName: address.tagName,
      userId: address.userId,
      receiverName: address.receiverName,
      receiverPhone: address.receiverPhone,
      receiverAddress: address.receiverAddress,
      provinceCode: address.provinceCode,
      districtCode: address.districtCode,
      wardCode: address.wardCode,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: address.isDefault,
    );
  }
}

class AddressSelectionDialog extends StatefulWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final Function(Address) onAddressSelected;
  final Function(Address) onAddressAdded;

  const AddressSelectionDialog({
    super.key,
    required this.addresses,
    this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddressAdded,
  });

  @override
  State<AddressSelectionDialog> createState() => _AddressSelectionDialogState();
}

class _AddressSelectionDialogState extends State<AddressSelectionDialog> {
  Address? _tempSelectedAddress;
  bool _isAddingNewAddress = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedAddress = widget.selectedAddress;
  }

  void _showAddAddressDialog() {
    setState(() {
      _isAddingNewAddress = true;
    });
  }

  void _hideAddAddressDialog() {
    setState(() {
      _isAddingNewAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAddingNewAddress) {
      return AddAddressDialog(
        onCancel: _hideAddAddressDialog,
        onAddressAdded: (address) {
          widget.onAddressAdded(address);
          _hideAddAddressDialog();
          Navigator.of(context).pop();
        },
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn địa chỉ giao hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.addresses.length,
                itemBuilder: (context, index) {
                  final address = widget.addresses[index];
                  final isSelected = _tempSelectedAddress?.id == address.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _tempSelectedAddress = address;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1D7020)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(0xFF1D7020).withOpacity(0.05)
                              : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<Address>(
                                  value: address,
                                  groupValue: _tempSelectedAddress,
                                  onChanged: (Address? value) {
                                    setState(() {
                                      _tempSelectedAddress = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF1D7020),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            address.receiverName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (address.tagName != null &&
                                              address.tagName!.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1D7020)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                address.tagName!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF1D7020),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (address.isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Mặc định',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address.receiverPhone,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        address.receiverAddress,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _showAddAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text('Thêm địa chỉ mới'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1D7020),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _tempSelectedAddress != null
                        ? () {
                            widget.onAddressSelected(_tempSelectedAddress!);
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7020),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddressDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(Address) onAddressAdded;

  const AddAddressDialog({
    super.key,
    required this.onCancel,
    required this.onAddressAdded,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _tagController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _addAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newAddress = Address(
        id: 0, // Will be assigned by service
        tagName: _tagController.text.trim().isEmpty
            ? null
            : _tagController.text.trim(),
        userId: 15, // Hardcoded user ID
        receiverName: _nameController.text.trim(),
        receiverPhone: _phoneController.text.trim(),
        receiverAddress: _addressController.text.trim(),
        provinceCode: "79", // Default province code
        districtCode: "769", // Default district code
        wardCode: "26833", // Default ward code
        latitude: "",
        longitude: "",
        isDefault: _isDefault,
      );

      final addedAddress = await AddressService.addAddress(newAddress);
      widget.onAddressAdded(addedAddress);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thêm địa chỉ'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm địa chỉ mới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên người nhận *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên người nhận';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ chi tiết *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập địa chỉ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Nhãn địa chỉ (VD: Nhà, Công ty)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Đặt làm địa chỉ mặc định'),
                        value: _isDefault,
                        onChanged: (bool? value) {
                          setState(() {
                            _isDefault = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF1D7020),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : widget.onCancel,
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7020),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Thêm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
