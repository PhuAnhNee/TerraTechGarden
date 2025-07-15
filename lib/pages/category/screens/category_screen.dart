import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../../authentication/bloc/auth_bloc.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryBloc(authBloc: context.read<AuthBloc>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          backgroundColor: const Color(0xFF1D7020),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategoriesEvent());
              },
              tooltip: 'Refresh Categories',
            ),
          ],
        ),
        body: BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryDetailsLoaded) {
              _showCategoryDetailsModal(context);
            } else if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoryLoaded) {
                if (state.categories.isEmpty) {
                  return const Center(child: Text('No categories available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        leading: const Icon(
                          Icons.category,
                          color: Color(0xFF4CAF50),
                          size: 30.0,
                        ),
                        title: Text(
                          category['name']?.toString() ?? 'Unnamed Category',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          final id = category['id']?.toString();
                          if (id != null) {
                            context
                                .read<CategoryBloc>()
                                .add(LoadCategoryByIdEvent(id));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Category ID not found')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              } else if (state is CategoryError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Center(child: Text('No categories available'));
            },
          ),
        ),
      ),
    );
  }

  void _showCategoryDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoryDetailsLoaded) {
                      final category = state.category;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              category['name']?.toString() ??
                                  'Category Details',
                              style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D7020),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'ID: ${category['id']?.toString() ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.black87),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Description: ${category['description']?.toString() ?? 'No description available'}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.black87),
                          ),
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D7020),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Close',
                                style: TextStyle(fontSize: 16.0)),
                          ),
                        ],
                      );
                    }
                    return const Center(child: Text('No details available'));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
