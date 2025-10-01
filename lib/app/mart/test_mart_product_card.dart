import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/mart/widgets/mart_product_card.dart';

import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/mart_subcategory_model.dart';

class TestMartProductCardScreen extends StatelessWidget {
  const TestMartProductCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test MartProductCard'),
        backgroundColor: const Color(0xFF292966),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Testing Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Tap the ADD button on the first card to test simple add to cart\n'
                    '• Tap the ADD button on the second card to test options modal\n'
                    '• Check responsive design by resizing the screen\n'
                    '• Verify all styling matches the original ProductCard\n'
                    '• Cards are displayed 2 per row with ratings\n'
                    '• Both cards maintain same height regardless of content\n'
                    '• Test the new ProductCard component below',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test Products Row 1 - Side by Side
            const Text(
              '🧪 Test Products Row 1 - Side by Side',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B69),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Two products displayed side by side with ratings - Same height enforced',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Row with 2 products side by side - FIXED HEIGHT 275px
            SizedBox(
              height: 275, // Fixed height container - reduced to prevent overflow
              child: Row(
                children: [
                  // Product 1 - Simple Product (BALANCED CONTENT)
                  Expanded(
                    child: Container(
                      height: 275, // Fixed height for consistent card sizing - reduced to prevent overflow
                      child: _buildTestProductCard(
                        context,
                        MartItemModel(
                          id: 'test_product_001',
                          name: 'Fresh Organic Apples',
                          description: 'Sweet organic apples from local farms with premium quality and amazing taste profile',
                          photo: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&h=300&fit=crop',
                          price: 120.0,
                          disPrice: 99.0, // Discounted price
                          categoryID: 'fruits',
                          subcategoryID: 'organic_fruits',
                          vendorID: 'test_vendor',
                          veg: true,
                          nonveg: false,
                          quantity: 50,
                          reviewCount: '128',
                          reviewSum: '4.5',
                          has_options: false,
                          options_count: 0,
                          isAvailable: true,
                          publish: true,
                        ),
                        'organic_fruits',
                        'Organic Fruits',
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Product 2 - Product with Options (BALANCED CONTENT)
                  Expanded(
                    child: Container(
                      height: 275, // Fixed height for consistent card sizing - reduced to prevent overflow
                      child: _buildTestProductCard(
                        context,
                        MartItemModel(
                          id: 'test_product_002',
                          name: 'Coffee Beans',
                          description: 'Quality coffee beans with multiple roasting levels and premium taste experience',
                          photo: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=300&fit=crop',
                          price: 450.0,
                          disPrice: 399.0, // Discounted price
                          categoryID: 'beverages',
                          subcategoryID: 'coffee',
                          vendorID: 'test_vendor',
                          veg: true,
                          nonveg: false,
                          quantity: 25,
                          reviewCount: '89',
                          reviewSum: '4.8',
                          has_options: true,
                          options_count: 3,
                          isAvailable: true,
                          publish: true,
                          options: [
                            {
                              'id': 'option_1',
                              'option_title': 'Light Roast',
                              'price': 399.0,
                              'original_price': 450.0,
                              'unit_price': 399.0,
                              'unit_measure': 250,
                              'unit_measure_type': 'g',
                              'image': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
                            },
                            {
                              'id': 'option_2',
                              'option_title': 'Medium Roast',
                              'price': 450.0,
                              'original_price': 500.0,
                              'unit_price': 450.0,
                              'unit_measure': 250,
                              'unit_measure_type': 'g',
                              'image': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
                            },
                            {
                              'id': 'option_3',
                              'option_title': 'Dark Roast',
                              'price': 500.0,
                              'original_price': 550.0,
                              'unit_price': 500.0,
                              'unit_measure': 250,
                              'unit_measure_type': 'g',
                              'image': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
                            },
                          ],
                        ),
                        'coffee',
                        'Coffee',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),





          ],
        ),
      ),
    );
  }

  Widget _buildTestProductCard(
    BuildContext context,
    MartItemModel product,
    String subcategoryId,
    String subcategoryTitle,
  ) {
    // Create a mock controller for testing
    final testController = CategoryDetailController();
    testController.subcategories.value = [
      MartSubcategoryModel(
        id: subcategoryId,
        title: subcategoryTitle,
        photo: product.photo,
      ),
    ];

    return MartProductCard(
      product: product,
      controller: testController,
      screenWidth: MediaQuery.of(context).size.width,
    );
  }


}
