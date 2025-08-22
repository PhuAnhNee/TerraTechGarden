import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class DeliveryScreen extends StatefulWidget {
  final LatLng? destinationLatLng;
  final Map<String, dynamic>? orderData;

  const DeliveryScreen({super.key, this.destinationLatLng, this.orderData});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;
  LatLng? _finalDestinationLatLng;
  List<LatLng> polylineCoordinates = [];
  String? _errorMessage;
  String? _completionImage;
  final ImagePicker _imagePicker = ImagePicker();
  BitmapDescriptor? _shipperIcon;

  // Receiver information
  final String receiverName = "Hải";
  final String receiverPhone = "0856686130";
  final String receiverAddress =
      "20D, Phường Long Thạnh Mỹ, Thành phố Thủ Đức, Thành phố Hồ Chí Minh";

  @override
  void initState() {
    super.initState();
    _initializeDelivery();
    _loadCustomIcon();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to convert Icon to BitmapDescriptor
  Future<BitmapDescriptor> _createMarkerIcon() async {
    const iconSize = 48.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final painter = TextPainter(textDirection: TextDirection.ltr);
    final icon = Icons.directions_car;

    final textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        fontSize: iconSize,
        color: Colors.blue,
      ),
    );

    painter.text = textSpan;
    painter.layout();
    painter.paint(canvas, Offset.zero);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(iconSize.toInt(), iconSize.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final bitmap = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    return bitmap;
  }

  // Function to load custom motorcycle icon
  Future<void> _loadCustomIcon() async {
    try {
      final BitmapDescriptor icon = await _createMarkerIcon();
      setState(() {
        _shipperIcon = icon;
      });
    } catch (e) {
      developer.log('Error loading custom icon: $e', name: 'DeliveryScreen');
      setState(() {
        _shipperIcon = BitmapDescriptor.defaultMarker;
      });
    }
  }

  Future<void> _initializeDelivery() async {
    await _checkAndGetLocation();
    await _setDestinationCoordinates();
  }

  Future<void> _setDestinationCoordinates() async {
    print('=== SET DESTINATION START ===');
    print('Widget destination: ${widget.destinationLatLng}');

    if (widget.destinationLatLng != null) {
      setState(() {
        _finalDestinationLatLng = widget.destinationLatLng;
      });
      print('Using destination from widget: $_finalDestinationLatLng');
    } else {
      print('No destination from widget, geocoding address...');
      await _geocodeAddress();
    }

    print('Final destination set to: $_finalDestinationLatLng');
    await Future.delayed(Duration(milliseconds: 500));

    if (_currentLatLng != null && _finalDestinationLatLng != null) {
      print('Both coordinates available, drawing route...');
      await _drawRouteWithOSRM();
    } else {
      print('Missing coordinates for route drawing:');
      print('Current: $_currentLatLng, Destination: $_finalDestinationLatLng');
    }
    print('=== SET DESTINATION END ===');
  }

  Future<void> _geocodeAddress() async {
    print('=== GEOCODING START ===');
    try {
      setState(() {
        _finalDestinationLatLng = const LatLng(10.8411, 106.8066);
      });
      print(
          'Using coordinates for Long Thanh My, Thu Duc: $_finalDestinationLatLng');

      final encodedAddress =
          Uri.encodeQueryComponent("Thu Duc City, Ho Chi Minh City, Vietnam");
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1';

      print('Geocoding URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DeliveryApp/1.0'},
      );

      print('Geocoding response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Geocoding response: $data');
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          setState(() {
            _finalDestinationLatLng = LatLng(lat, lon);
          });
          print('Updated coordinates from geocoding: $_finalDestinationLatLng');
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
      setState(() {
        _finalDestinationLatLng = const LatLng(10.8411, 106.8066);
      });
    }
    print('=== GEOCODING END ===');
  }

  Future<void> _checkAndGetLocation() async {
    print('=== GET LOCATION START ===');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Vui lòng bật dịch vụ định vị trên thiết bị.';
      });
      print('Location services disabled');
      return;
    }

    print('Checking permissions...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Requesting permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Ứng dụng cần quyền truy cập vị trí. Vui lòng cấp quyền.';
        });
        print('Permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.';
      });
      print('Permission denied forever');
      return;
    }

    print('Getting current position...');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _errorMessage = null;
      });
      print('Current location obtained: $_currentLatLng');

      if (_currentLatLng != null && _controller.isCompleted) {
        GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
      }
    } catch (e) {
      print('Location error: $e');
      setState(() {
        _currentLatLng = const LatLng(20.9373, 106.3277); // Hải Dương
        _errorMessage = null;
      });
      print('Using fallback location: $_currentLatLng');
    }
    print('=== GET LOCATION END ===');
  }

  Future<void> _drawRouteWithOSRM() async {
    print('=== DRAWING ROUTE START ===');
    print('Current location: $_currentLatLng');
    print('Destination: $_finalDestinationLatLng');

    if (_currentLatLng == null || _finalDestinationLatLng == null) {
      print('Cannot draw route: missing coordinates');
      print('Current: $_currentLatLng, Destination: $_finalDestinationLatLng');
      return;
    }

    final url =
        'https://router.project-osrm.org/route/v1/driving/${_currentLatLng!.longitude},${_currentLatLng!.latitude};${_finalDestinationLatLng!.longitude},${_finalDestinationLatLng!.latitude}?overview=full&geometries=geojson';
    print('OSRM URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DeliveryApp/1.0'},
      );
      print('OSRM response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('OSRM decoded data: $data');

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates']
              .map<LatLng>(
                  (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          print('Route coordinates count: ${coordinates.length}');
          print('First few coordinates: ${coordinates.take(3).toList()}');

          setState(() {
            polylineCoordinates = coordinates;
          });
          print('Route set successfully with ${coordinates.length} points');

          if (_controller.isCompleted && coordinates.length > 1) {
            await _fitCameraToRoute();
          }
        } else {
          print('No routes found in response');
          setState(() {
            _errorMessage = 'Không tìm thấy đường đi';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Lỗi OSRM: ${response.statusCode} - ${response.body}';
        });
        print('OSRM HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi vẽ đường: $e';
      });
      print('OSRM Exception: $e');
    }
    print('=== DRAWING ROUTE END ===');
  }

  Future<void> _fitCameraToRoute() async {
    if (polylineCoordinates.isEmpty) return;

    GoogleMapController controller = await _controller.future;

    double minLat = polylineCoordinates.first.latitude;
    double maxLat = polylineCoordinates.first.latitude;
    double minLng = polylineCoordinates.first.longitude;
    double maxLng = polylineCoordinates.first.longitude;

    for (LatLng point in polylineCoordinates) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  // FIXED PHONE CALL METHOD
  Future<void> _makePhoneCall() async {
    print('PHONE CALL DEBUG: Starting phone call process');

    // Clean phone number - loại bỏ mọi ký tự không phải số
    final String cleanPhone = receiverPhone.replaceAll(RegExp(r'[^\d]'), '');
    print('PHONE CALL DEBUG: Original: $receiverPhone, Clean: $cleanPhone');

    // Thử nhiều format khác nhau
    final List<String> phoneFormats = [
      'tel:$cleanPhone',
      'tel:+84${cleanPhone.substring(1)}', // Convert to international
      'tel://$cleanPhone',
    ];

    bool callSuccessful = false;

    for (String phoneUri in phoneFormats) {
      try {
        print('PHONE CALL DEBUG: Trying $phoneUri');
        final Uri uri = Uri.parse(phoneUri);

        if (await canLaunchUrl(uri)) {
          print('PHONE CALL DEBUG: Can launch $phoneUri');

          final bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          print('PHONE CALL DEBUG: Launch result for $phoneUri: $launched');

          if (launched) {
            callSuccessful = true;
            break;
          }
        } else {
          print('PHONE CALL DEBUG: Cannot launch $phoneUri');
        }
      } catch (e) {
        print('PHONE CALL DEBUG: Error with $phoneUri: $e');
      }
    }

    if (!callSuccessful) {
      print('PHONE CALL DEBUG: All methods failed, showing error');
      _showErrorSnackBar(
          'Không thể gọi điện. Kiểm tra:\n1. Permissions\n2. Ứng dụng điện thoại\n3. Test trên device thật');
    }
  }

  // BUILD ENHANCED PHONE BUTTON
  Widget _buildEnhancedPhoneButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          print('PHONE BUTTON DEBUG: Button tapped!');

          // Show immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang thực hiện cuộc gọi...'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );

          // Delay slightly then make call
          Future.delayed(Duration(milliseconds: 500), () {
            _makePhoneCall();
          });
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.phone,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Future<void> _pickCompletionImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Chọn ảnh hoàn thành',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Chụp ảnh mới',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Chọn từ thư viện',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );

      if (source != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (pickedFile != null) {
          setState(() {
            _completionImage = pickedFile.path;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh hoàn thành đã được chọn!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Image picker error: $e', name: 'DeliveryScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    if (_completionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh xác nhận hoàn thành trước!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận hoàn thành',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Xác nhận đơn hàng đã được giao thành công?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            if (_completionImage != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_completionImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeDelivery();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeDelivery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Giao hàng thành công! Đang cập nhật trạng thái...'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, {
      'completed': true,
      'completionImage': _completionImage,
      'completionTime': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : _currentLatLng == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLatLng!,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) =>
                          _controller.complete(controller),
                      markers: {
                        Marker(
                          markerId: const MarkerId('shipper'),
                          position: _currentLatLng!,
                          icon: _shipperIcon ?? BitmapDescriptor.defaultMarker,
                          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
                        ),
                        if (_finalDestinationLatLng != null)
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: _finalDestinationLatLng!,
                            infoWindow:
                                const InfoWindow(title: 'Vị trí khách hàng'),
                          ),
                      },
                      polylines: {
                        if (polylineCoordinates.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId('route'),
                            color: Colors.green,
                            width: 5,
                            points: polylineCoordinates,
                          ),
                      },
                      style: '''
                        [
                          {
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#212121"
                              }
                            ]
                          },
                          {
                            "elementType": "labels.icon",
                            "stylers": [
                              {
                                "visibility": "off"
                              }
                            ]
                          },
                          {
                            "elementType": "labels.text.fill",
                            "stylers": [
                              {
                                "color": "#757575"
                              }
                            ]
                          },
                          {
                            "elementType": "labels.text.stroke",
                            "stylers": [
                              {
                                "color": "#212121"
                              }
                            ]
                          },
                          {
                            "featureType": "administrative",
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#757575"
                              }
                            ]
                          },
                          {
                            "featureType": "road",
                            "elementType": "geometry.fill",
                            "stylers": [
                              {
                                "color": "#2c2c2c"
                              }
                            ]
                          },
                          {
                            "featureType": "road.arterial",
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#373737"
                              }
                            ]
                          },
                          {
                            "featureType": "road.highway",
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#3c3c3c"
                              }
                            ]
                          },
                          {
                            "featureType": "water",
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#000000"
                              }
                            ]
                          }
                        ]
                      ''',
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 80,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Đang đi tới khách hàng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Đang giao',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          receiverName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          receiverAddress,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // ENHANCED PHONE BUTTON
                                  _buildEnhancedPhoneButton(),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Mã đơn hàng: #JA447FB549',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Đã xác nhận',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Dự kiến giao hàng',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        '23 August 25',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _pickCompletionImage,
                                      icon: const Icon(Icons.photo,
                                          color: Colors.white),
                                      label: Text(
                                        _completionImage != null
                                            ? 'Chọn lại ảnh hoàn thành'
                                            : 'Chọn ảnh hoàn thành',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_completionImage != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_completionImage!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _showCompletionDialog,
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.white),
                                        label: const Text(
                                          'Xác nhận hoàn thành giao hàng',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
