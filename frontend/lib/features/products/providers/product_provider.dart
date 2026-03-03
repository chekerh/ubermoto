import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product model for the catalog.
class Product {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final double? originalPrice; // for discounts
  final String category;
  final String categoryAr;
  final String imageUrl;
  final String description;
  final String descriptionAr;
  final String unit; // e.g. "500g", "1L"
  final List<String> tags; // e.g. ["Spicy", "Bio"]
  final bool isFavorite;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    this.nameAr = '',
    required this.price,
    this.originalPrice,
    required this.category,
    this.categoryAr = '',
    required this.imageUrl,
    this.description = '',
    this.descriptionAr = '',
    this.unit = '',
    this.tags = const [],
    this.isFavorite = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'price': price,
        'originalPrice': originalPrice,
        'category': category,
        'categoryAr': categoryAr,
        'imageUrl': imageUrl,
        'description': description,
        'descriptionAr': descriptionAr,
        'unit': unit,
        'tags': tags,
        'isFavorite': isFavorite,
        'rating': rating,
        'reviewCount': reviewCount,
      };

  Product copyWith({bool? isFavorite}) => Product(
        id: id,
        name: name,
        nameAr: nameAr,
        price: price,
        originalPrice: originalPrice,
        category: category,
        categoryAr: categoryAr,
        imageUrl: imageUrl,
        description: description,
        descriptionAr: descriptionAr,
        unit: unit,
        tags: tags,
        isFavorite: isFavorite ?? this.isFavorite,
        rating: rating,
        reviewCount: reviewCount,
      );
}

/// Cart item wraps a product with quantity.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'subtotal': subtotal,
      };
}

/// Product catalog state.
class ProductCatalogState {
  final List<Product> products;
  final List<Product> popularProducts;
  final List<CartItem> cart;
  final bool isLoading;
  final String? error;
  final String? selectedProductId;

  const ProductCatalogState({
    this.products = const [],
    this.popularProducts = const [],
    this.cart = const [],
    this.isLoading = false,
    this.error,
    this.selectedProductId,
  });

  double get cartSubtotal =>
      cart.fold(0.0, (sum, item) => sum + item.subtotal);

  int get cartItemCount =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  double get deliveryFee => cartSubtotal > 0 ? 2.0 : 0.0;

  double get cartTotal => cartSubtotal + deliveryFee;

  Product? get selectedProduct {
    if (selectedProductId == null) return null;
    try {
      return products.firstWhere((p) => p.id == selectedProductId);
    } catch (_) {
      return null;
    }
  }

  ProductCatalogState copyWith({
    List<Product>? products,
    List<Product>? popularProducts,
    List<CartItem>? cart,
    bool? isLoading,
    String? error,
    String? selectedProductId,
  }) =>
      ProductCatalogState(
        products: products ?? this.products,
        popularProducts: popularProducts ?? this.popularProducts,
        cart: cart ?? this.cart,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        selectedProductId: selectedProductId ?? this.selectedProductId,
      );
}

/// Product catalog notifier — manages products, cart, and favorites.
class ProductCatalogNotifier extends StateNotifier<ProductCatalogState> {
  ProductCatalogNotifier() : super(const ProductCatalogState()) {
    _loadProducts();
  }

  void _loadProducts() {
    // In production, these would come from the backend API.
    // For now, we use realistic Tunisian product data that gets
    // injected dynamically into the HTML screens.
    const catalog = [
      Product(
        id: 'harissa-sicam',
        name: 'Harissa Sicam',
        nameAr: 'هريسة سيكام',
        price: 2.500,
        category: 'Épices & Condiments',
        categoryAr: 'بهارات وتوابل',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuANljbrau7PDzD7_YiNrqQ_1M3eU3Ks2oRtuDDoBpey7tQoCGZjp24JaX4BDKhEdvQKLy9Z8AK3xT_1Wo7TEp-RHKn40jFhESz7SFEHTBJ3iRvv9YiO3Mz-bdRrNkkhFSHfa1MP5-Ja3yPTzcwQ8FN-wJ12eyhLJA-PZt6bC5c1OGI7J8DA50UGeQBKTQveb7BRhEvhotwBK7CfvGaYkTVm-NqjZLMKR1oVAdBxbqjTH5ckN2RRZHtojI9fmwdws6zvSUR2MM53dP4',
        description:
            'Authentic Tunisian Harissa made from sun-dried hot chili peppers, garlic, caraway, coriander, and olive oil.',
        descriptionAr:
            'هريسة تونسية أصيلة مصنوعة من الفلفل الحار المجفف بالشمس والثوم والكراوية والكزبرة وزيت الزيتون.',
        unit: '500g',
        tags: ['Spicy', 'Bio', 'Tunisian Origin'],
        rating: 4.8,
        reviewCount: 342,
      ),
      Product(
        id: 'couscous-fin',
        name: 'Couscous Fin',
        nameAr: 'كسكسي رقيق',
        price: 1.800,
        category: 'Céréales',
        categoryAr: 'حبوب',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAT2iQyz2C0-laySzWV8rn3aQUaJt6Edog8SSTjet8wHQ2FEQaunTRXt1HBedaqikhd97FH84jHQLCtxsxAuiPfaV8YSGua_Z9okmXtO-XXFK3VCOM690vXf7mm0VdOw4it3ZjSpODBAdk3X8ZwFwCaquhzFnR7PcUVlKYU9Kk3ieT5u4NgTqCqfdyNwzLeMReyDaILHCjX6qhunDIWOdj1JkfKV7jirT9gRZiuS-0AUSvOj8of65T5GRtXgMbGDmx5jlQulMIysu0',
        description:
            'Fine grain couscous, perfect for traditional Friday couscous with lamb and vegetables.',
        descriptionAr:
            'كسكسي حبة رقيقة مثالي لكسكسي الجمعة التقليدي مع اللحم والخضار.',
        unit: '1kg',
        tags: ['Traditional'],
        rating: 4.5,
        reviewCount: 215,
      ),
      Product(
        id: 'indomie-poulet',
        name: 'Indomie Poulet',
        nameAr: 'إندومي دجاج',
        price: 1.200,
        originalPrice: 1.500,
        category: 'Pâtes Instantanées',
        categoryAr: 'معكرونة سريعة',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALx9X92FJa37FQ9OVX09SBkzeWm6woCk5qqeY3nNsbY0sX5Zvjc_tf9kwkKTLtXAnQYsfITsEfM0mATrpJYE-FIYUbqD5JXj3m0-XpLUmf3MI6LIfxIy4QYGXjEELrDTafj44yeFUjILADLbgU854lt3lLO7d2OvjnFY4mAfLhBQCpDLX9TLeYcIjOFMwXsYKoNOIVmBo8D96pf6jXUYHVAv5bjPbdyln-xkXR_RS-c16M3vKyug3rTFxIY2zlWYoo-OF5l6XIeU0',
        description:
            'Popular instant chicken flavored noodles. Quick and easy meal in minutes.',
        descriptionAr:
            'نودلز فورية بنكهة الدجاج. وجبة سريعة وسهلة في دقائق.',
        unit: '80g × 5',
        tags: ['Popular', '-20%'],
        rating: 4.2,
        reviewCount: 567,
      ),
      Product(
        id: 'delice-milk',
        name: 'Délice Milk',
        nameAr: 'حليب ديليس',
        price: 1.400,
        category: 'Produits Laitiers',
        categoryAr: 'منتجات الألبان',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2b9xRQ-MN9TZyXqoFffM4_6gYMm3iJVeISZ65t01TVi4eH3jVMF1HjusQe5CjnUJ5OeCtZ0629A9J_1Pv0s04_5bKl_tpaPzKy7gZ1z-1TxQyLUkScEhW-3M6TyEwS5m8sIINfIl4CNlbJwVJZYhqhTapgsImPR3SC-ykj3kLrnz3XRhG32YfN4UXv44Do5vvY_yls5d8fFU1ECr7E9Bzmspp1KokNLlo7RavCzwn4It31bsAP8iLMRmb3-GmWrvDxb8MRIZX1uE',
        description: 'Fresh full cream milk from Délice, Tunisia\'s leading dairy brand.',
        descriptionAr: 'حليب كامل الدسم طازج من ديليس.',
        unit: '1L',
        tags: ['Fresh'],
        rating: 4.6,
        reviewCount: 189,
      ),
      Product(
        id: 'tuna-bg',
        name: 'Thon El Manar',
        nameAr: 'تونة المنار',
        price: 3.200,
        category: 'Conserves',
        categoryAr: 'معلبات',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuANljbrau7PDzD7_YiNrqQ_1M3eU3Ks2oRtuDDoBpey7tQoCGZjp24JaX4BDKhEdvQKLy9Z8AK3xT_1Wo7TEp-RHKn40jFhESz7SFEHTBJ3iRvv9YiO3Mz-bdRrNkkhFSHfa1MP5-Ja3yPTzcwQ8FN-wJ12eyhLJA-PZt6bC5c1OGI7J8DA50UGeQBKTQveb7BRhEvhotwBK7CfvGaYkTVm-NqjZLMKR1oVAdBxbqjTH5ckN2RRZHtojI9fmwdws6zvSUR2MM53dP4',
        description: 'Premium canned tuna in olive oil from the Mediterranean coast.',
        descriptionAr: 'تونة معلبة ممتازة بزيت الزيتون من ساحل البحر الأبيض المتوسط.',
        unit: '200g',
        tags: ['Premium'],
        rating: 4.4,
        reviewCount: 128,
      ),
      Product(
        id: 'olive-oil-chemlali',
        name: 'Huile d\'Olive Chemlali',
        nameAr: 'زيت زيتون شملالي',
        price: 12.500,
        category: 'Huiles',
        categoryAr: 'زيوت',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAT2iQyz2C0-laySzWV8rn3aQUaJt6Edog8SSTjet8wHQ2FEQaunTRXt1HBedaqikhd97FH84jHQLCtxsxAuiPfaV8YSGua_Z9okmXtO-XXFK3VCOM690vXf7mm0VdOw4it3ZjSpODBAdk3X8ZwFwCaquhzFnR7PcUVlKYU9Kk3ieT5u4NgTqCqfdyNwzLeMReyDaILHCjX6qhunDIWOdj1JkfKV7jirT9gRZiuS-0AUSvOj8of65T5GRtXgMbGDmx5jlQulMIysu0',
        description: 'Extra virgin olive oil from Sfax region, cold pressed from Chemlali olives.',
        descriptionAr: 'زيت زيتون بكر ممتاز من منطقة صفاقس، معصور على البارد من زيتون الشملالي.',
        unit: '1L',
        tags: ['Bio', 'Premium', 'Tunisian Origin'],
        rating: 4.9,
        reviewCount: 456,
      ),
    ];

    state = state.copyWith(
      products: catalog,
      popularProducts: catalog.take(4).toList(),
      isLoading: false,
    );
  }

  void selectProduct(String productId) {
    state = state.copyWith(selectedProductId: productId);
  }

  void toggleFavorite(String productId) {
    final updated = state.products.map((p) {
      if (p.id == productId) return p.copyWith(isFavorite: !p.isFavorite);
      return p;
    }).toList();
    state = state.copyWith(
      products: updated,
      popularProducts:
          state.popularProducts.map((p) {
            if (p.id == productId) return p.copyWith(isFavorite: !p.isFavorite);
            return p;
          }).toList(),
    );
  }

  void addToCart(String productId, {int quantity = 1}) {
    final product = state.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => state.products.first,
    );

    final existingIdx =
        state.cart.indexWhere((ci) => ci.product.id == productId);
    final updatedCart = List<CartItem>.from(state.cart);

    if (existingIdx >= 0) {
      final existing = updatedCart[existingIdx];
      updatedCart[existingIdx] = CartItem(
        product: existing.product,
        quantity: existing.quantity + quantity,
      );
    } else {
      updatedCart.add(CartItem(product: product, quantity: quantity));
    }

    state = state.copyWith(cart: updatedCart);
  }

  void removeFromCart(String productId) {
    final updatedCart =
        state.cart.where((ci) => ci.product.id != productId).toList();
    state = state.copyWith(cart: updatedCart);
  }

  void updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final updatedCart = state.cart.map((ci) {
      if (ci.product.id == productId) {
        return CartItem(product: ci.product, quantity: quantity);
      }
      return ci;
    }).toList();
    state = state.copyWith(cart: updatedCart);
  }

  void clearCart() {
    state = state.copyWith(cart: []);
  }
}

/// Global product catalog provider.
final productCatalogProvider =
    StateNotifierProvider<ProductCatalogNotifier, ProductCatalogState>((ref) {
  return ProductCatalogNotifier();
});
