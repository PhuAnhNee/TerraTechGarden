import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:convert';

// Import this in your checkout_screen.dart:
// import 'address.dart';

class Address {
  final int? id;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final bool isDefault;

  Address({
    this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverAddress': receiverAddress,
    };
  }

  @override
  String toString() {
    return '$receiverName\n$receiverPhone\n$receiverAddress';
  }
}

class AddressService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String baseUrl =
      'https://terarium.shop'; // Change this URL as needed

  static Future<String?> _getUserIdFromToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        developer.log('❌ No token found', name: 'AddressService');
        return null;
      }

      // Decode JWT token to extract user ID
      final parts = token.split('.');
      if (parts.length != 3) {
        developer.log('❌ Invalid JWT token format', name: 'AddressService');
        return null;
      }

      // Decode the payload (middle part)
      final payload = parts[1];
      // Add padding if necessary
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      final userId = payloadMap['sub']?.toString();
      developer.log('✅ Extracted userId from JWT: $userId',
          name: 'AddressService');

      return userId;
    } catch (e) {
      developer.log('💥 Error extracting userId from JWT: $e',
          name: 'AddressService');
      return null;
    }
  }

  static Future<Dio> _getDio() async {
    final dio = Dio();
    final token = await _storage.read(key: 'auth_token');

    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
      developer.log('✅ Authorization header set for address API',
          name: 'AddressService');
    } else {
      developer.log('⚠️ No token found for address API',
          name: 'AddressService');
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    // Add interceptor for logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('🚀 ADDRESS REQUEST: ${options.method} ${options.path}',
            name: 'AddressService');
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('✅ ADDRESS RESPONSE: ${response.statusCode}',
            name: 'AddressService');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log(
            '❌ ADDRESS ERROR: ${error.response?.statusCode} ${error.message}',
            name: 'AddressService');
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<bool> addAddress(Address address) async {
    try {
      final dio = await _getDio();
      final response = await dio.post(
        '$baseUrl/api/Address/add-address',
        data: address.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Address added successfully', name: 'AddressService');
        return true;
      } else {
        developer.log('❌ Failed to add address: ${response.statusCode}',
            name: 'AddressService');
        return false;
      }
    } catch (e) {
      developer.log('💥 Error adding address: $e', name: 'AddressService');
      return false;
    }
  }

  static Future<List<Address>> getAddresses() async {
    try {
      // Get user ID from JWT token
      final userId = await _getUserIdFromToken();
      if (userId == null) {
        developer.log('❌ Cannot get addresses: No user ID found',
            name: 'AddressService');
        return [];
      }

      final dio = await _getDio();
      final response = await dio.get(
        '$baseUrl/api/Address/getall-by-user-id/$userId',
      );

      developer.log('📋 Address response status: ${response.statusCode}',
          name: 'AddressService');
      developer.log('📋 Address response data: ${response.data}',
          name: 'AddressService');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response formats
        List<dynamic> addressList = [];

        if (data is Map<String, dynamic>) {
          // If response has status and data fields
          if (data.containsKey('status') && data['status'] == 200) {
            addressList = data['data'] as List<dynamic>? ?? [];
          }
          // If response has items or addresses field
          else if (data.containsKey('data')) {
            addressList = data['data'] as List<dynamic>? ?? [];
          }
          // If the response itself contains address fields directly
          else if (data.containsKey('addresses')) {
            addressList = data['addresses'] as List<dynamic>? ?? [];
          }
        }
        // If response is directly a list
        else if (data is List<dynamic>) {
          addressList = data;
        }

        developer.log('📋 Processing ${addressList.length} addresses',
            name: 'AddressService');

        return addressList
            .map((json) {
              try {
                return Address.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                developer.log('❌ Error parsing address: $e',
                    name: 'AddressService');
                return null;
              }
            })
            .whereType<Address>()
            .toList();
      } else {
        developer.log('❌ Failed to get addresses: ${response.statusCode}',
            name: 'AddressService');
      }
    } catch (e) {
      developer.log('💥 Error fetching addresses: $e', name: 'AddressService');
      if (e is DioException) {
        developer.log('💥 Dio error details: ${e.response?.data}',
            name: 'AddressService');
      }
    }
    return [];
  }
}

class AddAddressDialog extends StatefulWidget {
  final Function(Address) onAddressAdded;

  const AddAddressDialog({super.key, required this.onAddressAdded});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _addAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final address = Address(
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      receiverAddress: _addressController.text.trim(),
    );

    final success = await AddressService.addAddress(address);

    setState(() => _isLoading = false);

    if (success) {
      widget.onAddressAdded(address);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm địa chỉ thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thêm địa chỉ. Vui lòng thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7020),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_location,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Thêm địa chỉ mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D7020),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Receiver Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên người nhận *',
                    hintText: 'Nhập tên người nhận',
                    prefixIcon:
                        const Icon(Icons.person, color: Color(0xFF1D7020)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF1D7020), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên người nhận';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Receiver Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại *',
                    hintText: 'Nhập số điện thoại',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF1D7020)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF1D7020), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value.trim())) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Receiver Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ *',
                    hintText:
                        'Nhập địa chỉ đầy đủ (số nhà, đường, phường/xã, quận/huyện, tỉnh/thành)',
                    prefixIcon:
                        const Icon(Icons.location_on, color: Color(0xFF1D7020)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF1D7020), width: 2),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    if (value.trim().length < 10) {
                      return 'Địa chỉ quá ngắn, vui lòng nhập đầy đủ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D7020),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Thêm địa chỉ',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
  late List<Address> _addresses;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _addresses = List.from(widget.addresses);
    _selectedAddress = widget.selectedAddress;
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAddressDialog(
        onAddressAdded: (address) {
          setState(() {
            _addresses.add(address);
          });
          widget.onAddressAdded(address);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D7020),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chọn địa chỉ giao hàng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D7020),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showAddAddressDialog,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF1D7020),
                    size: 28,
                  ),
                  tooltip: 'Thêm địa chỉ mới',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: _addresses.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có địa chỉ nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddAddressDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm địa chỉ đầu tiên'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D7020),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        final isSelected = _selectedAddress == address;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: RadioListTile<Address>(
                            value: address,
                            groupValue: _selectedAddress,
                            activeColor: const Color(0xFF1D7020),
                            onChanged: (Address? value) {
                              setState(() {
                                _selectedAddress = value;
                              });
                            },
                            title: Text(
                              address.receiverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  address.receiverPhone,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
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
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        );
                      },
                    ),
            ),
            if (_addresses.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAddress == null
                          ? null
                          : () {
                              widget.onAddressSelected(_selectedAddress!);
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7020),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Chọn địa chỉ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
