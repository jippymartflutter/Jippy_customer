
import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/utils/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MartCategoriesScreen extends StatefulWidget {
  const MartCategoriesScreen({super.key});

  @override
  State<MartCategoriesScreen> createState() => _MartCategoriesScreenState();
}

class _MartCategoriesScreenState extends State<MartCategoriesScreen> {
  late MartController _martController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _martController = Get.find<MartController>();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _martController.loadCategoriesStreaming();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      await _loadCategories();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      await _martController.searchCategories(query);
    } catch (e) {
      print('Error searching categories: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background for grocery app
      body: Column(
        children: [
          // Enhanced Header with gradient and better shadow
          Container(
            width: screenWidth,
            height: screenWidth < 480
                ? 140 + statusBarHeight
                : 150 + statusBarHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConst.martPrimary,
                  ColorConst.martPrimary.withOpacity(0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Enhanced Search Bar with elevation
                Positioned(
                  left: 20,
                  top: screenWidth < 480
                      ? 80 + statusBarHeight
                      :80 + statusBarHeight,
                  child: Container(
                    width: screenWidth - 40,
                    height: screenWidth < 480 ? 52 : 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.search_rounded,
                            color: const Color(0xFF6B6B6B),
                            size: screenWidth < 480 ? 22 : 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              Future.delayed(const Duration(milliseconds: 500),
                                      () {
                                    if (_searchController.text == value) {
                                      _performSearch(value);
                                    }
                                  });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search grocery categories...',
                              hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: screenWidth < 480 ? 15 : 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8F8F8F),
                                height: screenWidth < 480 ? 18 / 15 : 20 / 16,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: screenWidth < 480 ? 15 : 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: screenWidth < 480 ? 18 / 15 : 20 / 16,
                            ),
                          ),
                        ),
                        if (_isSearching || _searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.clear_rounded,
                                  color: const Color(0xFF6B6B6B),
                                  size: screenWidth < 480 ? 18 : 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Title with better typography
                Positioned(
                  left: 0,
                  right: 0,
                  top: screenWidth < 480
                      ? 20 + statusBarHeight
                      : 24 + statusBarHeight,
                  child: Column(
                    children: [
                      Text(
                        _isSearching ? 'Search Results' : 'Grocery Categories',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: screenWidth < 480 ? 20 : 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSearching
                            ? 'Found in our grocery store'
                            : 'Browse all categories',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: screenWidth < 480 ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: GetX<MartController>(
                builder: (controller) {
                  if (controller.isCategoryLoading.value) {
                    return _buildLoadingState();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState();
                  }

                  if (controller.martCategories.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    backgroundColor: Colors.white,
                    color: MartTheme.jippyMartButton,
                    onRefresh: _loadCategories,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: _buildCategoriesBySections(controller.martCategories),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MartTheme.jippyMartButton.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: MartTheme.jippyMartButton,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your grocery items ready',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your internet connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: MartTheme.jippyMartButton,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: MartTheme.jippyMartButton.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSearching ? Icons.search_off_rounded : Icons.category_rounded,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isSearching ? 'No Categories Found' : 'No Categories Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? 'Try different search terms or browse all categories'
                  : 'Categories will appear here once available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            if (_isSearching)
              ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MartTheme.jippyMartButton,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Search'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBySections(List<MartCategoryModel> categories) {
    Map<String, List<MartCategoryModel>> sections = {};
    Map<String, int> sectionOrders = {};

    for (var category in categories) {
      String sectionName = category.section ?? 'Other';
      if (!sections.containsKey(sectionName)) {
        sections[sectionName] = [];
        sectionOrders[sectionName] = category.sectionOrder ?? 999;
      }
      sections[sectionName]!.add(category);
    }

    List<String> sortedSections = sections.keys.toList()
      ..sort((a, b) => (sectionOrders[a] ?? 999).compareTo(sectionOrders[b] ?? 999));

    return Column(
      children: [
        ...sortedSections.asMap().entries.map((entry) {
          final index = entry.key;
          final sectionName = entry.value;
          final sectionCategories = sections[sectionName]!;

          return Column(
            children: [
              if (index > 0) const SizedBox(height: 12),
              _buildSection(sectionName, sectionCategories),
            ],
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String sectionName, List<MartCategoryModel> sectionCategories) {
    sectionCategories.sort((a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;
        double crossAxisSpacing;
        double mainAxisSpacing;

        if (screenWidth < 360) {
          crossAxisCount = 3;
          childAspectRatio = 0.85;
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else if (screenWidth < 480) {
          crossAxisCount = 4;
          childAspectRatio = 0.8;
          crossAxisSpacing = 14;
          mainAxisSpacing = 14;
        } else if (screenWidth < 600) {
          crossAxisCount = 4;
          childAspectRatio = 0.75;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
        } else if (screenWidth < 900) {
          crossAxisCount = 5;
          childAspectRatio = 0.7;
          crossAxisSpacing = 18;
          mainAxisSpacing = 18;
        } else {
          crossAxisCount = 6;
          childAspectRatio = 0.65;
          crossAxisSpacing = 20;
          mainAxisSpacing = 20;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Section Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                sectionName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenWidth < 480 ? 14 : 15,
                  fontWeight: FontWeight.w700,
                  color: MartTheme.jippyMartButton,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Enhanced Categories Grid with better cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: sectionCategories.length,
              itemBuilder: (context, index) {
                final category = sectionCategories[index];
                return _buildCategoryCard(category, screenWidth);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(MartCategoryModel category, double screenWidth) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.to(() => const MartCategoryDetailScreen(), arguments: {
            'categoryId': category.id,
            'categoryName': category.title ?? 'Category',
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced Image Container
              Container(
                width: screenWidth < 480 ? 50 : 56,
                height: screenWidth < 480 ? 50 : 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFE), // Slightly darker purple for better contrast
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: MartTheme.jippyMartButton.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: category.photo != null && category.photo!.isNotEmpty
                      ? NetworkImageWidget(
                    imageUrl: category.photo!,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: const Color(0xFFF0EFFE),
                      child: Icon(
                        Icons.category_rounded,
                        size: screenWidth < 480 ? 22 : 24,
                        color: MartTheme.jippyMartButton,
                      ),
                    ),
                  )
                      : Container(
                    color: const Color(0xFFF0EFFE),
                    child: Icon(
                      Icons.category_rounded,
                      size: screenWidth < 480 ? 22 : 24,
                      color: MartTheme.jippyMartButton,
                    ),
                  ),
                ),
              ),

              // Enhanced Text Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  category.title ?? 'Category',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: screenWidth < 480 ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
// import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
// import 'package:customer/models/mart_category_model.dart';
// import 'package:customer/themes/app_them_data.dart';
// import 'package:customer/themes/mart_theme.dart';
// import 'package:customer/utils/network_image_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class MartCategoriesScreen extends StatefulWidget {
//   const MartCategoriesScreen({super.key});
//
//   @override
//   State<MartCategoriesScreen> createState() => _MartCategoriesScreenState();
// }
//
// class _MartCategoriesScreenState extends State<MartCategoriesScreen> {
//   late MartController _martController;
//   late TextEditingController _searchController;
//   bool _isSearching = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _martController = Get.find<MartController>();
//     _searchController = TextEditingController();
//
//     // Add a small delay to ensure controller is fully initialized
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadCategories();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadCategories() async {
//     try {
//       // Add a small delay to prevent race conditions
//       await Future.delayed(const Duration(milliseconds: 500));
//       // Use Firestore instead of API
//       await _martController.loadCategoriesStreaming();
//     } catch (e) {
//       print('Error loading categories: $e');
//     }
//   }
//
//   Future<void> _performSearch(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _isSearching = false;
//       });
//       await _loadCategories();
//       return;
//     }
//
//     setState(() {
//       _isSearching = true;
//     });
//
//     try {
//       await _martController.searchCategories(query);
//     } catch (e) {
//       print('Error searching categories: $e');
//     }
//   }
//
//   void _clearSearch() {
//     _searchController.clear();
//     setState(() {
//       _isSearching = false;
//     });
//     _loadCategories();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final statusBarHeight = MediaQuery.of(context).padding.top;
//
//     return Scaffold(
//       backgroundColor:
//           AppThemeData.homeScreenBackground, // Reusable home screen background
//       body: Column(
//         children: [
//           // Header with gradient background - Fill entire top area
//           Container(
//             width: screenWidth,
//             height: screenWidth < 480
//                 ? 120 + statusBarHeight
//                 : 136 + statusBarHeight, // Responsive height
//             decoration: const BoxDecoration(
//               color:
//                   MartTheme.jippyMartButton, // Use solid jippyMartButton color
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Search bar container - Responsive width
//                 Positioned(
//                   left: 16,
//                   top: screenWidth < 480
//                       ? 56 + statusBarHeight
//                       : 64 + statusBarHeight, // Responsive top position
//                   child: Container(
//                     width: screenWidth - 32, // Responsive width
//                     height: screenWidth < 480 ? 48 : 52, // Responsive height
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(80),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(width: screenWidth < 480 ? 16 : 19),
//                         Icon(Icons.search,
//                             color: const Color(0xFF6B6B6B),
//                             size: screenWidth < 480 ? 20 : 24),
//                         SizedBox(width: screenWidth < 480 ? 10 : 12),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             onChanged: (value) {
//                               // Debounce search to avoid too many API calls
//                               Future.delayed(const Duration(milliseconds: 500),
//                                   () {
//                                 if (_searchController.text == value) {
//                                   _performSearch(value);
//                                 }
//                               });
//                             },
//                             decoration: InputDecoration(
//                               hintText: 'Search in Categories...',
//                               hintStyle: TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontSize: screenWidth < 480 ? 14 : 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xFF6B6B6B),
//                                 height: screenWidth < 480 ? 18 / 14 : 20 / 16,
//                               ),
//                               border: InputBorder.none,
//                               enabledBorder: InputBorder.none,
//                               focusedBorder: InputBorder.none,
//                               errorBorder: InputBorder.none,
//                               focusedErrorBorder: InputBorder.none,
//                               disabledBorder: InputBorder.none,
//                               contentPadding: EdgeInsets.zero,
//                               isDense: true,
//                             ),
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: screenWidth < 480 ? 14 : 16,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black,
//                               height: screenWidth < 480 ? 18 / 14 : 20 / 16,
//                             ),
//                           ),
//                         ),
//                         if (_isSearching || _searchController.text.isNotEmpty)
//                           GestureDetector(
//                             onTap: _clearSearch,
//                             child: Icon(
//                               Icons.clear,
//                               color: const Color(0xFF6B6B6B),
//                               size: screenWidth < 480 ? 18 : 20,
//                             ),
//                           ),
//                         SizedBox(width: screenWidth < 480 ? 16 : 20),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Title - positioned absolutely
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   top: screenWidth < 480
//                       ? 16 + statusBarHeight
//                       : 20 + statusBarHeight, // Responsive top position
//                   child: Text(
//                     _isSearching ? 'Search Results' : 'All Categories',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: screenWidth < 480 ? 18 : 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Scrollable content with proper constraints
//           Expanded(
//             child: GetX<MartController>(
//               builder: (controller) {
//                 if (controller.isCategoryLoading.value) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF5D56F3),
//                     ),
//                   );
//                 }
//
//                 if (controller.errorMessage.value.isNotEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           size: 64,
//                           color: Colors.orange,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Unable to load categories',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Please check your connection and try again',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _loadCategories,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF5D56F3),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Retry',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 if (controller.martCategories.isEmpty) {
//                   // Show different messages based on whether we're searching or not
//                   if (_isSearching) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.search_off,
//                             size: 64,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No categories found',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Try searching with different keywords',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton(
//                             onPressed: _clearSearch,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF5D56F3),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                                 vertical: 12,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text('Clear Search'),
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.category_outlined,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No categories available',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 }
//
//                 return RefreshIndicator(
//                   onRefresh: _loadCategories,
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.zero,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 14),
//                       child:
//                           _buildCategoriesBySections(controller.martCategories),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoriesBySections(List<MartCategoryModel> categories) {
//     // Group categories by section
//     Map<String, List<MartCategoryModel>> sections = {};
//     Map<String, int> sectionOrders = {};
//
//     for (var category in categories) {
//       String sectionName = category.section ?? 'Other';
//       if (!sections.containsKey(sectionName)) {
//         sections[sectionName] = [];
//         sectionOrders[sectionName] = category.sectionOrder ??
//             999; // Default high order for sections without order
//       }
//       sections[sectionName]!.add(category);
//     }
//
//     // Sort sections by section_order field
//     List<String> sortedSections = sections.keys.toList()
//       ..sort((a, b) =>
//           (sectionOrders[a] ?? 999).compareTo(sectionOrders[b] ?? 999));
//
//     return Column(
//       children: [
//         ...sortedSections.asMap().entries.map((entry) {
//           final index = entry.key;
//           final sectionName = entry.value;
//           final sectionCategories = sections[sectionName]!;
//
//           return Column(
//             children: [
//               // Add balanced spacing between sections (except for the first one)
//               if (index > 0) const SizedBox(height: 8),
//               _buildSection(sectionName, sectionCategories),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildSection(
//       String sectionName, List<MartCategoryModel> sectionCategories) {
//     // Sort categories within section by order
//     sectionCategories
//         .sort((a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Responsive grid configuration
//         double screenWidth = constraints.maxWidth;
//         int crossAxisCount;
//         double childAspectRatio;
//         double crossAxisSpacing;
//         double mainAxisSpacing;
//
//         if (screenWidth < 360) {
//           // Small phones
//           crossAxisCount = 3;
//           childAspectRatio = 0.8;
//           crossAxisSpacing = 8;
//           mainAxisSpacing = 8;
//         } else if (screenWidth < 480) {
//           // Medium phones
//           crossAxisCount = 4;
//           childAspectRatio = 0.75;
//           crossAxisSpacing = 10;
//           mainAxisSpacing = 10;
//         } else if (screenWidth < 600) {
//           // Large phones
//           crossAxisCount = 4;
//           childAspectRatio = 0.7;
//           crossAxisSpacing = 12;
//           mainAxisSpacing = 12;
//         } else if (screenWidth < 900) {
//           // Tablets
//           crossAxisCount = 5;
//           childAspectRatio = 0.65;
//           crossAxisSpacing = 14;
//           mainAxisSpacing = 14;
//         } else {
//           // Large tablets/desktop
//           crossAxisCount = 6;
//           childAspectRatio = 0.6;
//           crossAxisSpacing = 16;
//           mainAxisSpacing = 16;
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section Header
//             Padding(
//               padding: const EdgeInsets.only(left: 6, bottom: 6),
//               child: Text(
//                 sectionName,
//                 style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: screenWidth < 480 ? 16 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             // Categories Grid
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: EdgeInsets.zero,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 childAspectRatio: childAspectRatio,
//                 crossAxisSpacing: crossAxisSpacing,
//                 mainAxisSpacing: mainAxisSpacing,
//               ),
//               itemCount: sectionCategories.length,
//               itemBuilder: (context, index) {
//                 final category = sectionCategories[index];
//                 return _buildCategoryCard(category, screenWidth);
//               },
//             ),
//             SizedBox(height: 4),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildCategoryCard(MartCategoryModel category, double screenWidth) {
//     // Fixed dimensions based on Figma specifications
//     double cardWidth = 88;
//     double imageHeight = 82.44;
//     double textHeight = 28; // Increased height for 2 lines
//     double borderRadius = 18;
//     double titleFontSize = 12;
//     double titleLineHeight = 15;
//
//     return InkWell(
//       onTap: () {
//         print('Tapped on category: ${category.title}');
//         // Navigate to category products screen
//         final currentVendorId =
//             _martController.selectedVendorId.value.isNotEmpty
//                 ? _martController.selectedVendorId.value
//                 : '';
//         final vendorName = _martController.currentVendorName;
//
//         Get.to(() => const MartCategoryDetailScreen(), arguments: {
//           'categoryId': category.id,
//           'categoryName': category.title ?? 'Category',
//         });
//       },
//       borderRadius: BorderRadius.circular(borderRadius),
//       child: Column(
//         children: [
//           // Image Container - Separate with light purple background
//           Container(
//             width: cardWidth,
//             height: imageHeight,
//             decoration: BoxDecoration(
//               color: const Color(0xFFECEAFD), // Light purple background
//               borderRadius: BorderRadius.circular(borderRadius),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(borderRadius),
//               child: category.photo != null && category.photo!.isNotEmpty
//                   ? NetworkImageWidget(
//                       imageUrl: category.photo!,
//                       fit: BoxFit.cover,
//                       errorWidget: Container(
//                         color: const Color(0xFFECEAFD),
//                         child: Icon(
//                           Icons.category,
//                           size: 24,
//                           color: const Color(0xFF5D56F3),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       color: const Color(0xFFECEAFD),
//                       child: Icon(
//                         Icons.category,
//                         size: 24,
//                         color: const Color(0xFF5D56F3),
//                       ),
//                     ),
//             ),
//           ),
//           // Text Container - No background
//           Container(
//             width: cardWidth,
//             height: textHeight,
//             // 🔑 Removed white background color
//             child: Center(
//               child: Text(
//                 category.title ?? 'Unknown Category',
//                 style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: titleFontSize,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                   height: titleLineHeight / titleFontSize,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
