import 'package:customer/app/mart/mart_category_detail_screen.dart';
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
      return Icons.local_dining;
    } else if (name.contains('oil')) {
      return Icons.opacity;
    } else if (name.contains('dal') || name.contains('pulse')) {
      return Icons.grain;
    } else if (name.contains('rice')) {
      return Icons.grain;
    } else if (name.contains('atta') || name.contains('flour')) {
      return Icons.grain;
    } else if (name.contains('fruit')) {
      return Icons.apple;
    } else if (name.contains('milk') || name.contains('dairy')) {
      return Icons.local_drink;
    } else if (name.contains('bread') || name.contains('bakery')) {
      return Icons.local_dining;
    } else if (name.contains('snack') || name.contains('chips')) {
      return Icons.fastfood;
    } else if (name.contains('beverage') || name.contains('drink')) {
      return Icons.local_cafe;
    } else if (name.contains('personal') || name.contains('care')) {
      return Icons.person;
    } else if (name.contains('baby') || name.contains('care')) {
      return Icons.child_care;
    } else if (name.contains('pet') || name.contains('animal')) {
      return Icons.pets;
    } else {
      return Icons.category;
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
          // Section Title with item count
          GetX<MartController>(
            builder: (controller) {
              final itemCount = controller.homepageSubcategories.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shop by Subcategory',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                  if (itemCount > 0)
                    Text(
                      '($itemCount items)',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Subcategories Grid with Pagination
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
                  // Loading skeleton
                  if (controller.isSubcategoryLoading.value &&
                      homepageSubcategories.isEmpty)
                    _buildLoadingSkeleton(),

                  // Subcategories Grid
                  if (homepageSubcategories.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: homepageSubcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = homepageSubcategories[index];
                        return _buildSubcategoryItem(subcategory);
                      },
                    ),

                  // Empty State
                  if (homepageSubcategories.isEmpty &&
                      !controller.isSubcategoryLoading.value)
                    _buildEmptyState(controller),

                  // Pagination Controls
                  if (homepageSubcategories.isNotEmpty)
                    _buildPaginationControls(controller),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingSkeleton() {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (index) => Column(
            children: [
              Container(
                width: 87,
                height: 81.54,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 87,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(MartController controller) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'No subcategories available',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            controller.loadFirstPageHomepageSubcategories();
          },
          child: const Text('Retry Loading'),
        ),
      ],
    );
  }

  /// Build pagination controls
  Widget _buildPaginationControls(MartController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        children: [
          // Loading more indicator
          if (controller.isSubcategoryLoading.value)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  'Loading more subcategories...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          else if (controller.hasMoreSubcategories)
            // View More button
            ElevatedButton(
              onPressed: () {
                controller.loadMoreHomepageSubcategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00998a),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'View More',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            // No more items message
            const Text(
              'All subcategories loaded',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),

          // Page info
          const SizedBox(height: 8),
          Text(
            'Loaded ${controller.loadedSubcategoriesCount} subcategories',
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

  /// Build individual subcategory item
  Widget _buildSubcategoryItem(MartSubcategoryModel subcategory) {
    return InkWell(
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
          Container(
            width: 87,
            height: 81.54,
            decoration: BoxDecoration(
              color: const Color(0xFFECEAFD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: (subcategory.validImageUrl.isNotEmpty ||
                      (subcategory.photo != null &&
                          subcategory.photo!.isNotEmpty))
                  ? NetworkImageWidget(
                      imageUrl: subcategory.validImageUrl.isNotEmpty
                          ? subcategory.validImageUrl
                          : subcategory.photo!,
                      width: 87,
                      height: 81.54,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        width: 87,
                        height: 81.54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEAFD),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _getSubcategoryIcon(subcategory.title ?? ''),
                          color: const Color(0xFF00998a),
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      width: 87,
                      height: 81.54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEAFD),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _getSubcategoryIcon(subcategory.title ?? ''),
                        color: const Color(0xFF00998a),
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 87,
            child: Text(
              subcategory.title ?? 'Subcategory',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
