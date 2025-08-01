import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../pages/terrarium/bloc/terrarium_bloc.dart';
import '../pages/terrarium/bloc/terrarium_event.dart';

class TerrariumMenuFilter extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFilterApplied;

  const TerrariumMenuFilter({super.key, this.onFilterApplied});

  @override
  State<TerrariumMenuFilter> createState() => _TerrariumMenuFilterState();
}

class _TerrariumMenuFilterState extends State<TerrariumMenuFilter> {
  List<Map<String, dynamic>> environments = [];
  List<Map<String, dynamic>> shapes = [];
  List<Map<String, dynamic>> tankMethods = [];
  bool _isLoading = true;
  int? _selectedEnvironmentId;
  int? _selectedShapeId;
  int? _selectedTankMethodId;

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {
    setState(() => _isLoading = true);
    try {
      final envResponse = await http.get(Uri.parse('/api/Environment/get-all'),
          headers: {'Content-Type': 'application/json'});
      final shapeResponse = await http.get(Uri.parse('/api/Shape/get-all'),
          headers: {'Content-Type': 'application/json'});
      final tankResponse = await http.get(Uri.parse('/api/TankMethod/get-all'),
          headers: {'Content-Type': 'application/json'});

      if (envResponse.statusCode == 200 &&
          shapeResponse.statusCode == 200 &&
          tankResponse.statusCode == 200) {
        final envData = jsonDecode(envResponse.body);
        final shapeData = jsonDecode(shapeResponse.body);
        final tankData = jsonDecode(tankResponse.body);

        if (envData['status'] == 200 && envData['data'] is List) {
          environments = List<Map<String, dynamic>>.from(envData['data']);
        }
        if (shapeData['status'] == 200 && shapeData['data'] is List) {
          shapes = List<Map<String, dynamic>>.from(shapeData['data']);
        }
        if (tankData['status'] == 200 && tankData['data'] is List) {
          tankMethods = List<Map<String, dynamic>>.from(tankData['data']);
        }
      } else {
        developer.log(
            'Failed to load references: Env(${envResponse.statusCode}), Shape(${shapeResponse.statusCode}), Tank(${tankResponse.statusCode})',
            name: 'TerrariumMenuFilter');
      }
    } catch (e) {
      developer.log('Exception during reference fetch: $e',
          name: 'TerrariumMenuFilter');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (widget.onFilterApplied != null) {
      widget.onFilterApplied!({
        'environmentId': _selectedEnvironmentId,
        'shapeId': _selectedShapeId,
        'tankMethodId': _selectedTankMethodId,
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lọc Terrarium'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Môi trường'),
                    value: _selectedEnvironmentId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('-- Chọn môi trường --'),
                      ),
                      ...environments.map((env) {
                        return DropdownMenuItem<int>(
                          value: env['environmentId'] as int?,
                          child: Text(
                              env['environmentName']?.toString() ?? 'Unknown'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedEnvironmentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Hình dạng'),
                    value: _selectedShapeId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('-- Chọn hình dạng --'),
                      ),
                      ...shapes.map((shape) {
                        return DropdownMenuItem<int>(
                          value: shape['shapeId'] as int?,
                          child:
                              Text(shape['shapeName']?.toString() ?? 'Unknown'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedShapeId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration:
                        const InputDecoration(labelText: 'Phương pháp bể'),
                    value: _selectedTankMethodId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('-- Chọn phương pháp --'),
                      ),
                      ...tankMethods.map((method) {
                        return DropdownMenuItem<int>(
                          value: method['tankMethodId'] as int?,
                          child: Text(method['tankMethodType']?.toString() ??
                              'Unknown'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTankMethodId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedEnvironmentId = null;
              _selectedShapeId = null;
              _selectedTankMethodId = null;
            });
            _applyFilter();
          },
          child: const Text('Xóa bộ lọc'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _applyFilter,
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
