import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// **TRIE NODE FOR DICTIONARY-BASED SEARCH**
class TrieNode {
  Map<String, TrieNode> children = {};
  List<dynamic> dataRefs = []; // Can be VendorModel or ProductModel
  bool isEnd = false;
  double relevanceScore = 0.0;
}

// **TRIE SEARCH IMPLEMENTATION**
class TrieSearch {
  final TrieNode root = TrieNode();
  int totalIndexedItems = 0;
  
  void insert(String word, dynamic data, {double relevanceScore = 1.0}) {
    try {
      if (word.isEmpty) return;
      
      TrieNode node = root;
      final lowerWord = word.toLowerCase();
      
      for (var char in lowerWord.split('')) {
        node = node.children.putIfAbsent(char, () => TrieNode());
      }
      
      node.isEnd = true;
      node.dataRefs.add(data);
      node.relevanceScore = relevanceScore;
      totalIndexedItems++;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to insert word "$word" into trie: $e');
      }
      // Log to Crashlytics for production monitoring
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie insert failed');
    }
  }
  
  List<dynamic> search(String prefix, {int maxResults = 50}) {
    try {
      if (prefix.isEmpty) return [];
      
      TrieNode node = root;
      final lowerPrefix = prefix.toLowerCase();
      
      // Navigate to the prefix node
      for (var char in lowerPrefix.split('')) {
        if (!node.children.containsKey(char)) {
          return []; // Prefix not found
        }
        node = node.children[char]!;
      }
      
      // Collect all results from this node and its children
      List<Map<String, dynamic>> results = [];
      _collectAllResults(node, results, maxResults);
      
      // Sort by relevance score (higher first)
      results.sort((a, b) => b['score'].compareTo(a['score']));
      
      // Return only the data objects
      return results.map((result) => result['data']).toList();
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Trie search failed for prefix "$prefix": $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie search failed');
      return [];
    }
  }
  
  void _collectAllResults(TrieNode node, List<Map<String, dynamic>> results, int maxResults) {
    if (results.length >= maxResults) return;
    
    // Add results from current node
    if (node.isEnd && node.dataRefs.isNotEmpty) {
      for (var data in node.dataRefs) {
        if (results.length >= maxResults) break;
        results.add({
          'data': data,
          'score': node.relevanceScore,
        });
      }
    }
    
    // Recursively search children
    for (var child in node.children.values) {
      if (results.length >= maxResults) break;
      _collectAllResults(child, results, maxResults);
    }
  }
  
  List<String> getSuggestions(String prefix, {int maxSuggestions = 10}) {
    try {
      if (prefix.isEmpty) return [];
      
      TrieNode node = root;
      final lowerPrefix = prefix.toLowerCase();
      
      // Navigate to the prefix node
      for (var char in lowerPrefix.split('')) {
        if (!node.children.containsKey(char)) {
          print("🔍 Trie: Prefix '$prefix' not found - no children for '$char'");
          return []; // Prefix not found
        }
        node = node.children[char]!;
      }
      
      // Collect suggestions
      List<String> suggestions = [];
      _collectSuggestions(node, prefix, suggestions, maxSuggestions);
      
      print("🔍 Trie: Found ${suggestions.length} suggestions for '$prefix': $suggestions");
      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Trie suggestions failed for prefix "$prefix": $e');
      }
      return [];
    }
  }
  
  void _collectSuggestions(TrieNode node, String currentWord, List<String> suggestions, int maxSuggestions) {
    if (suggestions.length >= maxSuggestions) return;
    
    if (node.isEnd && node.dataRefs.isNotEmpty) {
      // Get unique names from data
      Set<String> names = {};
      for (var data in node.dataRefs) {
        String? name;
        if (data.runtimeType.toString().contains('VendorModel')) {
          name = data.name; // VendorModel uses 'name', not 'title'
        } else if (data.runtimeType.toString().contains('ProductModel')) {
          name = data.name;
        }
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }
      print("🔍 Trie: Found ${names.length} names at '$currentWord': $names");
      suggestions.addAll(names.take(maxSuggestions - suggestions.length));
    }
    
    // Recursively search children
    for (var entry in node.children.entries) {
      if (suggestions.length >= maxSuggestions) break;
      _collectSuggestions(entry.value, currentWord + entry.key, suggestions, maxSuggestions);
    }
  }
  
  void clear() {
    root.children.clear();
    root.dataRefs.clear();
    root.isEnd = false;
    root.relevanceScore = 0.0;
    totalIndexedItems = 0;
  }
  
  int get itemCount => totalIndexedItems;
}
