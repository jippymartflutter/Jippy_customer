class CategoryConfig {
  // List of category IDs that should be shown in the "All Categories" screen
  // Add the IDs of the categories you want to display
  static const List<String> allowedCategoryIds = [
    // Add your specific category IDs here
    // Example: 'category_id_1', 'category_id_2', 'category_id_3'
    // You can find these IDs in your Firestore database
  ];

  // List of category titles that should be shown (alternative to IDs)
  // This is useful if you want to filter by category names instead of IDs
  static const List<String> allowedCategoryTitles = [
    'Sandwich',
    'Burger',
    'Chinese',
    'Noodles',
    'North Indian',
    'Dosa',
    'Biryani',
    'Fried Rice',
    'Ice cream',
    'Parotta',
    'Cakes',
    'Rolls',
    'Thali',
    'Juice',
    'Veg',
    'Lassi',
    'Chicken',
    'Desserts',
    'Paneer',
    'Sweets',
    'Mocktails',
    'Idly',
    'Soups',
    'Tiffins',
    'Gobi',
    'Pizza',
    'Sea Foods',
    'Milkshakes',
    'Beverages',
    'Breakfast',
    'Egg Starters',
    'Fried Chicken',
    'Mutton Salad',
    'Shawarma',
    'Badam Milk',
    'Non-Veg Tandoori',
    'Chapati',
    'Prawns',
    'Curries',
  ];

  // Set this to true to enable category filtering
  static const bool enableCategoryFiltering = true;

  // Set this to true to use title-based filtering instead of ID-based filtering
  static const bool useTitleFiltering = true; // Enable title-based filtering

  // Maximum number of categories to show (set to null for unlimited)
  static const int? maxCategoriesToShow = 40; // Show all 40 categories

  // Set this to true to show only categories that have active vendors
  static const bool showOnlyCategoriesWithVendors = false;
} 