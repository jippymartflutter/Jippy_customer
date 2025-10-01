import 'package:flutter/material.dart';
import 'package:customer/app/mart/widgets/playtime_product_card.dart';

/// Example usage of PlaytimeProductCard component
/// This shows how to use the extracted component in different scenarios
class PlaytimeProductCardExample extends StatelessWidget {
  const PlaytimeProductCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlaytimeProductCard Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Single card
            const Text(
              'Single Card Example:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: PlaytimeProductCard(
                volume: '500g',
                productName: 'Example Product',
                discount: '20% OFF',
                currentPrice: '₹199',
                originalPrice: '₹249',
                screenWidth: screenWidth,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Example 2: Horizontal scrolling cards
            const Text(
              'Horizontal Scrolling Cards:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  PlaytimeProductCard(
                    volume: '250ml',
                    productName: 'Product 1',
                    discount: '15% OFF',
                    currentPrice: '₹150',
                    originalPrice: '₹180',
                    screenWidth: screenWidth,
                  ),
                  PlaytimeProductCard(
                    volume: '500ml',
                    productName: 'Product 2',
                    discount: '25% OFF',
                    currentPrice: '₹299',
                    originalPrice: '₹399',
                    screenWidth: screenWidth,
                  ),
                  PlaytimeProductCard(
                    volume: '1L',
                    productName: 'Product 3',
                    discount: '30% OFF',
                    currentPrice: '₹499',
                    originalPrice: '₹699',
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Example 3: Grid layout
            const Text(
              'Grid Layout Example:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.5,
              children: [
                PlaytimeProductCard(
                  volume: '100g',
                  productName: 'Grid Product 1',
                  discount: '10% OFF',
                  currentPrice: '₹89',
                  originalPrice: '₹99',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '200g',
                  productName: 'Grid Product 2',
                  discount: '20% OFF',
                  currentPrice: '₹159',
                  originalPrice: '₹199',
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
