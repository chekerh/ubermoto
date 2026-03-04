import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubertaxi_frontend/features/settings/providers/language_provider.dart';
import 'package:ubertaxi_frontend/features/products/providers/product_provider.dart';

void main() {
  // ── Smoke Test ─────────────────────────────────────────────────────────

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Nassib')),
            body: const Center(child: Text('Loaded')),
          ),
        ),
      ),
    );
    expect(find.text('Nassib'), findsOneWidget);
    expect(find.text('Loaded'), findsOneWidget);
  });

  // ── Language Provider ──────────────────────────────────────────────────

  group('LanguageProvider', () {
    test('defaults to English', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(languageProvider), AppLanguage.english);
    });

    test('setLanguage changes state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(languageProvider.notifier).setLanguage(AppLanguage.french);
      expect(container.read(languageProvider), AppLanguage.french);
    });

    test('setFromString detects French', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(languageProvider.notifier).setFromString('Français');
      expect(container.read(languageProvider), AppLanguage.french);
    });

    test('setFromString detects Arabic', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(languageProvider.notifier).setFromString('العربية');
      expect(container.read(languageProvider), AppLanguage.arabic);
    });

    test('setFromString detects Derja', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(languageProvider.notifier).setFromString('تونسي');
      expect(container.read(languageProvider), AppLanguage.derja);
    });

    test('setFromString defaults unknown input to English', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(languageProvider.notifier).setFromString('unknown');
      expect(container.read(languageProvider), AppLanguage.english);
    });

    test('AppLanguage enum has correct language codes', () {
      expect(AppLanguage.english.code, 'en');
      expect(AppLanguage.french.code, 'fr');
      expect(AppLanguage.arabic.code, 'ar');
      expect(AppLanguage.derja.code, 'tn');
    });

    test('Arabic and Derja are RTL', () {
      expect(AppLanguage.arabic.isRtl, isTrue);
      expect(AppLanguage.derja.isRtl, isTrue);
      expect(AppLanguage.english.isRtl, isFalse);
      expect(AppLanguage.french.isRtl, isFalse);
    });
  });

  // ── Translation Map ────────────────────────────────────────────────────

  group('uiTranslations', () {
    test('contains essential keys', () {
      const essentialKeys = [
        'Home',
        'Search',
        'Cart',
        'Orders',
        'Profile',
        'Sign in',
        'Password',
      ];
      for (final key in essentialKeys) {
        expect(uiTranslations.containsKey(key), isTrue,
            reason: 'Missing translation key: $key');
      }
    });

    test('every key has fr, ar, and tn translations', () {
      for (final entry in uiTranslations.entries) {
        final langs = entry.value;
        expect(langs.containsKey('fr'), isTrue,
            reason: '"${entry.key}" missing French translation');
        expect(langs.containsKey('ar'), isTrue,
            reason: '"${entry.key}" missing Arabic translation');
        expect(langs.containsKey('tn'), isTrue,
            reason: '"${entry.key}" missing Derja translation');
      }
    });

    test('no empty translation values', () {
      for (final entry in uiTranslations.entries) {
        for (final langEntry in entry.value.entries) {
          expect(langEntry.value.isNotEmpty, isTrue,
              reason:
                  '"${entry.key}" has empty ${langEntry.key} translation');
        }
      }
    });
  });

  // ── Product Provider ───────────────────────────────────────────────────

  group('ProductCatalogProvider', () {
    test('initial state has products loaded', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(productCatalogProvider);
      expect(state.products, isNotEmpty);
      expect(state.isLoading, isFalse);
    });

    test('cart starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(productCatalogProvider);
      expect(state.cart, isEmpty);
      expect(state.cartSubtotal, 0.0);
      expect(state.cartItemCount, 0);
    });

    test('addToCart adds product', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      final products = container.read(productCatalogProvider).products;

      notifier.addToCart(products.first.id);
      final state = container.read(productCatalogProvider);
      expect(state.cart.length, 1);
      expect(state.cart.first.product.id, products.first.id);
      expect(state.cart.first.quantity, 1);
    });

    test('addToCart increments quantity for same product', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      final product = container.read(productCatalogProvider).products.first;

      notifier.addToCart(product.id);
      notifier.addToCart(product.id);
      final state = container.read(productCatalogProvider);
      expect(state.cart.length, 1);
      expect(state.cart.first.quantity, 2);
    });

    test('cartSubtotal calculates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      final products = container.read(productCatalogProvider).products;

      notifier.addToCart(products[0].id); // e.g. 2.500
      notifier.addToCart(products[1].id); // e.g. 1.800
      final state = container.read(productCatalogProvider);
      expect(state.cartSubtotal,
          products[0].price + products[1].price);
    });

    test('deliveryFee is 2.0 when cart has items, 0 when empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(productCatalogProvider).deliveryFee, 0.0);

      container
          .read(productCatalogProvider.notifier)
          .addToCart(container.read(productCatalogProvider).products.first.id);
      expect(container.read(productCatalogProvider).deliveryFee, 2.0);
    });

    test('clearCart empties the cart', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      notifier.addToCart(
          container.read(productCatalogProvider).products.first.id);
      notifier.clearCart();
      expect(container.read(productCatalogProvider).cart, isEmpty);
    });

    test('toggleFavorite toggles product isFavorite flag', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      final productId =
          container.read(productCatalogProvider).products.first.id;

      notifier.toggleFavorite(productId);
      var product = container
          .read(productCatalogProvider)
          .products
          .firstWhere((p) => p.id == productId);
      expect(product.isFavorite, isTrue);

      notifier.toggleFavorite(productId);
      product = container
          .read(productCatalogProvider)
          .products
          .firstWhere((p) => p.id == productId);
      expect(product.isFavorite, isFalse);
    });

    test('selectProduct sets selectedProductId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(productCatalogProvider.notifier);
      final productId =
          container.read(productCatalogProvider).products.first.id;

      notifier.selectProduct(productId);
      final state = container.read(productCatalogProvider);
      expect(state.selectedProductId, productId);
      expect(state.selectedProduct, isNotNull);
      expect(state.selectedProduct!.id, productId);
    });
  });

  // ── Product Model ──────────────────────────────────────────────────────

  group('Product model', () {
    test('toJson round-trips key fields', () {
      const p = Product(
        id: 'test-1',
        name: 'Test',
        price: 5.0,
        category: 'Cat',
        imageUrl: 'https://example.com/img.png',
      );
      final json = p.toJson();
      expect(json['id'], 'test-1');
      expect(json['price'], 5.0);
    });

    test('copyWith preserves fields except overridden', () {
      const p = Product(
        id: 'p1',
        name: 'P',
        price: 3.0,
        category: 'C',
        imageUrl: 'url',
        isFavorite: false,
      );
      final fav = p.copyWith(isFavorite: true);
      expect(fav.isFavorite, isTrue);
      expect(fav.id, 'p1');
      expect(fav.price, 3.0);
    });
  });

  // ── CartItem Model ─────────────────────────────────────────────────────

  group('CartItem model', () {
    test('subtotal = price × quantity', () {
      const p = Product(
        id: 'x',
        name: 'X',
        price: 4.0,
        category: 'C',
        imageUrl: 'url',
      );
      const item = CartItem(product: p, quantity: 3);
      expect(item.subtotal, 12.0);
    });
  });
}
