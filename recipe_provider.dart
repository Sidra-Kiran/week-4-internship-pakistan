import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  String _searchQuery = '';

  List<Recipe> get recipes => _searchQuery.isEmpty ? _recipes : _filteredRecipes;
  List<Recipe> get favoriteRecipes => _recipes.where((recipe) => recipe.isFavorite).toList();

  RecipeProvider() {
    _loadRecipes();
    _loadFavorites();
  }

  // Sample recipes data
  final List<Recipe> _sampleRecipes = [
    Recipe(
      id: '1',
      title: 'Vegetable Pasta',
      description: 'A delicious and healthy pasta dish with fresh vegetables',
      imageUrl: 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg',
      ingredients: [
        '200g pasta',
        '2 tbsp olive oil',
        '2 cloves garlic, minced',
        '1 bell pepper, sliced',
        '1 zucchini, sliced',
        '1 cup cherry tomatoes, halved',
        'Salt and pepper to taste',
        'Fresh basil leaves',
        'Parmesan cheese (optional)'
      ],
      steps: [
        'Cook pasta according to package instructions.',
        'Heat olive oil in a large pan over medium heat.',
        'Add garlic and sauté until fragrant.',
        'Add bell pepper and zucchini, cook for 5 minutes.',
        'Add cherry tomatoes and cook for another 3 minutes.',
        'Drain pasta and add to the pan with vegetables.',
        'Season with salt and pepper, toss to combine.',
        'Garnish with fresh basil and Parmesan cheese before serving.'
      ],
    ),
    Recipe(
      id: '2',
      title: 'Chocolate Chip Cookies',
      description: 'Classic homemade chocolate chip cookies',
      imageUrl: 'https://images.pexels.com/photos/230325/pexels-photo-230325.jpeg',
      ingredients: [
        '2 1/4 cups all-purpose flour',
        '1 tsp baking soda',
        '1 tsp salt',
        '1 cup butter, softened',
        '3/4 cup granulated sugar',
        '3/4 cup packed brown sugar',
        '2 large eggs',
        '2 tsp vanilla extract',
        '2 cups chocolate chips'
      ],
      steps: [
        'Preheat oven to 375°F (190°C).',
        'In a small bowl, mix flour, baking soda, and salt.',
        'In a large bowl, beat butter, granulated sugar, and brown sugar until creamy.',
        'Add eggs and vanilla extract, beat well.',
        'Gradually beat in flour mixture.',
        'Stir in chocolate chips.',
        'Drop by rounded tablespoon onto ungreased baking sheets.',
        'Bake for 9 to 11 minutes or until golden brown.',
        'Cool on baking sheets for 2 minutes; remove to wire racks to cool completely.'
      ],
    ),
    Recipe(
      id: '3',
      title: 'Fresh Garden Salad',
      description: 'A refreshing salad with mixed greens and vegetables',
      imageUrl: 'https://images.pexels.com/photos/2862154/pexels-photo-2862154.jpeg',
      ingredients: [
        '4 cups mixed salad greens',
        '1 cucumber, sliced',
        '1 cup cherry tomatoes, halved',
        '1/2 red onion, thinly sliced',
        '1/4 cup olives',
        '2 tbsp olive oil',
        '1 tbsp lemon juice',
        'Salt and pepper to taste',
        'Feta cheese (optional)'
      ],
      steps: [
        'Wash and dry the salad greens thoroughly.',
        'Chop the vegetables and place them in a large bowl.',
        'In a small bowl, whisk together olive oil, lemon juice, salt, and pepper.',
        'Pour the dressing over the salad and toss to combine.',
        'Top with feta cheese if desired and serve immediately.'
      ],
    ),
    Recipe(
      id: '4',
      title: 'Grilled Chicken Sandwich',
      description: 'A hearty sandwich with grilled chicken and fresh toppings',
      imageUrl: 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
      ingredients: [
        '2 boneless chicken breasts',
        '4 slices whole grain bread',
        '2 lettuce leaves',
        '2 tomato slices',
        '4 slices avocado',
        '2 tbsp mayonnaise',
        '1 tbsp mustard',
        'Salt and pepper to taste',
        '1 tbsp olive oil'
      ],
      steps: [
        'Season chicken breasts with salt and pepper.',
        'Heat olive oil in a grill pan over medium-high heat.',
        'Grill chicken for 6-7 minutes on each side until cooked through.',
        'Toast the bread slices lightly.',
        'Spread mayonnaise and mustard on one side of each bread slice.',
        'Layer lettuce, tomato, avocado, and grilled chicken on two bread slices.',
        'Top with the remaining bread slices and serve.'
      ],
    ),
    Recipe(
      id: '5',
      title: 'Berry Smoothie Bowl',
      description: 'A nutritious and colorful breakfast bowl',
      imageUrl: 'https://images.pexels.com/photos/103566/pexels-photo-103566.jpeg',
      ingredients: [
        '1 cup frozen mixed berries',
        '1 banana',
        '1/2 cup Greek yogurt',
        '2 tbsp honey or maple syrup',
        '2 tbsp granola',
        '1 tbsp chia seeds',
        'Fresh berries for topping',
        'Sliced almonds for topping'
      ],
      steps: [
        'In a blender, combine frozen berries, banana, Greek yogurt, and honey.',
        'Blend until smooth and creamy.',
        'Pour the smoothie into a bowl.',
        'Top with granola, chia seeds, fresh berries, and sliced almonds.',
        'Serve immediately.'
      ],
    ),
  ];

  void _loadRecipes() {
    _recipes = _sampleRecipes;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    for (var recipe in _recipes) {
      final isFavorite = prefs.getBool('favorite_${recipe.id}') ?? false;
      if (isFavorite) {
        final index = _recipes.indexWhere((r) => r.id == recipe.id);
        if (index != -1) {
          _recipes[index] = _recipes[index].copyWith(isFavorite: true);
        }
      }
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String recipeId) async {
    final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index != -1) {
      final newFavoriteStatus = !_recipes[index].isFavorite;
      _recipes[index] = _recipes[index].copyWith(isFavorite: newFavoriteStatus);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_$recipeId', newFavoriteStatus);
      
      notifyListeners();
    }
  }

  void searchRecipes(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredRecipes = _recipes;
    } else {
      _filteredRecipes = _recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
            recipe.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Recipe getRecipeById(String id) {
    return _recipes.firstWhere((recipe) => recipe.id == id);
  }
}