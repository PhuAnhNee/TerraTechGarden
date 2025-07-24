import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DeliveryScreen extends StatefulWidget {
  final LatLng? destinationLatLng;

  const DeliveryScreen({super.key, this.destinationLatLng});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;
  List<LatLng> polylineCoordinates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndGetLocation();
  }

  Future<void> _checkAndGetLocation() async {
    print('Checking location services...');
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
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _errorMessage = null;
      });
      print('Current location: $_currentLatLng');
      if (_currentLatLng != null && _controller.isCompleted) {
        GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
      }
      if (widget.destinationLatLng != null) {
        _drawRouteWithOSRM();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Không thể lấy vị trí: $e. Vui lòng kiểm tra GPS hoặc kết nối.';
      });
      print('Location error: $e');
    }
  }

  Future<void> _drawRouteWithOSRM() async {
    if (_currentLatLng == null || widget.destinationLatLng == null) {
      print('Cannot draw route: _currentLatLng or destinationLatLng is null');
      return;
    }

    final url =
        'https://router.project-osrm.org/route/v1/driving/${_currentLatLng!.longitude},${_currentLatLng!.latitude};${widget.destinationLatLng!.longitude},${widget.destinationLatLng!.latitude}?overview=full&geometries=geojson';
    print('Requesting route from OSRM: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates']
            .map<LatLng>(
                (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
            .toList();
        setState(() {
          polylineCoordinates = coordinates;
        });
        print('OSRM route success: ${coordinates.length} points');
      } else {
        setState(() {
          _errorMessage =
              'Failed to get route from OSRM: ${response.statusCode} - ${response.body}';
        });
        print('OSRM error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to draw route: $e';
      });
      print('OSRM route error: $e');
    }
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
                    // Google Map
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
                          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
                        ),
                        if (widget.destinationLatLng != null)
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: widget.destinationLatLng!,
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

                    // Back Button
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

                    // Top Status Bar
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

                    // Bottom Panel
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
                            // Driver Info Card
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
                                        const Text(
                                          'Michael Anthony',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Car Courier',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.message,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Order Details
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
                                        '10 May 20',
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

                            // Live Tracking Button
                            Container(
                              margin: const EdgeInsets.all(16),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle live tracking
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Live Tracking',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
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
