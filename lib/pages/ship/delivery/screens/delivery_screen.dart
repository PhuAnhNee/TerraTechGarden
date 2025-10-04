import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../../../models/transport.dart';
import '../../../../models/address.dart';

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
  BitmapDescriptor? _shipperIcon;

  // Dynamic receiver information - will be populated from API data
  String receiverName = "Loading...";
  String receiverPhone = "";
  String receiverAddress = "Loading address...";
  String transportId = "";
  String estimatedDelivery = "";
  Transport? transport;
  Address? address;

  @override
  void initState() {
    super.initState();
    _extractArgumentsFromRoute();
    _initializeDelivery();
    _loadCustomIcon();
  }

  void _extractArgumentsFromRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        transport = arguments['transport'] as Transport?;
        address = arguments['address'] as Address?;

        print('=== EXTRACTING API DATA ===');
        print('Transport data: ${transport?.toJson()}');
        print('Address data: ${address?.toJson()}');

        // Use API data from address object
        if (address != null) {
          setState(() {
            receiverName = address!.receiverName ?? "Unknown Receiver";
            receiverPhone = address!.receiverPhone ?? "";
            receiverAddress = address!.receiverAddress ?? "Unknown Address";
          });

          // Set destination coordinates from address
          if (address!.latitude != null && address!.longitude != null) {
            setState(() {
              _finalDestinationLatLng =
                  LatLng(address!.latitude!, address!.longitude!);
            });
            print('Using coordinates from address: $_finalDestinationLatLng');
          }
        }

        // Use transport data for order information
        if (transport != null) {
          setState(() {
            transportId = transport!.transportId.toString();
            if (transport!.estimatedDelivery != null) {
              estimatedDelivery =
                  '${transport!.estimatedDelivery!.day}/${transport!.estimatedDelivery!.month}/${transport!.estimatedDelivery!.year}';
            }
          });
        }

        print('=== FINAL EXTRACTED DATA ===');
        print('Receiver Name: $receiverName');
        print('Receiver Phone: $receiverPhone');
        print('Receiver Address: $receiverAddress');
        print('Transport ID: $transportId');
        print('Estimated Delivery: $estimatedDelivery');
        print('Destination LatLng: $_finalDestinationLatLng');
      } else {
        print('=== NO ARGUMENTS FOUND ===');
        _showErrorSnackBar('Không thể tải thông tin đơn hàng');
      }
    });
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
    print('=== INITIALIZE DELIVERY START ===');
    await _checkAndGetLocation();
    await _setDestinationCoordinates();
    print('=== INITIALIZE DELIVERY END ===');
  }

  Future<void> _checkAndGetLocation() async {
    print('=== GET LOCATION START ===');

    try {
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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _errorMessage = null;
      });
      print('Current location obtained: $_currentLatLng');

      // Update camera to current location
      if (_currentLatLng != null && _controller.isCompleted) {
        GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
      }
    } catch (e) {
      print('Location error: $e');
      // Use Ho Chi Minh City center as fallback
      setState(() {
        _currentLatLng = const LatLng(10.8231, 106.6297);
        _errorMessage = null;
      });
      print('Using fallback location: $_currentLatLng');
    }
    print('=== GET LOCATION END ===');
  }

  Future<void> _setDestinationCoordinates() async {
    print('=== SET DESTINATION START ===');
    print('Widget destination: ${widget.destinationLatLng}');
    print(
        'Address coordinates: lat=${address?.latitude}, lng=${address?.longitude}');

    // Priority: widget parameter > address coordinates > geocoding
    if (widget.destinationLatLng != null) {
      setState(() {
        _finalDestinationLatLng = widget.destinationLatLng;
      });
      print('Using destination from widget parameter');
    } else if (address?.latitude != null && address?.longitude != null) {
      setState(() {
        _finalDestinationLatLng =
            LatLng(address!.latitude!, address!.longitude!);
      });
      print('Using coordinates from address object');
    } else if (receiverAddress.isNotEmpty &&
        receiverAddress != "Loading address...") {
      print('No coordinates available, attempting geocoding...');
      await _geocodeAddress();
    } else {
      print('No address data available for geocoding');
      _showErrorSnackBar('Không có thông tin địa chỉ');
      return;
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
      // Try multiple geocoding strategies
      LatLng? coordinates = await _tryMultipleGeocodingServices();

      if (coordinates != null) {
        setState(() {
          _finalDestinationLatLng = coordinates;
        });
        print('Successfully geocoded: $_finalDestinationLatLng');
      } else {
        print('All geocoding methods failed');
        _showErrorSnackBar('Không tìm thấy địa chỉ chính xác');

        // Fallback to Ho Chi Minh City center as last resort
        setState(() {
          _finalDestinationLatLng = const LatLng(10.8231, 106.6297);
        });
        print('Using Ho Chi Minh City center as fallback');
      }
    } catch (e) {
      print('Geocoding error: $e');
      _showErrorSnackBar('Lỗi khi tìm địa chỉ');

      // Fallback coordinates
      setState(() {
        _finalDestinationLatLng = const LatLng(10.8231, 106.6297);
      });
    }
    print('=== GEOCODING END ===');
  }

  Future<LatLng?> _tryMultipleGeocodingServices() async {
    // Strategy 1: Try with simplified address (remove detailed parts)
    LatLng? result = await _geocodeWithSimplifiedAddress();
    if (result != null) return result;

    // Strategy 2: Try with district/city only
    result = await _geocodeDistrictOnly();
    if (result != null) return result;

    // Strategy 3: Try original full address with Nominatim
    result = await _geocodeWithNominatim(receiverAddress);
    if (result != null) return result;

    // Strategy 4: Try Google Geocoding API if available
    // result = await _geocodeWithGoogle();
    // if (result != null) return result;

    return null;
  }

  Future<LatLng?> _geocodeWithSimplifiedAddress() async {
    print('Trying simplified address geocoding...');

    // Extract main parts from Vietnamese address
    String simplified = _simplifyVietnameseAddress(receiverAddress);
    if (simplified.isNotEmpty) {
      return await _geocodeWithNominatim(simplified);
    }
    return null;
  }

  String _simplifyVietnameseAddress(String fullAddress) {
    // Remove house numbers and detailed parts, keep district and city
    String simplified = fullAddress;

    // Remove house/building numbers (pattern: số X, X/, etc.)
    simplified =
        simplified.replaceAll(RegExp(r'số\s*\d+[A-Za-z]*/?\d*[,\s]*'), '');
    simplified = simplified.replaceAll(RegExp(r'\d+[A-Za-z]*/?\d*[,\s]*'), '');

    // Keep only district and city information
    List<String> parts = simplified.split(',');
    List<String> importantParts = [];

    for (String part in parts) {
      String trimmed = part.trim();
      if (trimmed.contains('Quận') ||
          trimmed.contains('Huyện') ||
          trimmed.contains('Thành phố') ||
          trimmed.contains('Phường') ||
          trimmed.contains('Xã')) {
        importantParts.add(trimmed);
      }
    }

    String result = importantParts.join(', ');
    print('Simplified address: "$fullAddress" -> "$result"');
    return result;
  }

  Future<LatLng?> _geocodeDistrictOnly() async {
    print('Trying district-only geocoding...');

    // Extract district and city
    List<String> parts = receiverAddress.split(',');
    String districtCity = '';

    for (String part in parts) {
      String trimmed = part.trim();
      if (trimmed.contains('Quận') || trimmed.contains('Thành phố')) {
        districtCity += trimmed + ', ';
      }
    }

    if (districtCity.isNotEmpty) {
      districtCity = districtCity.substring(
          0, districtCity.length - 2); // Remove last ", "
      print('Trying district/city: "$districtCity"');
      return await _geocodeWithNominatim(districtCity);
    }

    return null;
  }

  Future<LatLng?> _geocodeWithNominatim(String address) async {
    try {
      final encodedAddress = Uri.encodeQueryComponent(address);
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1&countrycodes=VN';

      print('Nominatim URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DeliveryApp/1.0',
          'Accept': 'application/json',
        },
      );

      print('Nominatim response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Nominatim response: $data');

        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());

          if (lat != null && lon != null) {
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      print('Nominatim geocoding error: $e');
    }
    return null;
  }

  // Alternative: Use known district centers as fallback
  Future<LatLng?> _getDistrictCenter() async {
    print('Using known district centers...');

    Map<String, LatLng> districtCenters = {
      'Quận 1': LatLng(10.7769, 106.7009),
      'Quận 2': LatLng(10.7543, 106.7285),
      'Quận 3': LatLng(10.7860, 106.6917),
      'Quận 4': LatLng(10.7572, 106.7025),
      'Quận 5': LatLng(10.7546, 106.6660),
      'Quận 6': LatLng(10.7433, 106.6515),
      'Quận 7': LatLng(10.7332, 106.7199),
      'Quận 8': LatLng(10.7384, 106.6763),
      'Quận 9': LatLng(10.8428, 106.8068),
      'Quận 10': LatLng(10.7736, 106.6710),
      'Quận 11': LatLng(10.7624, 106.6507),
      'Quận 12': LatLng(10.8537, 106.6504),
      'Quận Bình Thạnh': LatLng(10.8014, 106.7100),
      'Quận Tân Bình': LatLng(10.8009, 106.6525),
      'Quận Tân Phú': LatLng(10.7904, 106.6279),
      'Quận Phú Nhuận': LatLng(10.7980, 106.6829),
      'Quận Gò Vấp': LatLng(10.8376, 106.6667),
      'Thành phố Thủ Đức': LatLng(10.8709, 106.7633),
      'Quận Bình Tân': LatLng(10.7392, 106.6055),
      'Huyện Bình Chánh': LatLng(10.7417, 106.5500),
      'Huyện Hóc Môn': LatLng(10.8835, 106.5917),
      'Huyện Củ Chi': LatLng(10.9742, 106.4917),
    };

    // Find matching district
    for (String district in districtCenters.keys) {
      if (receiverAddress.contains(district)) {
        print('Found district center for: $district');
        return districtCenters[district];
      }
    }

    return null;
  }

  // Integrated approach - modify your existing _setDestinationCoordinates method
  Future<void> _setDestinationCoordinatesImproved() async {
    print('=== SET DESTINATION START (IMPROVED) ===');
    print('Widget destination: ${widget.destinationLatLng}');
    print(
        'Address coordinates: lat=${address?.latitude}, lng=${address?.longitude}');

    // Priority 1: widget parameter
    if (widget.destinationLatLng != null) {
      setState(() {
        _finalDestinationLatLng = widget.destinationLatLng;
      });
      print('Using destination from widget parameter');
    }
    // Priority 2: address coordinates from API
    else if (address?.latitude != null && address?.longitude != null) {
      setState(() {
        _finalDestinationLatLng =
            LatLng(address!.latitude!, address!.longitude!);
      });
      print('Using coordinates from address object');
    }
    // Priority 3: Try multiple geocoding strategies
    else if (receiverAddress.isNotEmpty &&
        receiverAddress != "Loading address...") {
      print('No coordinates available, trying improved geocoding...');

      // Try improved geocoding
      LatLng? geocodedCoords = await _tryMultipleGeocodingServices();

      if (geocodedCoords != null) {
        setState(() {
          _finalDestinationLatLng = geocodedCoords;
        });
        print('Successfully geocoded address');
      } else {
        // Final fallback: Try district centers
        LatLng? districtCoords = await _getDistrictCenter();
        if (districtCoords != null) {
          setState(() {
            _finalDestinationLatLng = districtCoords;
          });
          print('Using district center coordinates');
          _showErrorSnackBar('Sử dụng tọa độ trung tâm quận/huyện');
        } else {
          print('All geocoding methods failed');
          _showErrorSnackBar('Không thể xác định địa chỉ chính xác');
          return;
        }
      }
    }
    // No address data
    else {
      print('No address data available for geocoding');
      _showErrorSnackBar('Không có thông tin địa chỉ');
      return;
    }

    print('Final destination set to: $_finalDestinationLatLng');
    await Future.delayed(Duration(milliseconds: 500));

    if (_currentLatLng != null && _finalDestinationLatLng != null) {
      print('Both coordinates available, drawing route...');
      await _drawRouteWithOSRM();
    }

    print('=== SET DESTINATION END (IMPROVED) ===');
  }

  Future<void> _drawRouteWithOSRM() async {
    print('=== DRAWING ROUTE START ===');
    print('Current location: $_currentLatLng');
    print('Destination: $_finalDestinationLatLng');

    if (_currentLatLng == null || _finalDestinationLatLng == null) {
      print('Cannot draw route: missing coordinates');
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

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates']
              .map<LatLng>(
                  (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          print('Route coordinates count: ${coordinates.length}');

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
          _errorMessage = 'Lỗi OSRM: ${response.statusCode}';
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

  Future<void> _makePhoneCall() async {
    if (receiverPhone.isEmpty) {
      _showCallFeedback('Không có số điện thoại', Colors.red);
      return;
    }

    final String cleanPhone = receiverPhone.replaceAll(RegExp(r'[^\d]'), '');
    print('📞 Attempting to call: $cleanPhone');

    try {
      var phonePermission = await Permission.phone.status;
      if (!phonePermission.isGranted) {
        phonePermission = await Permission.phone.request();
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);

      bool launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        print('📞 ✅ Phone call launched successfully!');
        _showCallFeedback('Đang thực hiện cuộc gọi...', Colors.green);
        return;
      }

      launched = await launchUrl(
        Uri.parse('tel:$cleanPhone'),
        mode: LaunchMode.externalNonBrowserApplication,
      );

      if (launched) {
        print('📞 ✅ External phone call successful!');
        _showCallFeedback('Đang thực hiện cuộc gọi...', Colors.green);
        return;
      }

      if (Platform.isAndroid) {
        launched = await launchUrl(
          Uri.parse('tel:$cleanPhone'),
          mode: LaunchMode.platformDefault,
        );

        if (launched) {
          print('📞 ✅ Platform default call successful!');
          _showCallFeedback('Đang thực hiện cuộc gọi...', Colors.green);
          return;
        }
      }

      launched = await launchUrl(
        Uri.parse('tel://$cleanPhone'),
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        print('📞 ✅ Alternative URI format successful!');
        _showCallFeedback('Đang thực hiện cuộc gọi...', Colors.green);
        return;
      }

      throw Exception('All launch methods failed');
    } catch (e) {
      print('📞 ❌ All phone call methods failed: $e');
      _showCallFeedback('Không thể thực hiện cuộc gọi', Colors.red);
    }
  }

  void _showCallFeedback(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildPhoneButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () async {
          print('📞 PHONE BUTTON: Tapped!');
          _showCallFeedback('Đang chuẩn bị cuộc gọi...', Colors.blue);
          await Future.delayed(const Duration(milliseconds: 200));
          await _makePhoneCall();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _initializeDelivery();
                    },
                    child: Text('Thử lại'),
                  ),
                ],
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
                    // Back button
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
                    // Status bar
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
                    // Bottom info panel
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
                            // Customer info
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
                                  _buildPhoneButton(),
                                ],
                              ),
                            ),
                            // Order info
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                      Text(
                                        transport != null
                                            ? 'Mã đơn hàng: #${transport!.transportId}'
                                            : 'Mã đơn hàng: #JA447FB549',
                                        style: const TextStyle(
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
                                      Text(
                                        transport?.estimatedDelivery != null
                                            ? '${transport!.estimatedDelivery!.day}/${transport!.estimatedDelivery!.month}/${transport!.estimatedDelivery!.year}'
                                            : '27 August 2025',
                                        style: const TextStyle(
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
