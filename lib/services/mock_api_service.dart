import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MockApiService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<MockApiService> init() async {
    // Initialize any necessary data or connections here
    return this;
  }

  // Dummy user data
  final Map<String, dynamic> dummyUser = {
    'id': 'user123',
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+1234567890',
    'address': '123 Main St, City',
  };

  // Dummy products data
  final List<Map<String, dynamic>> dummyProducts = [
    {
      'id': '1',
      'name': 'Fresh Milk',
      'price': 3.99,
      'description': 'Fresh whole milk',
      'image': 'https://example.com/milk.jpg',
      'category': 'Dairy',
      'stock': 50,
    },
    {
      'id': '2',
      'name': 'Whole Wheat Bread',
      'price': 2.49,
      'description': 'Freshly baked whole wheat bread',
      'image': 'https://example.com/bread.jpg',
      'category': 'Bakery',
      'stock': 30,
    },
    // Add more dummy products as needed
  ];

  // Dummy orders data
  final List<Map<String, dynamic>> dummyOrders = [
    {
      'id': 'order1',
      'userId': 'user123',
      'items': [
        {'productId': '1', 'quantity': 2, 'price': 3.99},
        {'productId': '2', 'quantity': 1, 'price': 2.49},
      ],
      'total': 10.47,
      'status': 'delivered',
      'date': DateTime.now().subtract(Duration(days: 2)),
    },
    // Add more dummy orders as needed
  ];

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Product methods
  Future<List<Map<String, dynamic>>> getProducts() async {
    await Future.delayed(Duration(seconds: 1));
    return dummyProducts;
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    await Future.delayed(Duration(seconds: 1));
    return dummyProducts.firstWhere((product) => product['id'] == id);
  }

  // Order methods
  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    await Future.delayed(Duration(seconds: 1));
    return dummyOrders.where((order) => order['userId'] == userId).toList();
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    await Future.delayed(Duration(seconds: 1));
    final newOrder = {
      'id': 'order${dummyOrders.length + 1}',
      ...orderData,
      'date': DateTime.now(),
    };
    dummyOrders.add(newOrder);
    return newOrder;
  }

  // User profile methods
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await Future.delayed(Duration(seconds: 1));
    return dummyUser;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await Future.delayed(Duration(seconds: 1));
    dummyUser.addAll(data);
  }

  // Cart methods
  Future<void> addToCart(String userId, String productId, int quantity) async {
    await Future.delayed(Duration(seconds: 1));
    // Implement cart logic here
  }

  Future<void> removeFromCart(String userId, String productId) async {
    await Future.delayed(Duration(seconds: 1));
    // Implement cart logic here
  }

  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    await Future.delayed(Duration(seconds: 1));
    return [];
  }
} 