import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/blog_bloc.dart';
import '../bloc/blog_event.dart';
import '../bloc/blog_state.dart';
import '../../../components/blog_card.dart';
import '../widgets/blog_detail.dart'; // Import the popup component

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(FetchBlogs(page: currentPage));
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
      context.read<BlogBloc>().add(FetchBlogs(page: newPage));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onBlogTap(Map<String, dynamic> blog) {
    final blogId = blog['blogId'];
    if (blogId != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => BlogDetailPopup(blogId: blogId),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể tải chi tiết blog'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
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
              color: isActive ? const Color(0xFF1D7020) : Colors.white,
              border: Border.all(
                color:
                    isActive ? const Color(0xFF1D7020) : Colors.grey.shade300,
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

    // Previous button
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
                color: currentPage > 1 ? const Color(0xFF1D7020) : Colors.grey,
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

    // Next button
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
                color: currentPage < totalPages
                    ? const Color(0xFF1D7020)
                    : Colors.grey,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        title: const Text('Blog'),
        elevation: 0,
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red.shade600,
                action: SnackBarAction(
                  label: 'Thử lại',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<BlogBloc>().add(FetchBlogs(page: currentPage));
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1D7020)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải blog...',
                    style: TextStyle(
                      color: Color(0xFF1D7020),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is BlogLoaded) {
            final blogs = state.blogs;

            if (blogs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không có blog nào',
                      style: TextStyle(
                        color: Color(0xFF1D7020),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy quay lại sau để xem nội dung mới',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<BlogBloc>()
                            .add(FetchBlogs(page: currentPage));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7020),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF1D7020),
                    onRefresh: () async {
                      context
                          .read<BlogBloc>()
                          .add(FetchBlogs(page: currentPage));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: blogs.length,
                      itemBuilder: (context, index) {
                        return BlogCard(
                          blog: blogs[index],
                          onTap: () => _onBlogTap(blogs[index]),
                        );
                      },
                    ),
                  ),
                ),
                _buildPaginationControls(state.totalPages),
              ],
            );
          } else if (state is BlogError) {
            return Center(
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
                      color: Colors.red.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<BlogBloc>()
                          .add(FetchBlogs(page: currentPage));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7020),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
