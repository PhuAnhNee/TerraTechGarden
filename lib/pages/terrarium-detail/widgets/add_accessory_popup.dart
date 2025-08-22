import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../api/terra_api.dart';

class AddAccessoryPopup extends StatefulWidget {
  final Map<String, dynamic> terrarium;
  final List<Map<String, dynamic>> accessories;
  final Function(List<Map<String, dynamic>>) onConfirm;

  const AddAccessoryPopup({
    super.key,
    required this.terrarium,
    required this.accessories,
    required this.onConfirm,
  });

  @override
  State<AddAccessoryPopup> createState() => _AddAccessoryPopupState();
}

class _AddAccessoryPopupState extends State<AddAccessoryPopup> {
  late List<Map<String, dynamic>> selectedAccessories;

  @override
  void initState() {
    super.initState();
    developer.log('Received accessories: ${widget.accessories}',
        name: 'AddAccessoryPopup');
    selectedAccessories = widget.accessories.map((accessory) {
      return {
        'accessoryId': accessory['accessoryId'] ?? accessory['id'],
        'itemId': accessory['itemId'],
        'isSelected': false,
        'name': accessory['name'] ?? 'Unknown Accessory',
        'price': accessory['price'] ?? 0.0,
        'imageUrl': '', // Will be fetched from API
      };
    }).toList();

    // Fetch images for each accessory
    _fetchAccessoryImages();
  }

  Future<void> _fetchAccessoryImages() async {
    for (var i = 0; i < selectedAccessories.length; i++) {
      final accessoryId = selectedAccessories[i]['accessoryId'];
      if (accessoryId == null) {
        developer.log('Missing accessoryId for accessory at index $i',
            name: 'AddAccessoryPopup');
        setState(() {
          selectedAccessories[i]['imageUrl'] = '';
        });
        continue;
      }

      try {
        developer.log('Fetching image for accessoryId: $accessoryId',
            name: 'AddAccessoryPopup');
        final response = await Dio().get(
          TerraApi.getAccessoryImageById(accessoryId.toString()),
          options: Options(headers: {
            'Content-Type': 'application/json',
            'accept': 'text/plain',
          }),
        );

        developer.log(
            'API Response for accessory $accessoryId: ${response.statusCode} - ${response.data}',
            name: 'AddAccessoryPopup');

        if (response.statusCode == 200 && response.data['status'] == 200) {
          final data = response.data['data'] as Map<String, dynamic>?;
          if (data == null) {
            developer.log('No data in response for accessory $accessoryId',
                name: 'AddAccessoryPopup');
            setState(() {
              selectedAccessories[i]['imageUrl'] = '';
            });
            continue;
          }

          final imageUrl = data['imageUrl']?.toString() ?? '';
          developer.log(
              'Extracted imageUrl for accessory $accessoryId: $imageUrl',
              name: 'AddAccessoryPopup');

          setState(() {
            selectedAccessories[i]['imageUrl'] =
                imageUrl.isNotEmpty ? imageUrl : '';
          });
        } else {
          developer.log(
              'Invalid response for accessory $accessoryId: status ${response.data['status']}',
              name: 'AddAccessoryPopup');
          setState(() {
            selectedAccessories[i]['imageUrl'] = '';
          });
        }
      } catch (e, stackTrace) {
        developer.log('Error fetching image for accessory $accessoryId: $e',
            name: 'AddAccessoryPopup', error: e, stackTrace: stackTrace);
        setState(() {
          selectedAccessories[i]['imageUrl'] = '';
        });
      }
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      selectedAccessories[index]['isSelected'] =
          !selectedAccessories[index]['isSelected'];
    });
  }

  void _toggleSelectAll() {
    setState(() {
      final allSelected =
          selectedAccessories.every((item) => item['isSelected']);
      for (var accessory in selectedAccessories) {
        accessory['isSelected'] = !allSelected;
      }
    });
  }

  void _handleConfirm() {
    final selectedItems = selectedAccessories
        .where((item) => item['isSelected'] == true)
        .map((item) => {
              'accessoryId': item['accessoryId'],
              'accessoryQuantity': 1,
              if (item['itemId'] != null) 'itemId': item['itemId'],
            })
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one accessory'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onConfirm(selectedItems);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Accessories',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(
              selectedAccessories.every((item) => item['isSelected'])
                  ? 'Deselect All'
                  : 'Select All',
              style: const TextStyle(color: Color(0xFF1D7020)),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: selectedAccessories.length,
          itemBuilder: (context, index) {
            final accessory = selectedAccessories[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: CheckboxListTile(
                value: accessory['isSelected'],
                onChanged: (value) => _toggleSelection(index),
                title: Text(accessory['name']),
                subtitle: Text(
                  'Price: ${TerrariumHelper.formatCurrency(accessory['price'].toDouble())}',
                ),
                secondary: accessory['imageUrl'].isNotEmpty
                    ? Image.network(
                        accessory['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          developer.log(
                              'Image load failed for ${accessory['imageUrl']}: $error',
                              name: 'AddAccessoryPopup');
                          return Image.network(
                            'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator();
                        },
                      )
                    : Image.network(
                        'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D7020),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}

// Helper class for shared utilities
class TerrariumHelper {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }
}
