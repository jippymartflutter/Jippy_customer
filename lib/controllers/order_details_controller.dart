import 'package:customer/constant/constant.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    calculatePrice();
    update();
  }

  RxDouble subTotal = 0.0.obs;
  RxDouble specialDiscountAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;

  calculatePrice() async {
    subTotal.value = 0.0;
    specialDiscountAmount.value = 0.0;
    taxAmount.value = 0.0;
    totalAmount.value = 0.0;

    print('DEBUG: Order Details Controller - Starting price calculation');
    print('DEBUG: Order Details Controller - Order ID: ${orderModel.value.id}');
    print('DEBUG: Order Details Controller - Total products: ${orderModel.value.products?.length ?? 0}');

    // Calculate subtotal using promotional prices if available
    for (var element in orderModel.value.products!) {
      print('DEBUG: Order Details Controller - Processing product: ${element.name}');
      print('DEBUG: Order Details Controller - Product ID: ${element.id}');
      print('DEBUG: Order Details Controller - Price: ${element.price}');
      print('DEBUG: Order Details Controller - DiscountPrice: ${element.discountPrice}');
      print('DEBUG: Order Details Controller - PromoId: ${element.promoId}');
      
      // Check if this item has a promotional price
      final hasPromo = element.promoId != null && element.promoId!.isNotEmpty;
      print('DEBUG: Order Details Controller - Has promo: $hasPromo');
      
      double itemPrice;
      if (hasPromo) {
        // Use promotional price for calculations
        itemPrice = double.parse(element.price.toString());
        print('DEBUG: Order Details Controller - Using promotional price: $itemPrice');
      } else if (double.parse(element.discountPrice.toString()) <= 0) {
        // No promotion, no discount - use regular price
        itemPrice = double.parse(element.price.toString());
        print('DEBUG: Order Details Controller - Using regular price: $itemPrice');
      } else {
        // Regular discount (non-promo) - use discount price
        itemPrice = double.parse(element.discountPrice.toString());
        print('DEBUG: Order Details Controller - Using discount price: $itemPrice');
      }
      
      final quantity = double.parse(element.quantity.toString());
      final extrasPrice = double.parse(element.extrasPrice.toString());
      
      final itemTotal = (itemPrice * quantity) + (extrasPrice * quantity);
      subTotal.value += itemTotal;
      
      print('DEBUG: Order Details Controller - Item total: $itemTotal, Running subtotal: ${subTotal.value}');
    }

    if (orderModel.value.specialDiscount != null && orderModel.value.specialDiscount!['special_discount'] != null) {
      specialDiscountAmount.value = double.parse(orderModel.value.specialDiscount!['special_discount'].toString());
      print('DEBUG: Order Details Controller - Special discount: ₹${specialDiscountAmount.value}');
    }

    // Debug: Print subTotal and deliveryCharge
    print('DEBUG: Order Details Controller - Final subtotal: ₹${subTotal.value}');
    print('DEBUG: Order Details Controller - Delivery charge: ₹${orderModel.value.deliveryCharge}');

    // Check if order has promotional items for delivery charge calculation
    final hasPromotionalItems = orderModel.value.products?.any((item) => 
        item.promoId != null && item.promoId!.isNotEmpty) ?? false;
    
    print('DEBUG: Order Details Controller - Has promotional items: $hasPromotionalItems');

    double sgst = 0.0;
    double gst = 0.0;
    if (orderModel.value.taxSetting != null) {
      for (var element in orderModel.value.taxSetting!) {
        if ((element.title?.toLowerCase() ?? '').contains('sgst')) {
          // Calculate SGST on subtotal (which includes promotional prices)
          sgst = Constant.calculateTax(amount: subTotal.value.toString(), taxModel: element);
          print('DEBUG: Order Details Controller - SGST (5%) on item total: ₹$sgst');
        } else if ((element.title?.toLowerCase() ?? '').contains('gst')) {
          // Calculate GST on delivery charge
          gst = Constant.calculateTax(amount: double.parse(orderModel.value.deliveryCharge.toString()).toString(), taxModel: element);
          print('DEBUG: Order Details Controller - GST (18%) on delivery fee: ₹$gst');
        }
      }
    }
    taxAmount.value = sgst + gst;
    print('DEBUG: Order Details Controller - Total Taxes & Charges: ₹${taxAmount.value}');

    totalAmount.value = (subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscountAmount.value) +
        taxAmount.value +
        double.parse(orderModel.value.deliveryCharge.toString()) +
        double.parse(orderModel.value.tipAmount.toString());

    print('DEBUG: Order Details Controller - Final calculation:');
    print('DEBUG: Order Details Controller - Subtotal: ₹${subTotal.value}');
    print('DEBUG: Order Details Controller - Discount: -₹${orderModel.value.discount}');
    print('DEBUG: Order Details Controller - Special discount: -₹${specialDiscountAmount.value}');
    print('DEBUG: Order Details Controller - Tax: +₹${taxAmount.value}');
    print('DEBUG: Order Details Controller - Delivery: +₹${orderModel.value.deliveryCharge}');
    print('DEBUG: Order Details Controller - Tips: +₹${orderModel.value.tipAmount}');
    print('DEBUG: Order Details Controller - Total amount: ₹${totalAmount.value}');

    isLoading.value = false;
  }

  final CartProvider cartProvider = CartProvider();

  addToCart({required CartProductModel cartProductModel}) {
    cartProvider.addToCart(Get.context!, cartProductModel, cartProductModel.quantity!);
    update();
  }

  // Test function to manually test promotional calculations
  void testPromotionalCalculation() {
    print('=== MANUAL PROMOTIONAL CALCULATION TEST ===');
    
    if (orderModel.value.products != null) {
      print('Testing ${orderModel.value.products!.length} products:');
      
      for (int i = 0; i < orderModel.value.products!.length; i++) {
        final product = orderModel.value.products![i];
        print('Product ${i + 1}: ${product.name}');
        print('  - ID: ${product.id}');
        print('  - Price: ${product.price}');
        print('  - DiscountPrice: ${product.discountPrice}');
        print('  - PromoId: ${product.promoId}');
        print('  - Quantity: ${product.quantity}');
        
        // Test promotional detection
        final hasPromo = product.promoId != null && product.promoId!.isNotEmpty;
        print('  - Has PromoId: $hasPromo');
        
        // Test price calculation
        double itemPrice;
        if (hasPromo) {
          itemPrice = double.parse(product.price.toString());
          print('  - Using promotional price: ₹$itemPrice');
        } else if (double.parse(product.discountPrice.toString()) <= 0) {
          itemPrice = double.parse(product.price.toString());
          print('  - Using regular price: ₹$itemPrice');
        } else {
          itemPrice = double.parse(product.discountPrice.toString());
          print('  - Using discount price: ₹$itemPrice');
        }
        
        final quantity = double.parse(product.quantity.toString());
        final extrasPrice = double.parse(product.extrasPrice.toString());
        final itemTotal = (itemPrice * quantity) + (extrasPrice * quantity);
        
        print('  - Item total: ₹$itemTotal');
        print('');
      }
      
      // Test overall promotional detection
      final hasAnyPromotionalItems = orderModel.value.products!.any((item) => 
          item.promoId != null && item.promoId!.isNotEmpty);
      
      print('Overall has promotional items: $hasAnyPromotionalItems');
    } else {
      print('No products found in order');
    }
    
    print('=== END MANUAL TEST ===');
  }
}
