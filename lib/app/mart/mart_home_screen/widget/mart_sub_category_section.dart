import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/models/mart_subcategory_model.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/mart_controller.dart' show MartController;

class MartSubcategoriesSection extends StatelessWidget {
  final double screenWidth;

  const MartSubcategoriesSection({super.key, required this.screenWidth});

  /// Get appropriate icon for subcategory based on name
  IconData _getSubcategoryIcon(String subcategoryName) {
    final name = subcategoryName.toLowerCase();

    if (name.contains('veggie') || name.contains('vegetable')) {
      return Icons.eco;
    } else if (name.contains('spice')) {
      return Icons.emoji_food_beverage;
    } else if (name.contains('oil')) {
      return Icons.opacity;
    } else if (name.contains('dal') || name.contains('pulse')) {
      return Icons.grain;
    } else if (name.contains('rice')) {
      return Icons.rice_bowl;
    } else if (name.contains('atta') || name.contains('flour')) {
      return Icons.grain;
    } else if (name.contains('fruit')) {
      return Icons.apple;
    } else if (name.contains('milk') || name.contains('dairy')) {
      return Icons.local_drink;
    } else if (name.contains('bread') || name.contains('bakery')) {
      return Icons.bakery_dining;
    } else if (name.contains('snack') || name.contains('chips')) {
      return Icons.fastfood;
    } else if (name.contains('beverage') || name.contains('drink')) {
      return Icons.local_cafe;
    } else if (name.contains('personal') || name.contains('care')) {
      return Icons.spa;
    } else if (name.contains('baby') || name.contains('care')) {
      return Icons.child_friendly;
    } else if (name.contains('pet') || name.contains('animal')) {
      return Icons.pets;
    } else {
      return Icons.shopping_basket;
    }
  }

  /// Get gradient background based on subcategory
  List<Color> _getSubcategoryGradient(String subcategoryName) {
    final name = subcategoryName.toLowerCase();

    if (name.contains('veggie') || name.contains('vegetable')) {
      return [const Color(0xFFE8F5E8), const Color(0xFFC8E6C9)];
    } else if (name.contains('fruit')) {
      return [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
    } else if (name.contains('dairy') || name.contains('milk')) {
      return [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)];
    } else if (name.contains('spice')) {
      return [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)];
    } else if (name.contains('bakery') || name.contains('bread')) {
      return [const Color(0xFFEFEBE9), const Color(0xFFD7CCC8)];
    } else {
      return [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          GetX<MartController>(
            builder: (controller) {
              final itemCount = controller.homepageSubcategories.length;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00998a),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Shop by Category',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (itemCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00998a).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$itemCount items',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00998a),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          GetX<MartController>(
            builder: (controller) {
              // Initial load
              if (controller.subcategoriesMap.isEmpty &&
                  !controller.isSubcategoryLoading.value) {
                print(
                    '[MART HOME] 🏷️ Loading first page of homepage subcategories...');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.loadFirstPageHomepageSubcategories();
                });
              }

              final homepageSubcategories = controller.homepageSubcategories;

              return Column(
                children: [
                  // Enhanced Loading Skeleton
                  if (controller.isSubcategoryLoading.value &&
                      homepageSubcategories.isEmpty)
                    _buildEnhancedLoadingSkeleton(),

                  // Enhanced Subcategories Grid
                  if (homepageSubcategories.isNotEmpty)
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: homepageSubcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = homepageSubcategories[index];
                        return _buildEnhancedSubcategoryItem(subcategory);
                      },
                    ),

                  // Enhanced Empty State
                  if (homepageSubcategories.isEmpty &&
                      !controller.isSubcategoryLoading.value)
                    _buildEnhancedEmptyState(controller),

                  // Enhanced Pagination Controls
                  if (homepageSubcategories.isNotEmpty)
                    _buildEnhancedPaginationControls(controller),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build enhanced loading skeleton with shimmer effect simulation
  Widget _buildEnhancedLoadingSkeleton() {
    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
              (index) => Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build enhanced empty state
  Widget _buildEnhancedEmptyState(MartController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Categories Available',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new categories',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.loadFirstPageHomepageSubcategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00998a),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Refresh Categories',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced pagination controls
  Widget _buildEnhancedPaginationControls(MartController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // Loading more indicator
          if (controller.isSubcategoryLoading.value)
            Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00998a),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Loading more categories...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          else if (controller.hasMoreSubcategories)
          // Enhanced View More button
            ElevatedButton(
              onPressed: () {
                controller.loadMoreHomepageSubcategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00998a),
                elevation: 2,
                shadowColor: const Color(0xFF00998a).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF00998a).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Load More Categories',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.expand_more, size: 18),
                ],
              ),
            )
          else
          // No more items message
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Color(0xFF00998a),
                ),
                SizedBox(width: 8),
                Text(
                  'All categories loaded',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color(0xFF00998a),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

          // Enhanced Page info
          const SizedBox(height: 12),
          Text(
            '${controller.loadedSubcategoriesCount} categories available',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced individual subcategory item with better UI
  Widget _buildEnhancedSubcategoryItem(MartSubcategoryModel subcategory) {
    final gradientColors = _getSubcategoryGradient(subcategory.title ?? '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {
          if (subcategory.parentCategoryId != null &&
              subcategory.parentCategoryId!.isNotEmpty) {
            Get.to(() => const MartCategoryDetailScreen(), arguments: {
              'categoryId': subcategory.parentCategoryId!,
              'categoryName': subcategory.parentCategoryTitle ?? 'Category',
              'subcategoryId': subcategory.id ?? '',
            });
          } else {
            print(
                '[MART HOME] 🏷️ Warning: Subcategory ${subcategory.title} has no parent category ID');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Enhanced Category Card with shadow and gradient
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background pattern
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradientColors[0].withOpacity(0.8),
                            gradientColors[1].withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),

                    // Image or Icon
                    Center(
                      child: (subcategory.validImageUrl.isNotEmpty ||
                          (subcategory.photo != null &&
                              subcategory.photo!.isNotEmpty))
                          ? NetworkImageWidget(
                        imageUrl: subcategory.validImageUrl.isNotEmpty
                            ? subcategory.validImageUrl
                            : subcategory.photo!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: Icon(
                            _getSubcategoryIcon(subcategory.title ?? ''),
                            color: const Color(0xFF00998a),
                            size: 24,
                          ),
                        ),
                      )
                          : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Icon(
                          _getSubcategoryIcon(subcategory.title ?? ''),
                          color: const Color(0xFF00998a),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Enhanced Text Container
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  SizedBox(
                    height: 28, // enough for up to 2 lines
                    child: Text(
                      subcategory.title ?? 'Category',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00998a).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
// import 'package:customer/models/mart_subcategory_model.dart';
// import 'package:customer/utils/network_image_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controller/mart_controller.dart' show MartController;
//
// class MartSubcategoriesSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartSubcategoriesSection({super.key, required this.screenWidth});
//
//   /// Get appropriate icon for subcategory based on name
//   IconData _getSubcategoryIcon(String subcategoryName) {
//     final name = subcategoryName.toLowerCase();
//
//     if (name.contains('veggie') || name.contains('vegetable')) {
//       return Icons.eco;
//     } else if (name.contains('spice')) {
//       return Icons.local_dining;
//     } else if (name.contains('oil')) {
//       return Icons.opacity;
//     } else if (name.contains('dal') || name.contains('pulse')) {
//       return Icons.grain;
//     } else if (name.contains('rice')) {
//       return Icons.grain;
//     } else if (name.contains('atta') || name.contains('flour')) {
//       return Icons.grain;
//     } else if (name.contains('fruit')) {
//       return Icons.apple;
//     } else if (name.contains('milk') || name.contains('dairy')) {
//       return Icons.local_drink;
//     } else if (name.contains('bread') || name.contains('bakery')) {
//       return Icons.local_dining;
//     } else if (name.contains('snack') || name.contains('chips')) {
//       return Icons.fastfood;
//     } else if (name.contains('beverage') || name.contains('drink')) {
//       return Icons.local_cafe;
//     } else if (name.contains('personal') || name.contains('care')) {
//       return Icons.person;
//     } else if (name.contains('baby') || name.contains('care')) {
//       return Icons.child_care;
//     } else if (name.contains('pet') || name.contains('animal')) {
//       return Icons.pets;
//     } else {
//       return Icons.category;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 10,
//           ),
//           // Section Title with item count
//           GetX<MartController>(
//             builder: (controller) {
//               final itemCount = controller.homepageSubcategories.length;
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Shop by Subcategory',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                   if (itemCount > 0)
//                     Text(
//                       '($itemCount items)',
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           // Subcategories Grid with Pagination
//           GetX<MartController>(
//             builder: (controller) {
//               // Initial load
//               if (controller.subcategoriesMap.isEmpty &&
//                   !controller.isSubcategoryLoading.value) {
//                 print(
//                     '[MART HOME] 🏷️ Loading first page of homepage subcategories...');
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   controller.loadFirstPageHomepageSubcategories();
//                 });
//               }
//
//               final homepageSubcategories = controller.homepageSubcategories;
//
//               return Column(
//                 children: [
//                   // Loading skeleton
//                   if (controller.isSubcategoryLoading.value &&
//                       homepageSubcategories.isEmpty)
//                     _buildLoadingSkeleton(),
//
//                   // Subcategories Grid
//                   if (homepageSubcategories.isNotEmpty)
//                     GridView.builder(
//                       padding: EdgeInsets.zero,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         crossAxisSpacing: 8,
//                         mainAxisSpacing: 16,
//                         childAspectRatio: 0.75,
//                       ),
//                       itemCount: homepageSubcategories.length,
//                       itemBuilder: (context, index) {
//                         final subcategory = homepageSubcategories[index];
//                         return _buildSubcategoryItem(subcategory);
//                       },
//                     ),
//
//                   // Empty State
//                   if (homepageSubcategories.isEmpty &&
//                       !controller.isSubcategoryLoading.value)
//                     _buildEmptyState(controller),
//
//                   // Pagination Controls
//                   if (homepageSubcategories.isNotEmpty)
//                     _buildPaginationControls(controller),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Build loading skeleton
//   Widget _buildLoadingSkeleton() {
//     return SizedBox(
//       height: 140,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(
//           4,
//           (index) => Column(
//             children: [
//               Container(
//                 width: 87,
//                 height: 81.54,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: 87,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Build empty state
//   Widget _buildEmptyState(MartController controller) {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         const Text(
//           'No subcategories available',
//           style: TextStyle(
//             fontFamily: 'Montserrat',
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () {
//             controller.loadFirstPageHomepageSubcategories();
//           },
//           child: const Text('Retry Loading'),
//         ),
//       ],
//     );
//   }
//
//   /// Build pagination controls
//   Widget _buildPaginationControls(MartController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 10),
//       child: Column(
//         children: [
//           // Loading more indicator
//           if (controller.isSubcategoryLoading.value)
//             const Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 10),
//                 Text(
//                   'Loading more subcategories...',
//                   style: TextStyle(
//                     fontFamily: 'Montserrat',
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             )
//           else if (controller.hasMoreSubcategories)
//             // View More button
//             ElevatedButton(
//               onPressed: () {
//                 controller.loadMoreHomepageSubcategories();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00998a),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: const Text(
//                 'View More',
//                 style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             )
//           else
//             // No more items message
//             const Text(
//               'All subcategories loaded',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 12,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//
//           // Page info
//           const SizedBox(height: 8),
//           Text(
//             'Loaded ${controller.loadedSubcategoriesCount} subcategories',
//             style: const TextStyle(
//               fontFamily: 'Montserrat',
//               fontSize: 11,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Build individual subcategory item
//   Widget _buildSubcategoryItem(MartSubcategoryModel subcategory) {
//     return InkWell(
//       onTap: () {
//         if (subcategory.parentCategoryId != null &&
//             subcategory.parentCategoryId!.isNotEmpty) {
//           Get.to(() => const MartCategoryDetailScreen(), arguments: {
//             'categoryId': subcategory.parentCategoryId!,
//             'categoryName': subcategory.parentCategoryTitle ?? 'Category',
//             'subcategoryId': subcategory.id ?? '',
//           });
//         } else {
//           print(
//               '[MART HOME] 🏷️ Warning: Subcategory ${subcategory.title} has no parent category ID');
//         }
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 87,
//             height: 81.54,
//             decoration: BoxDecoration(
//               color: const Color(0xFFECEAFD),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(18),
//               child: (subcategory.validImageUrl.isNotEmpty ||
//                       (subcategory.photo != null &&
//                           subcategory.photo!.isNotEmpty))
//                   ? NetworkImageWidget(
//                       imageUrl: subcategory.validImageUrl.isNotEmpty
//                           ? subcategory.validImageUrl
//                           : subcategory.photo!,
//                       width: 87,
//                       height: 81.54,
//                       fit: BoxFit.cover,
//                       errorWidget: Container(
//                         width: 87,
//                         height: 81.54,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFECEAFD),
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Icon(
//                           _getSubcategoryIcon(subcategory.title ?? ''),
//                           color: const Color(0xFF00998a),
//                           size: 32,
//                         ),
//                       ),
//                     )
//                   : Container(
//                       width: 87,
//                       height: 81.54,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFECEAFD),
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: Icon(
//                         _getSubcategoryIcon(subcategory.title ?? ''),
//                         color: const Color(0xFF00998a),
//                         size: 32,
//                       ),
//                     ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 87,
//             child: Text(
//               subcategory.title ?? 'Subcategory',
//               style: const TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 height: 1.2,
//                 color: Color(0xFF000000),
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
