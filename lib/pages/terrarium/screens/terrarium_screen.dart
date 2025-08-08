import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/terrarium_bloc.dart';
import '../bloc/terrarium_event.dart';
import '../bloc/terrarium_state.dart';
import '../../../components/terrarium_cart.dart';
import '../../../navigation/routes.dart';

class TerrariumScreen extends StatefulWidget {
  const TerrariumScreen({super.key});

  @override
  State<TerrariumScreen> createState() => _TerrariumScreenState();
}

class _TerrariumScreenState extends State<TerrariumScreen> {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  String? _selectedEnvironment;
  String? _selectedShape;
  String? _selectedTankMethod;
  List<Map<String, dynamic>> environments = [];
  List<Map<String, dynamic>> shapes = [];
  List<Map<String, dynamic>> tankMethods = [];
  bool _referencesLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<TerrariumBloc>().add(FetchTerrariumReferences());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changePage(int newPage) {
    if (newPage != currentPage) {
      setState(() {
        currentPage = newPage;
      });
      if (_selectedEnvironment != null ||
          _selectedShape != null ||
          _selectedTankMethod != null) {
        context.read<TerrariumBloc>().add(FilterTerrariums(
              environmentName: _selectedEnvironment,
              shapeName: _selectedShape,
              tankMethodType: _selectedTankMethod,
              page: newPage,
            ));
      } else {
        context.read<TerrariumBloc>().add(FetchTerrariums(page: newPage));
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _navigateToTerrariumDetail(Map<String, dynamic> terrarium) {
    // Get terrarium ID from the terrarium data
    final terrariumId = terrarium['terrariumId']?.toString() ??
        terrarium['id']?.toString() ??
        '';

    if (terrariumId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        Routes.terrariumDetail,
        arguments: terrariumId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở chi tiết terrarium - thiếu ID'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFilterDialog() {
    if (!_referencesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải dữ liệu bộ lọc...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String? tempSelectedEnvironment = _selectedEnvironment;
        String? tempSelectedShape = _selectedShape;
        String? tempSelectedTankMethod = _selectedTankMethod;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Lọc Terrarium'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Môi trường'),
                      value: tempSelectedEnvironment,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('-- Chọn môi trường --'),
                        ),
                        ...environments.map((env) {
                          return DropdownMenuItem<String>(
                            value: env['environmentName'] as String?,
                            child: Text(env['environmentName']?.toString() ??
                                'Unknown'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSelectedEnvironment = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Hình dạng'),
                      value: tempSelectedShape,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('-- Chọn hình dạng --'),
                        ),
                        ...shapes.map((shape) {
                          return DropdownMenuItem<String>(
                            value: shape['shapeName'] as String?,
                            child: Text(
                                shape['shapeName']?.toString() ?? 'Unknown'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSelectedShape = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Phương pháp bể'),
                      value: tempSelectedTankMethod,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('-- Chọn phương pháp --'),
                        ),
                        ...tankMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method['tankMethodType'] as String?,
                            child: Text(method['tankMethodType']?.toString() ??
                                'Unknown'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSelectedTankMethod = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedEnvironment = null;
                      _selectedShape = null;
                      _selectedTankMethod = null;
                      currentPage = 1;
                    });
                    context.read<TerrariumBloc>().add(FetchTerrariums(page: 1));
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedEnvironment = tempSelectedEnvironment;
                      _selectedShape = tempSelectedShape;
                      _selectedTankMethod = tempSelectedTankMethod;
                      currentPage = 1;
                    });
                    context.read<TerrariumBloc>().add(FilterTerrariums(
                          environmentName: _selectedEnvironment,
                          shapeName: _selectedShape,
                          tankMethodType: _selectedTankMethod,
                          page: 1,
                        ));
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationButton(int page, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        elevation: isActive ? 4 : 1,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isActive ? null : () => _changePage(page),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? Colors.green : Colors.white,
              border: Border.all(
                color: isActive ? Colors.green : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox();

    List<Widget> paginationItems = [];
    paginationItems.add(
      Container(
        margin: const EdgeInsets.only(right: 8),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: currentPage > 1 ? () => _changePage(currentPage - 1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_left,
                color: currentPage > 1 ? Colors.green : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );

    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > 5) {
      if (currentPage <= 3) {
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    if (startPage > 1) {
      paginationItems.add(_buildPaginationButton(1));
      if (startPage > 2) {
        paginationItems.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      paginationItems
          .add(_buildPaginationButton(i, isActive: i == currentPage));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        paginationItems.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      paginationItems.add(_buildPaginationButton(totalPages));
    }

    paginationItems.add(
      Container(
        margin: const EdgeInsets.only(left: 8),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: currentPage < totalPages
                ? () => _changePage(currentPage + 1)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_right,
                color: currentPage < totalPages ? Colors.green : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: paginationItems,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trang $currentPage / $totalPages',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Tất cả Terrarium',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, size: 20),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: BlocConsumer<TerrariumBloc, TerrariumState>(
        listener: (context, state) {
          if (state is TerrariumReferencesLoaded) {
            setState(() {
              environments = state.environments;
              shapes = state.shapes;
              tankMethods = state.tankMethods;
              _referencesLoaded = true;
            });
            if (environments.isEmpty || shapes.isEmpty || tankMethods.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Không tải được dữ liệu bộ lọc, vui lòng thử lại.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            context
                .read<TerrariumBloc>()
                .add(FetchTerrariums(page: currentPage));
          } else if (state is TerrariumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TerrariumLoading && !_referencesLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu tham chiếu...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is TerrariumLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải terrarium...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is TerrariumLoaded) {
            final terrariums = state.terrariums;

            if (terrariums.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có terrarium nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy thử lại sau hoặc kiểm tra kết nối mạng',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tìm thấy ${state.totalItems} terrarium',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedEnvironment != null ||
                          _selectedShape != null ||
                          _selectedTankMethod != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEnvironment = null;
                              _selectedShape = null;
                              _selectedTankMethod = null;
                              currentPage = 1;
                            });
                            context
                                .read<TerrariumBloc>()
                                .add(FetchTerrariums(page: 1));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Xóa bộ lọc',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close,
                                    size: 12, color: Colors.red.shade700),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.green,
                    onRefresh: () async {
                      if (_selectedEnvironment != null ||
                          _selectedShape != null ||
                          _selectedTankMethod != null) {
                        context.read<TerrariumBloc>().add(FilterTerrariums(
                              environmentName: _selectedEnvironment,
                              shapeName: _selectedShape,
                              tankMethodType: _selectedTankMethod,
                              page: currentPage,
                            ));
                      } else {
                        context
                            .read<TerrariumBloc>()
                            .add(FetchTerrariums(page: currentPage));
                      }
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: terrariums.length,
                      itemBuilder: (context, index) {
                        final terrarium = terrariums[index];
                        return Hero(
                          tag: 'terrarium_${terrarium['terrariumId'] ?? index}',
                          child: TerrariumCard(
                            terrarium: terrarium,
                            onTap: () => _navigateToTerrariumDetail(terrarium),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildPaginationControls(state.totalPages),
              ],
            );
          } else if (state is TerrariumError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!_referencesLoaded) {
                          context
                              .read<TerrariumBloc>()
                              .add(FetchTerrariumReferences());
                        } else if (_selectedEnvironment != null ||
                            _selectedShape != null ||
                            _selectedTankMethod != null) {
                          context.read<TerrariumBloc>().add(FilterTerrariums(
                                environmentName: _selectedEnvironment,
                                shapeName: _selectedShape,
                                tankMethodType: _selectedTankMethod,
                                page: currentPage,
                              ));
                        } else {
                          context
                              .read<TerrariumBloc>()
                              .add(FetchTerrariums(page: currentPage));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
