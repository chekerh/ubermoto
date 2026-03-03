import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/driver/providers/driver_provider.dart';
import '../features/products/providers/product_provider.dart';
import '../features/settings/providers/language_provider.dart';
import '../services/delivery_service.dart';

class StitchViewer extends ConsumerStatefulWidget {
  final String assetPath;
  final String title;
  final String? nextRoute;
  final String? routeName;

  const StitchViewer({
    super.key,
    required this.assetPath,
    required this.title,
    this.nextRoute,
    this.routeName,
  });

  @override
  ConsumerState<StitchViewer> createState() => _StitchViewerState();
}

class _StitchViewerState extends ConsumerState<StitchViewer> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _isActionLoading = false;
  static String? _logoBase64Cache;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'StitchBridge',
        onMessageReceived: (message) => _handleBridgeMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (mounted) {
              setState(() => _loading = false);
            }
            await _installRouteBindings();
          },
        ),
      )
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (_isActionLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.2),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );

    if (_supportsDoubleTapAdvance) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: _handleDoubleTap,
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: content,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DOUBLE-TAP ADVANCE (splash screens)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _handleDoubleTap() async {
    if (!_supportsDoubleTapAdvance) return;

    // On splash1 save the language choice
    if (widget.routeName == '/splash1') {
      try {
        final selectedValue = await _controller.runJavaScriptReturningResult(
          "(() => document.querySelector('input[name=\"language_select\"]:checked')?.value || '')();",
        );

        if (!mounted) return;

        final selected =
            selectedValue.toString().replaceAll('"', '').toLowerCase();
        ref.read(languageProvider.notifier).setFromString(selected);

        if (selected.contains('arab') || selected.contains('derja')) {
          await context.setLocale(const Locale('ar', 'SA'));
        } else {
          await context.setLocale(const Locale('en', 'US'));
        }
      } catch (_) {
        // Ignore JS errors and continue.
      }
    }

    if (widget.nextRoute != null && mounted) {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute!);
    }
  }

  bool get _supportsDoubleTapAdvance {
    final routeName = widget.routeName ?? '';
    return routeName.startsWith('/splash');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ROUTE BINDINGS DISPATCHER
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _installRouteBindings() async {
    final routeName = widget.routeName ?? '';

    // Inject the universal bind helper and language translations
    await _injectBindHelper();
    await _injectTranslations();

    switch (routeName) {
      case '/splash1':
        await _injectSplash1Bindings();
      case '/splash2':
        await _injectSplash2Bindings();
      case '/splash3':
        await _injectSplash3Bindings();
      case '/splash4':
        await _injectSplash4Bindings();
      case '/login1':
      case '/login2':
        await _injectLoginBindings();
      case '/register1':
      case '/register2':
        await _injectRegisterBindings();
      case '/customer/home':
        await _injectCustomerHomeBindings();
      case '/customer/product':
        await _injectProductBindings();
      case '/customer/cart':
        await _injectCartBindings();
      case '/customer/checkout-promos':
        await _injectCheckoutPromosBindings();
      case '/customer/order-confirm':
        await _injectOrderConfirmationBindings();
      case '/customer/live-tracking':
        await _injectLiveTrackingBindings();
      case '/customer/filters':
        await _injectFiltersBindings();
      case '/customer/ai-order':
        await _injectAiOrderBindings();
      case '/customer/ai-voice':
        await _injectAiVoiceBindings();
      case '/customer/notifications':
        await _injectNotificationsBindings();
      case '/driver/dashboard':
        await _injectDriverDashboardBindings();
      case '/driver/active-job':
        await _injectActiveJobBindings();
      case '/driver/docs':
        await _injectDriverDocsBindings();
      case '/driver/motorcycle-select':
        await _injectMotorcycleSelectBindings();
      case '/driver/rating':
        await _injectDriverRatingBindings();
      case '/driver/training':
        await _injectDriverTrainingBindings();
      case '/driver/sos':
        await _injectDriverSosBindings();
      case '/driver/earnings':
        await _injectDriverEarningsBindings();
      case '/driver/profile':
        await _injectDriverProfileBindings();
      case '/admin/console':
        await _injectAdminConsoleBindings();
      case '/admin/catalog':
        await _injectAdminCatalogBindings();
      case '/admin/analytics':
        await _injectAdminAnalyticsBindings();
      case '/biometric-otp':
        await _injectBiometricOtpBindings();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // UNIVERSAL BIND HELPER (injected once per page)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectBindHelper() async {
    await _controller.runJavaScript(r'''
      (() => {
        if (window.__stitchBindHelper) return;
        window.__stitchBindHelper = true;

        window.stitchBind = (element, action, payload) => {
          if (!element || element.dataset.flutterBound === '1') return;
          element.dataset.flutterBound = '1';
          element.addEventListener('click', (event) => {
            event.preventDefault();
            event.stopPropagation();
            const msg = payload
              ? JSON.stringify({ action, payload })
              : JSON.stringify({ action });
            window.StitchBridge.postMessage(msg);
          });
        };

        window.stitchFindByText = (selector, textMatch) => {
          const els = Array.from(document.querySelectorAll(selector));
          return els.find(el => {
            const t = (el.textContent || '').toLowerCase().trim();
            if (Array.isArray(textMatch)) {
              return textMatch.some(m => t.includes(m.toLowerCase()));
            }
            return t.includes(textMatch.toLowerCase());
          });
        };

        window.stitchFindByIcon = (iconName) => {
          const icons = Array.from(document.querySelectorAll('.material-symbols-outlined, .material-symbols-rounded, .material-icons, [class*="material"]'));
          const icon = icons.find(el => (el.textContent || '').trim() === iconName);
          return icon ? (icon.closest('button') || icon.closest('a') || icon.parentElement) : null;
        };

        window.stitchBindBottomNav = (navMap) => {
          const navLinks = document.querySelectorAll('nav a, nav button');
          navLinks.forEach(link => {
            const text = (link.textContent || '').toLowerCase().trim();
            for (const [keywords, action] of Object.entries(navMap)) {
              const keys = keywords.split('|');
              if (keys.some(k => text.includes(k))) {
                stitchBind(link, action);
                break;
              }
            }
          });
        };
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRANSLATION INJECTION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectTranslations() async {
    final lang = ref.read(languageProvider);
    final isRtl = lang.isRtl;
    final langCode = lang.code;

    // Inject RTL direction if needed
    if (isRtl) {
      await _controller.runJavaScript('''
        document.documentElement.setAttribute('dir', 'rtl');
        document.body.style.direction = 'rtl';
      ''');
    }

    // Build JS translation map from Dart
    final translationEntries = <String>[];
    for (final entry in uiTranslations.entries) {
      final translated = entry.value[langCode];
      if (translated != null) {
        final escapedKey = entry.key.replaceAll("'", "\\'");
        final escapedVal = translated.replaceAll("'", "\\'");
        translationEntries.add("'$escapedKey': '$escapedVal'");
      }
    }

    if (translationEntries.isNotEmpty && langCode != 'en') {
      final mapStr = '{${translationEntries.join(',')}}';
      await _controller.runJavaScript('''
        (() => {
          const translations = $mapStr;
          const textNodes = document.querySelectorAll('span, button, a');
          textNodes.forEach(el => {
            const text = (el.textContent || '').trim();
            if (translations[text]) {
              el.textContent = translations[text];
            }
          });
        })();
      ''');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOGO INJECTION HELPER
  // ═══════════════════════════════════════════════════════════════════

  /// Injects the Nassib logo into elements with the given [imgId] and hides
  /// the fallback element with [fallbackId].
  Future<void> _injectLogo({
    String imgId = 'nassib-logo',
    String fallbackId = 'nassib-logo-fallback',
  }) async {
    try {
      _logoBase64Cache ??= base64Encode(
        (await rootBundle.load('assets/nassib-logo.png')).buffer.asUint8List(),
      );
      await _controller.runJavaScript('''
        (() => {
          const logo = document.getElementById('$imgId');
          const fallback = document.getElementById('$fallbackId');
          if (logo) {
            logo.src = 'data:image/png;base64,$_logoBase64Cache';
            logo.classList.remove('hidden');
            if (fallback) fallback.classList.add('hidden');
          }
        })();
      ''');
    } catch (e) {
      debugPrint('Logo injection failed: \$e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DYNAMIC CONTENT INJECTION (Products, Cart, Checkout)
  // ═══════════════════════════════════════════════════════════════════

  /// Injects product cards into the `#products-grid` container on the
  /// customer home screen, replacing loading skeletons with real data.
  Future<void> _injectProductsGrid() async {
    final catalog = ref.read(productCatalogProvider);
    final products = catalog.popularProducts.isNotEmpty
        ? catalog.popularProducts
        : catalog.products;

    if (products.isEmpty) return;

    final cardsHtml = StringBuffer();
    for (final p in products) {
      final priceStr = p.price.toStringAsFixed(3);
      final escapedName = p.name.replaceAll("'", "\\'");
      final discount = p.originalPrice != null
          ? '<span class="absolute top-2 left-2 bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">-${((1 - p.price / p.originalPrice!) * 100).round()}%</span>'
          : '';
      final favIcon = p.isFavorite ? 'favorite' : 'favorite_border';
      final favFill = p.isFavorite ? "font-variation-settings: 'FILL' 1;" : '';
      cardsHtml.write('''
<div data-product-id="${p.id}" class="product-card flex flex-col gap-2 cursor-pointer group">
  <div class="relative aspect-square w-full overflow-hidden rounded-2xl bg-stone-100 dark:bg-stone-800">
    <img src="${p.imageUrl}" alt="$escapedName" class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-110" />
    $discount
    <button data-fav-id="${p.id}" class="fav-btn absolute top-2 right-2 h-8 w-8 rounded-full bg-white/80 dark:bg-black/50 flex items-center justify-center text-red-500 shadow-sm backdrop-blur-sm">
      <span class="material-symbols-outlined text-[18px]" style="$favFill">$favIcon</span>
    </button>
  </div>
  <div class="px-1">
    <h4 class="text-sm font-bold text-slate-900 dark:text-white truncate">$escapedName</h4>
    <div class="flex items-center justify-between mt-1">
      <span class="text-primary font-bold text-sm">$priceStr DT</span>
      <span class="text-[10px] text-stone-400 dark:text-stone-500">${p.unit}</span>
    </div>
    <div class="flex items-center gap-1 mt-1">
      <span class="material-symbols-outlined text-yellow-500 text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
      <span class="text-[11px] font-medium text-stone-500">${p.rating} (${p.reviewCount})</span>
    </div>
  </div>
</div>
''');
    }

    final escapedHtml =
        cardsHtml.toString().replaceAll('\\', '\\\\').replaceAll('`', '\\`');

    await _controller.runJavaScript('''
      (() => {
        const grid = document.getElementById('products-grid');
        if (!grid) return;
        grid.innerHTML = `$escapedHtml`;

        // Bind product card clicks → open_product with product ID
        grid.querySelectorAll('.product-card').forEach(card => {
          const pid = card.dataset.productId;
          card.addEventListener('click', (e) => {
            // Ignore if clicking favorite button
            if (e.target.closest('.fav-btn')) return;
            window.StitchBridge.postMessage(JSON.stringify({
              action: 'select_and_open_product',
              payload: { productId: pid }
            }));
          });
        });

        // Bind favorite buttons
        grid.querySelectorAll('.fav-btn').forEach(btn => {
          btn.addEventListener('click', (e) => {
            e.stopPropagation();
            window.StitchBridge.postMessage(JSON.stringify({
              action: 'toggle_favorite',
              payload: { productId: btn.dataset.favId }
            }));
          });
        });
      })();
    ''');
  }

  /// Injects the selected product's details into the product detail screen.
  Future<void> _injectProductDetails() async {
    final catalog = ref.read(productCatalogProvider);
    final product = catalog.selectedProduct;
    final cartCount = catalog.cartItemCount;

    if (product == null) return;

    final escapedName = product.name.replaceAll("'", "\\'");
    final escapedDesc = product.description.replaceAll("'", "\\'");
    final escapedDescAr = product.descriptionAr.replaceAll("'", "\\'");
    final priceStr = product.price.toStringAsFixed(3);

    // Build tags HTML
    final tagsHtml = StringBuffer();
    for (final tag in product.tags) {
      final escapedTag = tag.replaceAll("'", "\\'");
      String bgClass = 'bg-stone-100 dark:bg-stone-800';
      String textClass = 'text-stone-600 dark:text-stone-300';
      String icon = '';
      if (tag.toLowerCase().contains('spicy')) {
        bgClass = 'bg-orange-100 dark:bg-orange-900/30';
        textClass = 'text-orange-800 dark:text-orange-200';
        icon =
            '<span class="material-symbols-outlined mr-1 text-[14px]">local_fire_department</span>';
      } else if (tag.toLowerCase().contains('bio')) {
        bgClass = 'bg-green-100 dark:bg-green-900/30';
        textClass = 'text-green-800 dark:text-green-200';
        icon =
            '<span class="material-symbols-outlined mr-1 text-[14px]">eco</span>';
      }
      tagsHtml.write(
          '<span class="inline-flex items-center rounded-full $bgClass px-2.5 py-0.5 text-xs font-medium $textClass">$icon$escapedTag</span>');
    }

    // Build related products HTML
    final relatedProducts =
        catalog.products.where((p) => p.id != product.id).take(3);
    final relatedHtml = StringBuffer();
    for (final rp in relatedProducts) {
      final rpName = rp.name.replaceAll("'", "\\'");
      relatedHtml.write('''
<div data-product-id="${rp.id}" class="related-card snap-start shrink-0 w-36 flex flex-col gap-2 group cursor-pointer">
  <div class="relative aspect-square w-full overflow-hidden rounded-xl bg-stone-100 dark:bg-stone-800">
    <img src="${rp.imageUrl}" alt="$rpName" class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-110" />
    <button data-add-id="${rp.id}" class="quick-add-btn absolute bottom-2 right-2 h-8 w-8 rounded-full bg-white dark:bg-stone-700 shadow-sm flex items-center justify-center text-primary hover:bg-primary hover:text-white transition-colors">
      <span class="material-symbols-outlined text-[18px]">add</span>
    </button>
  </div>
  <div>
    <h4 class="text-sm font-semibold text-slate-900 dark:text-white truncate">$rpName</h4>
    <p class="text-xs font-medium text-stone-500 dark:text-stone-400">${rp.unit} • ${rp.price.toStringAsFixed(3)} DT</p>
  </div>
</div>
''');
    }

    final escapedTags =
        tagsHtml.toString().replaceAll('\\', '\\\\').replaceAll('`', '\\`');
    final escapedRelated =
        relatedHtml.toString().replaceAll('\\', '\\\\').replaceAll('`', '\\`');

    await _controller.runJavaScript('''
      (() => {
        const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
        const setHtml = (id, val) => { const el = document.getElementById(id); if (el) el.innerHTML = val; };
        const setSrc = (id, val) => { const el = document.getElementById(id); if (el) el.src = val; };

        set('product-header-title', '$escapedName');
        set('product-name', '$escapedName');
        set('product-unit', '${product.unit}');
        set('product-price', '$priceStr DT');
        set('product-cart-count', '$cartCount');
        set('product-description', '$escapedDesc');
        set('product-description-ar', '$escapedDescAr');
        setSrc('product-image', '${product.imageUrl}');
        setHtml('product-tags', `$escapedTags`);

        // Related products
        const relatedEl = document.getElementById('product-related');
        if (relatedEl) {
          relatedEl.innerHTML = `$escapedRelated`;
          relatedEl.querySelectorAll('.related-card').forEach(card => {
            card.addEventListener('click', (e) => {
              if (e.target.closest('.quick-add-btn')) return;
              window.StitchBridge.postMessage(JSON.stringify({
                action: 'select_and_open_product',
                payload: { productId: card.dataset.productId }
              }));
            });
          });
          relatedEl.querySelectorAll('.quick-add-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
              e.stopPropagation();
              window.StitchBridge.postMessage(JSON.stringify({
                action: 'quick_add_to_cart',
                payload: { productId: btn.dataset.addId }
              }));
            });
          });
        }
      })();
    ''');
  }

  /// Injects cart items and totals into the cart/checkout screen.
  Future<void> _injectCartData() async {
    final catalog = ref.read(productCatalogProvider);
    final cart = catalog.cart;

    if (cart.isEmpty) {
      // Show empty cart message
      await _controller.runJavaScript('''
        (() => {
          const container = document.getElementById('cart-items-container');
          if (container) {
            container.innerHTML = '<div class="flex flex-col items-center justify-center py-12 text-center">'
              + '<span class="material-symbols-outlined text-stone-300 dark:text-stone-600 text-[64px] mb-4">shopping_cart</span>'
              + '<p class="text-lg font-bold text-stone-400 dark:text-stone-500">Your cart is empty</p>'
              + '<p class="text-sm text-stone-400 dark:text-stone-600 mt-1">Add some products to get started!</p>'
              + '</div>';
          }
          const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
          set('cart-subtotal', '0.000 DT');
          set('cart-delivery-fee', '0.000 DT');
          set('cart-total', '0.000 DT');
        })();
      ''');
      return;
    }

    final itemsHtml = StringBuffer();
    for (final ci in cart) {
      final p = ci.product;
      final escapedName = p.name.replaceAll("'", "\\'");
      final subtotalStr = ci.subtotal.toStringAsFixed(3);
      itemsHtml.write('''
<div class="cart-item flex items-center gap-4 rounded-xl bg-white dark:bg-stone-800 p-3 shadow-sm border border-stone-100 dark:border-stone-700" data-product-id="${p.id}">
  <img src="${p.imageUrl}" alt="$escapedName" class="rounded-lg size-16 shrink-0 object-cover" />
  <div class="flex flex-col justify-center flex-1 min-w-0">
    <p class="text-sm font-bold text-slate-900 dark:text-slate-100 truncate">$escapedName</p>
    <p class="text-xs text-stone-400 dark:text-stone-500">${p.unit}</p>
    <p class="text-sm font-bold text-primary mt-1">$subtotalStr DT</p>
  </div>
  <div class="flex items-center gap-1">
    <button data-qty-action="minus" data-pid="${p.id}" class="cart-qty-btn h-8 w-8 rounded-full bg-stone-100 dark:bg-stone-700 flex items-center justify-center text-stone-600 dark:text-stone-300 hover:bg-primary hover:text-white transition-colors">
      <span class="material-symbols-outlined text-[16px]">${ci.quantity > 1 ? 'remove' : 'delete'}</span>
    </button>
    <span class="w-6 text-center text-sm font-bold">${ci.quantity}</span>
    <button data-qty-action="plus" data-pid="${p.id}" class="cart-qty-btn h-8 w-8 rounded-full bg-stone-100 dark:bg-stone-700 flex items-center justify-center text-stone-600 dark:text-stone-300 hover:bg-primary hover:text-white transition-colors">
      <span class="material-symbols-outlined text-[16px]">add</span>
    </button>
  </div>
</div>
''');
    }

    final escapedItems =
        itemsHtml.toString().replaceAll('\\', '\\\\').replaceAll('`', '\\`');
    final subtotal = catalog.cartSubtotal.toStringAsFixed(3);
    final fee = catalog.deliveryFee.toStringAsFixed(3);
    final total = catalog.cartTotal.toStringAsFixed(3);

    await _controller.runJavaScript('''
      (() => {
        const container = document.getElementById('cart-items-container');
        if (container) {
          container.innerHTML = `$escapedItems`;

          // Bind quantity buttons
          container.querySelectorAll('.cart-qty-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
              e.stopPropagation();
              const action = btn.dataset.qtyAction;
              const pid = btn.dataset.pid;
              window.StitchBridge.postMessage(JSON.stringify({
                action: 'update_cart_qty',
                payload: { productId: pid, direction: action }
              }));
            });
          });
        }

        const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
        set('cart-subtotal', '$subtotal DT');
        set('cart-delivery-fee', '$fee DT');
        set('cart-total', '$total DT');
      })();
    ''');
  }

  /// Injects dynamic totals into the checkout/promo screen.
  Future<void> _injectCheckoutTotals() async {
    final catalog = ref.read(productCatalogProvider);
    final subtotal = catalog.cartSubtotal.toStringAsFixed(3);
    final fee = catalog.deliveryFee.toStringAsFixed(3);
    final total = catalog.cartTotal.toStringAsFixed(3);

    await _controller.runJavaScript('''
      (() => {
        const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
        set('checkout-subtotal', '$subtotal DT');
        set('checkout-delivery-fee', '$fee DT');
        set('checkout-discount', '-0.000 DT');
        set('checkout-total', '$total DT');
      })();
    ''');
  }

  /// Injects the order total into the confirmation screen.
  Future<void> _injectOrderConfirmTotal() async {
    final catalog = ref.read(productCatalogProvider);
    final total = catalog.cartTotal.toStringAsFixed(3);

    await _controller.runJavaScript('''
      (() => {
        const el = document.getElementById('confirm-total');
        if (el) {
          el.innerHTML = '$total <span class="text-sm font-medium text-slate-500 dark:text-slate-400">DT</span>';
        }
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // SPLASH SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectSplash1Bindings() async {
    await _injectLogo();

    await _controller.runJavaScript(r'''
      (() => {
        const getStarted = document.getElementById('splash-get-started');
        stitchBind(getStarted, 'open_login');
      })();
    ''');
  }

  Future<void> _injectSplash2Bindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'go_back');

        const helpBtn = stitchFindByIcon('help') || stitchFindByIcon('help_outline');
        stitchBind(helpBtn, 'show_help');

        const payoutBtn = stitchFindByText('button', ['payout', 'request']);
        stitchBind(payoutBtn, 'show_info', { message: 'Payout requests are processed within 24-48 hours.' });

        const viewAll = stitchFindByText('a,button', ['view all', 'voir tout']);
        stitchBind(viewAll, 'show_info', { message: 'Full transaction history coming soon.' });

        stitchBindBottomNav({
          'home|accueil': 'open_splash3',
          'earning|revenu': 'noop',
          'scanner|scan': 'show_coming_soon',
          'activity|activit': 'open_splash4',
          'profile|profil': 'open_splash3',
        });
      })();
    ''');
  }

  Future<void> _injectSplash3Bindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const editBtn = stitchFindByIcon('edit') || stitchFindByIcon('create');
        stitchBind(editBtn, 'show_info', { message: 'Profile editing will be available after sign-up.' });

        const cameraBtn = stitchFindByIcon('camera_alt') || stitchFindByIcon('photo_camera');
        stitchBind(cameraBtn, 'show_coming_soon');

        const rows = document.querySelectorAll('[class*="cursor-pointer"]');
        rows.forEach(row => {
          if (row.closest('nav')) return;
          const text = (row.textContent || '').toLowerCase();
          if (text.includes('language') || text.includes('langue')) {
            stitchBind(row, 'show_info', { message: 'Language can be changed from the splash screen.' });
          } else if (text.includes('help') || text.includes('aide') || text.includes('support')) {
            stitchBind(row, 'show_help');
          } else if (text.includes('about') || text.includes('propos')) {
            stitchBind(row, 'show_info', { message: 'Nassib v1.0.2 — Motorcycle delivery for Tunisia.' });
          } else if (text.includes('log out') || text.includes('connexion') || text.includes('logout')) {
            stitchBind(row, 'logout');
          } else if (text.includes('home') || text.includes('maison') || text.includes('work') || text.includes('travail')) {
            stitchBind(row, 'show_info', { message: 'Saved places will be available after sign-up.' });
          }
        });

        stitchBindBottomNav({
          'home|accueil': 'open_splash2',
          'trip|trajet': 'open_splash4',
          'wallet|portefeuille': 'open_splash2',
          'account|compte': 'noop',
        });
      })();
    ''');
  }

  Future<void> _injectSplash4Bindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_splash3');

        const filterBtn = stitchFindByIcon('filter_list') || stitchFindByIcon('tune');
        stitchBind(filterBtn, 'show_info', { message: 'Order filters will be available after you place orders.' });

        const reorderBtns = Array.from(document.querySelectorAll('button')).filter(
          el => (el.textContent || '').toLowerCase().includes('reorder')
        );
        reorderBtns.forEach(btn => {
          stitchBind(btn, 'show_info', { message: 'Reorder will add previous items to your cart.' });
        });

        stitchBindBottomNav({
          'home|accueil': 'open_splash2',
          'order|commande': 'noop',
          'wallet|portefeuille': 'open_splash2',
          'account|compte': 'open_splash3',
        });

        const fab = document.querySelector('nav [class*="rounded-full"][class*="bg-primary"]');
        stitchBind(fab, 'show_info', { message: 'Quick ride ordering — sign up first!' });
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectLoginBindings() async {
    // Inject mini logo into login header
    await _injectLogo(imgId: 'login-logo', fallbackId: 'login-logo-fallback');

    await _controller.runJavaScript('''
      (() => {
        const phoneTab = document.getElementById('login-tab-phone');
        const emailTab = document.getElementById('login-tab-email');
        const phoneField = document.getElementById('login-phone-field');
        const emailField = document.getElementById('login-email-field');
        const modeHint = document.getElementById('login-mode-hint');

        const activateTab = (mode) => {
          const isEmail = mode === 'email';
          if (emailTab) {
            emailTab.dataset.active = isEmail ? '1' : '0';
            emailTab.classList.toggle('border-primary', isEmail);
            emailTab.classList.toggle('text-slate-900', isEmail);
            emailTab.classList.toggle('dark:text-white', isEmail);
            emailTab.classList.toggle('border-transparent', !isEmail);
            emailTab.classList.toggle('text-slate-500', !isEmail);
            emailTab.classList.toggle('dark:text-slate-400', !isEmail);
          }
          if (phoneTab) {
            phoneTab.dataset.active = isEmail ? '0' : '1';
            phoneTab.classList.toggle('border-primary', !isEmail);
            phoneTab.classList.toggle('text-slate-900', !isEmail);
            phoneTab.classList.toggle('dark:text-white', !isEmail);
            phoneTab.classList.toggle('border-transparent', isEmail);
            phoneTab.classList.toggle('text-slate-500', isEmail);
            phoneTab.classList.toggle('dark:text-slate-400', isEmail);
          }
          if (emailField) emailField.classList.toggle('hidden', !isEmail);
          if (phoneField) phoneField.classList.toggle('hidden', isEmail);
          if (modeHint) {
            modeHint.textContent = 'Use email or phone number with your password.';
          }
        };

        const loginButton = document.getElementById('auth-login-btn');
        if (loginButton && loginButton.dataset.flutterBound !== '1') {
          loginButton.dataset.flutterBound = '1';
          loginButton.addEventListener('click', (event) => {
            event.preventDefault();
            const isEmail = (emailTab?.dataset.active || '1') === '1';
            const email = (document.getElementById('login-email')?.value || '').trim();
            const phone = (document.getElementById('login-phone')?.value || '').trim();
            const password = (document.getElementById('login-password')?.value || '').trim();
            window.StitchBridge.postMessage(JSON.stringify({
              action: 'login_submit',
              payload: { mode: isEmail ? 'email' : 'phone', email, phone, password }
            }));
          });
        }

        const registerLink =
          document.getElementById('auth-register-link') ||
          Array.from(document.querySelectorAll('a')).find(
            (el) => {
              const text = (el.textContent || '').toLowerCase();
              return text.includes('register') || text.includes('inscription') || text.includes("s'inscrire");
            }
          );
        stitchBind(registerLink, 'open_register');

        // Biometric/OTP link (if present)
        const biometricLink = Array.from(document.querySelectorAll('a, button')).find(
          (el) => {
            const text = (el.textContent || '').toLowerCase();
            return text.includes('biometric') || text.includes('otp') || text.includes('fingerprint') || text.includes('biom');
          }
        );
        stitchBind(biometricLink, 'open_biometric_otp');

        if (emailTab && emailTab.dataset.flutterBound !== '1') {
          emailTab.dataset.flutterBound = '1';
          emailTab.addEventListener('click', () => activateTab('email'));
        }
        if (phoneTab && phoneTab.dataset.flutterBound !== '1') {
          phoneTab.dataset.flutterBound = '1';
          phoneTab.addEventListener('click', () => activateTab('phone'));
        }

        activateTab((emailTab?.dataset.active || '1') === '1' ? 'email' : 'phone');
      })();
    ''');
  }

  Future<void> _injectRegisterBindings() async {
    await _controller.runJavaScript('''
      (() => {
        const submit = document.getElementById('register-submit-btn') ||
          stitchFindByText('button', ['suivant', 'submit', 'register', "s'inscrire"]);

        if (submit && submit.dataset.flutterBound !== '1') {
          submit.dataset.flutterBound = '1';
          submit.addEventListener('click', (event) => {
            event.preventDefault();
            const name = (document.getElementById('register-name')?.value || '').trim();
            const phone = (document.getElementById('register-phone')?.value || '').trim();
            const email = (document.getElementById('register-email')?.value || '').trim();
            const password = (document.getElementById('register-password')?.value || '').trim();
            const license = (document.getElementById('register-license')?.value || '').trim();
            const role = (document.querySelector('input[name="role"]:checked')?.value || 'client').trim();

            window.StitchBridge.postMessage(JSON.stringify({
              action: 'register_submit',
              payload: { name, phone, email, password, license, role }
            }));
          });
        }

        const loginLink =
          document.getElementById('register-login-link') ||
          Array.from(document.querySelectorAll('a')).find(
            (el) => {
              const text = (el.textContent || '').toLowerCase();
              return text.includes('connecter') || text.includes('login') || text.includes('sign in');
            }
          );
        stitchBind(loginLink, 'open_login');
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // CUSTOMER SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectCustomerHomeBindings() async {
    // Inject dynamic product cards from provider
    await _injectProductsGrid();

    await _controller.runJavaScript(r'''
      (() => {
        // Profile button
        stitchBind(document.getElementById('home-profile-btn'), 'open_notifications');

        // Filter button
        stitchBind(document.getElementById('home-filter-btn'), 'open_filters');

        // Promo banner
        stitchBind(document.getElementById('home-promo-btn'), 'show_info', { message: 'Check back for seasonal promotions and discounts!' });

        // Search — navigate on Enter, not on focus
        const searchInput = document.getElementById('home-search');
        if (searchInput && searchInput.dataset.flutterBound !== '1') {
          searchInput.dataset.flutterBound = '1';
          searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
              window.StitchBridge.postMessage(JSON.stringify({ action: 'open_filters' }));
            }
          });
        }

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'noop');
        stitchBind(document.getElementById('nav-orders'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-cart'), 'open_cart');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectProductBindings() async {
    // Inject dynamic product detail data
    await _injectProductDetails();

    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('product-back-btn'), 'go_back');

        // Cart icon in header
        stitchBind(document.getElementById('product-cart-btn'), 'open_cart');

        // Add to Cart button
        stitchBind(document.getElementById('product-add-to-cart'), 'add_to_cart_and_go');

        // Quantity controls
        const qtyEl = document.getElementById('product-qty');
        const minusBtn = document.getElementById('product-qty-minus');
        const plusBtn = document.getElementById('product-qty-plus');
        if (qtyEl && minusBtn && plusBtn) {
          let qty = parseInt(qtyEl.textContent) || 1;
          if (minusBtn.dataset.flutterBound !== '1') {
            minusBtn.dataset.flutterBound = '1';
            minusBtn.addEventListener('click', (e) => {
              e.preventDefault();
              if (qty > 1) { qty--; qtyEl.textContent = qty; }
            });
          }
          if (plusBtn.dataset.flutterBound !== '1') {
            plusBtn.dataset.flutterBound = '1';
            plusBtn.addEventListener('click', (e) => {
              e.preventDefault();
              if (qty < 20) { qty++; qtyEl.textContent = qty; }
            });
          }
        }

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-search'), 'open_filters');
        stitchBind(document.getElementById('nav-orders'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectCartBindings() async {
    // Inject dynamic cart items and totals
    await _injectCartData();

    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('cart-back-btn'), 'go_back');

        // Confirm order → checkout
        stitchBind(document.getElementById('cart-confirm-btn'), 'open_checkout_promos');

        // Edit delivery address
        stitchBind(document.getElementById('cart-edit-address'), 'show_info', { message: 'Delivery address can be changed at checkout.' });

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-cart'), 'noop');
        stitchBind(document.getElementById('nav-orders'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectCheckoutPromosBindings() async {
    // Inject dynamic checkout totals
    await _injectCheckoutTotals();

    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('checkout-back-btn'), 'go_back');

        // Confirm order → order confirmation
        stitchBind(document.getElementById('checkout-confirm-btn'), 'open_order_confirm');

        // Apply promo code (text fallback — no specific ID)
        const applyBtn = stitchFindByText('button', ['apply', 'appliquer']);
        if (applyBtn) stitchBind(applyBtn, 'show_info', { message: 'Promo code applied! 10% discount.' });

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-activity'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-cart'), 'open_cart');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectOrderConfirmationBindings() async {
    // Inject dynamic order total
    await _injectOrderConfirmTotal();

    await _controller.runJavaScript(r'''
      (() => {
        // Back to home
        stitchBind(document.getElementById('confirm-back-btn'), 'open_customer_home');

        // Track order → live tracking
        stitchBind(document.getElementById('confirm-track-btn'), 'open_live_tracking');

        // Cancel order → back to home
        stitchBind(document.getElementById('confirm-cancel-btn'), 'open_customer_home');

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-activity'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectLiveTrackingBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('tracking-back-btn'), 'go_back');

        // Help button
        stitchBind(document.getElementById('tracking-help-btn'), 'show_help');

        // Chat driver
        stitchBind(document.getElementById('tracking-chat-btn'), 'show_coming_soon');

        // Call driver
        stitchBind(document.getElementById('tracking-call-btn'), 'show_coming_soon');

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-activity'), 'noop');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectFiltersBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('filters-back-btn'), 'go_back');

        // Cart icon
        stitchBind(document.getElementById('filters-cart-btn'), 'open_cart');

        // Favorite buttons (icon fallback — multiple dynamic items)
        const favBtns = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'favorite_border';
        });
        favBtns.forEach(btn => stitchBind(btn, 'show_info', { message: 'Added to favorites!' }));

        // Add to cart buttons (icon fallback — multiple dynamic items)
        const addBtns = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && ['add', 'add_circle', 'add_shopping_cart'].includes((icon.textContent || '').trim());
        });
        addBtns.forEach(btn => stitchBind(btn, 'show_added_to_cart'));

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-market'), 'noop');
        stitchBind(document.getElementById('nav-orders'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectAiOrderBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('ai-order-back-btn'), 'go_back');

        // Add to Cart button
        stitchBind(document.getElementById('ai-order-add-cart'), 'open_cart');

        // Mic button
        stitchBind(document.getElementById('ai-order-mic-btn'), 'show_info', { message: 'Listening... Speak your order in Derja or French.' });

        // Text input — Enter to send
        const textInput = document.getElementById('ai-order-input');
        if (textInput && textInput.dataset.flutterBound !== '1') {
          textInput.dataset.flutterBound = '1';
          textInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
              window.StitchBridge.postMessage(JSON.stringify({
                action: 'show_info',
                payload: { message: 'Processing your order: "' + textInput.value + '"' }
              }));
            }
          });
        }

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-smart-order'), 'noop');
        stitchBind(document.getElementById('nav-activity'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectAiVoiceBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('voice-back-btn'), 'go_back');

        // Main mic button
        stitchBind(document.getElementById('voice-mic-btn'), 'show_info', { message: 'Listening... Say your order in Derja, Arabic, or French.' });

        // Suggestion chips (text matching — dynamic content)
        const chips = Array.from(document.querySelectorAll('button[class*="rounded-full"]')).filter(el => !el.closest('nav'));
        chips.forEach(chip => {
          const text = (chip.textContent || '').toLowerCase();
          if (text.includes('bread') || text.includes('pain')) {
            stitchBind(chip, 'show_added_to_cart');
          } else if (text.includes('confirm') || text.includes('confirmer')) {
            stitchBind(chip, 'open_order_confirm');
          } else if (text.includes('cancel') || text.includes('annuler')) {
            stitchBind(chip, 'go_back');
          }
        });

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-orders'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-voice'), 'noop');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'open_notifications');
      })();
    ''');
  }

  Future<void> _injectNotificationsBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        // Back button
        stitchBind(document.getElementById('notif-back-btn'), 'go_back');

        // Reorder + buttons (icon fallback — multiple dynamic items)
        const addBtns = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'add';
        });
        addBtns.forEach(btn => stitchBind(btn, 'open_cart'));

        // Bottom nav
        stitchBind(document.getElementById('nav-home'), 'open_customer_home');
        stitchBind(document.getElementById('nav-activity'), 'open_live_tracking');
        stitchBind(document.getElementById('nav-wallet'), 'show_coming_soon');
        stitchBind(document.getElementById('nav-profile'), 'noop');
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // DRIVER SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectDriverDashboardBindings() async {
    // Load driver profile when entering dashboard
    final authState = ref.read(authStateProvider);
    if (authState.user != null) {
      ref
          .read(driverAvailabilityProvider.notifier)
          .loadDriverProfile(authState.user!.id);
    }

    await _controller.runJavaScript(r'''
      (() => {
        // Notifications bell
        const bellBtn = stitchFindByIcon('notifications') || stitchFindByIcon('notifications_none');
        stitchBind(bellBtn, 'show_info', { message: 'No new notifications.' });

        // Online/Offline toggle (checkbox-based)
        const toggle = document.querySelector('input[type="checkbox"]');
        if (toggle && toggle.dataset.flutterBound !== '1') {
          toggle.dataset.flutterBound = '1';
          toggle.addEventListener('change', () => {
            window.StitchBridge.postMessage(JSON.stringify({ action: 'driver_toggle_availability' }));
          });
        }

        // Accept delivery
        const acceptBtn = stitchFindByText('button', ['accept', 'accepter']);
        stitchBind(acceptBtn, 'driver_accept_delivery');

        // Decline delivery
        const declineBtn = stitchFindByText('button', ['decline', 'refuser']);
        stitchBind(declineBtn, 'driver_decline_delivery');

        // Wire up any links that match driver sub-screens
        const allLinks = document.querySelectorAll('a, button, [class*="cursor-pointer"]');
        allLinks.forEach(el => {
          if (el.closest('nav')) return;
          const text = (el.textContent || '').toLowerCase();
          if (text.includes('motorcycle') || text.includes('vehicle') || text.includes('moto')) {
            stitchBind(el, 'open_motorcycle_select');
          } else if (text.includes('training') || text.includes('formation') || text.includes('learn')) {
            stitchBind(el, 'open_driver_training');
          } else if (text.includes('sos') || text.includes('emergency') || text.includes('urgence')) {
            stitchBind(el, 'open_driver_sos');
          } else if (text.includes('rating') || text.includes('feedback') || text.includes('valuation')) {
            stitchBind(el, 'open_driver_rating');
          }
        });

        // Bottom nav: Dashboard, Wallet, Docs, Profile
        stitchBindBottomNav({
          'dashboard|tableau': 'noop',
          'wallet|portefeuille|earning|revenu': 'open_driver_earnings',
          'doc|document': 'open_driver_docs',
          'profile|profil|compte': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectActiveJobBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_driver_dashboard');

        const helpBtn = stitchFindByIcon('help') || stitchFindByIcon('help_outline');
        stitchBind(helpBtn, 'show_help');

        // Recenter map — UI-only
        const recenterBtn = stitchFindByIcon('my_location') || stitchFindByIcon('gps_fixed');
        if (recenterBtn) stitchBind(recenterBtn, 'noop');

        // Navigate
        const navBtn = stitchFindByIcon('navigation') || stitchFindByIcon('near_me');
        stitchBind(navBtn, 'show_info', { message: 'Opening navigation to destination...' });

        // Chat / call customer
        const chatBtn = stitchFindByIcon('chat') || stitchFindByIcon('message') || stitchFindByIcon('chat_bubble');
        stitchBind(chatBtn, 'show_coming_soon');

        const callBtn = stitchFindByIcon('call') || stitchFindByIcon('phone');
        stitchBind(callBtn, 'show_coming_soon');

        // SOS button (if present on active job screen)
        const sosBtn = stitchFindByText('button', ['sos', 'emergency', 'urgence']);
        stitchBind(sosBtn, 'open_driver_sos');

        // Slide to Complete
        const slideBtn = stitchFindByText('button,div', ['slide to complete', 'slide', 'complete', 'terminer', 'glisser']);
        stitchBind(slideBtn, 'driver_complete_delivery');

        // Bottom nav: Delivery, Earnings, Ratings, Profile
        stitchBindBottomNav({
          'delivery|livraison': 'noop',
          'earning|revenu': 'open_driver_earnings',
          'rating|valuation|note': 'open_driver_rating',
          'profile|profil|compte': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectDriverDocsBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_driver_dashboard');

        const allBtns = Array.from(document.querySelectorAll('button'));
        allBtns.forEach(btn => {
          if (btn.closest('nav')) return;
          const text = (btn.textContent || '').toLowerCase().trim();
          if (text === 'edit') {
            stitchBind(btn, 'show_info', { message: 'Document editor opening...' });
          } else if (text === 'view') {
            stitchBind(btn, 'show_info', { message: 'Viewing document...' });
          } else if (text === 'upload') {
            stitchBind(btn, 'show_coming_soon');
          } else if (text.includes('submit')) {
            stitchBind(btn, 'driver_submit_docs');
          } else if (text.includes('continue') || text.includes('next') || text.includes('skip')) {
            stitchBind(btn, 'open_driver_training');
          }
        });
      })();
    ''');
  }

  Future<void> _injectMotorcycleSelectBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_driver_dashboard');

        const confirmBtn = stitchFindByText('button', ['confirm selection', 'confirmer', 'select', 'choisir']);
        stitchBind(confirmBtn, 'driver_confirm_motorcycle');
      })();
    ''');
  }

  Future<void> _injectDriverRatingBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const menuBtn = stitchFindByIcon('menu');
        stitchBind(menuBtn, 'show_info', { message: 'Menu: Dashboard, Earnings, Settings.' });

        const bellBtn = stitchFindByIcon('notifications') || stitchFindByIcon('notifications_none');
        stitchBind(bellBtn, 'show_info', { message: 'No new notifications.' });

        // Submit feedback
        const submitBtn = stitchFindByText('button', ['envoyer', 'submit', 'send']);
        stitchBind(submitBtn, 'driver_submit_rating');

        // Skip
        const skipBtn = stitchFindByText('button', ['passer', 'skip']);
        stitchBind(skipBtn, 'open_driver_dashboard');

        // Bottom nav: Accueil, Activité, Paiement, Compte
        stitchBindBottomNav({
          'accueil|home': 'open_driver_dashboard',
          'activit|activity': 'open_active_job',
          'paiement|payment|earning': 'open_driver_earnings',
          'compte|account|profil': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectDriverTrainingBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_driver_dashboard');

        const infoBtn = stitchFindByIcon('info') || stitchFindByIcon('info_outline');
        stitchBind(infoBtn, 'show_info', { message: 'Complete training modules to unlock premium deliveries and earn badges.' });

        const quizBtn = stitchFindByText('button', ['quiz', 'commencer', 'start']);
        stitchBind(quizBtn, 'show_info', { message: 'Safety quiz starting... Answer 10 questions to earn your safety badge!' });

        const viewAll = stitchFindByText('a,button', ['voir tout', 'view all']);
        stitchBind(viewAll, 'show_info', { message: 'All training modules will be available soon.' });

        const guideLink = stitchFindByText('a,button,div', ['guide pdf', 'guide']);
        stitchBind(guideLink, 'show_coming_soon');

        const supportLink = stitchFindByText('a,button,div', ['support chauffeur', 'driver support', 'support']);
        stitchBind(supportLink, 'show_coming_soon');

        // Clickable video cards
        const videoCards = document.querySelectorAll('[class*="cursor-pointer"]');
        videoCards.forEach(card => {
          if (!card.closest('nav')) {
            stitchBind(card, 'show_info', { message: 'Video lesson loading...' });
          }
        });

        // Bottom nav: Accueil, Revenus, Formation, Profil
        stitchBindBottomNav({
          'accueil|home': 'open_driver_dashboard',
          'revenu|earning': 'open_driver_earnings',
          'formation|training': 'noop',
          'profil|profile': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectDriverSosBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'go_back');

        const sosBtn = stitchFindByText('button', ['sos']);
        stitchBind(sosBtn, 'driver_sos_activated');

        // Map controls — UI-only
        const addBtn = stitchFindByIcon('add');
        const removeBtn = stitchFindByIcon('remove');
        const centerBtn = stitchFindByIcon('near_me') || stitchFindByIcon('my_location');
        if (addBtn) stitchBind(addBtn, 'noop');
        if (removeBtn) stitchBind(removeBtn, 'noop');
        if (centerBtn) stitchBind(centerBtn, 'noop');

        const callAdminBtn = stitchFindByText('button', ['call admin', 'appeler', 'admin']);
        stitchBind(callAdminBtn, 'show_info', { message: 'Calling admin support...' });

        const reportBtn = stitchFindByText('button', ['report', 'signaler']);
        stitchBind(reportBtn, 'show_info', { message: 'Issue report submitted. Admin will review.' });

        const completeBtn = stitchFindByText('button', ['complete ride', 'terminer', 'complete']);
        stitchBind(completeBtn, 'driver_complete_delivery');

        // Bottom nav: Home, Earnings, Ratings, Profile
        stitchBindBottomNav({
          'home|accueil': 'open_driver_dashboard',
          'earning|revenu': 'open_driver_earnings',
          'rating|valuation|note': 'open_driver_rating',
          'profile|profil': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectDriverEarningsBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_driver_dashboard');

        const helpBtn = stitchFindByIcon('help') || stitchFindByIcon('help_outline');
        stitchBind(helpBtn, 'show_help');

        const payoutBtn = stitchFindByText('button', ['payout', 'request', 'demander']);
        stitchBind(payoutBtn, 'show_info', { message: 'Payout request submitted! Processing in 24-48 hours.' });

        const viewAll = stitchFindByText('a,button', ['view all', 'voir tout']);
        stitchBind(viewAll, 'show_info', { message: 'Full transaction history will be available soon.' });

        // Bottom nav: Home, Earnings, Scanner, Activity, Profile
        stitchBindBottomNav({
          'home|accueil': 'open_driver_dashboard',
          'earning|revenu': 'noop',
          'scanner|scan': 'show_coming_soon',
          'activity|activit': 'open_active_job',
          'profile|profil': 'open_driver_profile',
        });
      })();
    ''');
  }

  Future<void> _injectDriverProfileBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const editBtn = stitchFindByIcon('edit') || stitchFindByIcon('create');
        stitchBind(editBtn, 'show_info', { message: 'Profile editing coming soon.' });

        const cameraBtn = stitchFindByIcon('camera_alt') || stitchFindByIcon('photo_camera');
        stitchBind(cameraBtn, 'show_coming_soon');

        const allClickables = document.querySelectorAll('[class*="cursor-pointer"]');
        allClickables.forEach(row => {
          if (row.closest('nav')) return;
          const text = (row.textContent || '').toLowerCase();
          if (text.includes('language') || text.includes('langue')) {
            stitchBind(row, 'show_info', { message: 'Language settings: Change from app settings.' });
          } else if (text.includes('help') || text.includes('aide') || text.includes('support')) {
            stitchBind(row, 'show_help');
          } else if (text.includes('about') || text.includes('propos')) {
            stitchBind(row, 'show_info', { message: 'Nassib v1.0.2 — Motorcycle delivery, Tunisia.' });
          } else if (text.includes('log out') || text.includes('connexion') || text.includes('logout')) {
            stitchBind(row, 'logout');
          } else if (text.includes('motorcycle') || text.includes('vehicle') || text.includes('moto')) {
            stitchBind(row, 'open_motorcycle_select');
          } else if (text.includes('training') || text.includes('formation')) {
            stitchBind(row, 'open_driver_training');
          } else if (text.includes('document') || text.includes('verification')) {
            stitchBind(row, 'open_driver_docs');
          } else if (text.includes('home') || text.includes('maison') || text.includes('work') || text.includes('travail')) {
            stitchBind(row, 'show_info', { message: 'Saved places can be updated in delivery settings.' });
          }
        });

        // Bottom nav: Home, Trips, Wallet, Account
        stitchBindBottomNav({
          'home|accueil': 'open_driver_dashboard',
          'trip|trajet': 'open_active_job',
          'wallet|portefeuille': 'open_driver_earnings',
          'account|compte': 'noop',
        });
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADMIN SCREENS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectAdminConsoleBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const menuBtn = stitchFindByIcon('menu');
        stitchBind(menuBtn, 'show_info', { message: 'Admin Menu: Console, Catalog, Analytics, Settings.' });

        const bellBtn = stitchFindByIcon('notifications') || stitchFindByIcon('notifications_none');
        stitchBind(bellBtn, 'show_info', { message: '3 pending driver verifications, 1 fraud alert.' });

        // Catalog shortcut
        const chevrons = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'chevron_right';
        });
        if (chevrons.length > 0) stitchBind(chevrons[0], 'open_admin_catalog');

        // Analytics — link from stats cards or second chevron
        const statsCards = document.querySelectorAll('[class*="cursor-pointer"]');
        statsCards.forEach(card => {
          if (card.closest('nav')) return;
          const text = (card.textContent || '').toLowerCase();
          if (text.includes('revenue') || text.includes('analytics') || text.includes('sales') || text.includes('fraud')) {
            stitchBind(card, 'open_admin_analytics');
          }
        });
        if (chevrons.length > 1) stitchBind(chevrons[1], 'open_admin_analytics');

        const viewAll = stitchFindByText('button,a', ['view all', 'voir tout']);
        stitchBind(viewAll, 'show_info', { message: 'Showing all pending driver verifications.' });

        // Details buttons
        const detailsBtns = Array.from(document.querySelectorAll('button')).filter(
          el => (el.textContent || '').toLowerCase().trim() === 'details'
        );
        detailsBtns.forEach(btn => {
          stitchBind(btn, 'show_info', { message: 'Driver details: National ID, License, Insurance, Vehicle — all documents on file.' });
        });

        // Review buttons
        const reviewBtns = Array.from(document.querySelectorAll('button')).filter(
          el => (el.textContent || '').toLowerCase().trim() === 'review'
        );
        reviewBtns.forEach(btn => {
          stitchBind(btn, 'admin_verify_driver');
        });

        const continueBtn = stitchFindByText('button', ['continue', 'continuer']);
        stitchBind(continueBtn, 'show_info', { message: 'Continuing verification review for this driver.' });
      })();
    ''');
  }

  Future<void> _injectAdminCatalogBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_admin_console');

        const moreBtn = stitchFindByIcon('more_vert');
        stitchBind(moreBtn, 'show_info', { message: 'Catalog options: Import CSV, Export, Bulk edit.' });

        // Edit buttons on products
        const editBtns = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'edit';
        });
        editBtns.forEach(btn => {
          stitchBind(btn, 'show_info', { message: 'Product editor: Update name, price, stock, category, and images.' });
        });

        // FAB — add new product
        const allBtns = Array.from(document.querySelectorAll('button'));
        const fab = allBtns.find(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'add' && !el.closest('nav');
        });
        stitchBind(fab, 'show_info', { message: 'New product form: Name, SKU, Price, Category, Image upload.' });

        // Bottom nav: Dashboard, Catalog, Orders, Settings
        stitchBindBottomNav({
          'dashboard|tableau': 'open_admin_console',
          'catalog|catalogue': 'noop',
          'order|commande': 'show_info',
          'setting|param': 'show_info',
        });
      })();
    ''');
  }

  Future<void> _injectAdminAnalyticsBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'open_admin_console');

        const bellBtn = stitchFindByIcon('notifications') || stitchFindByIcon('notifications_none');
        stitchBind(bellBtn, 'show_info', { message: '2 fraud alerts require attention.' });

        const viewReportBtn = stitchFindByText('button,a', ['view report', 'voir rapport']);
        stitchBind(viewReportBtn, 'show_info', { message: 'Sales report: +12% this week. Top sellers: Harissa, Dates, Olive Oil.' });

        // Alert chevrons
        const chevrons = Array.from(document.querySelectorAll('button')).filter(el => {
          const icon = el.querySelector('.material-symbols-outlined, .material-symbols-rounded');
          return icon && (icon.textContent || '').trim() === 'chevron_right';
        });
        chevrons.forEach(btn => {
          stitchBind(btn, 'show_info', { message: 'Alert details: Unusual order pattern detected. Review recommended.' });
        });

        const viewAll = stitchFindByText('a,button', ['view all', 'voir tout']);
        stitchBind(viewAll, 'show_info', { message: 'All active drivers list with real-time locations.' });

        // Bottom nav: Dashboard, Drivers, Orders, Settings
        stitchBindBottomNav({
          'dashboard|tableau': 'open_admin_console',
          'driver|chauffeur': 'show_info',
          'order|commande': 'show_info',
          'setting|param': 'show_info',
        });
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // BIOMETRIC / OTP
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _injectBiometricOtpBindings() async {
    await _controller.runJavaScript(r'''
      (() => {
        const backBtn = stitchFindByIcon('arrow_back') || stitchFindByIcon('chevron_left');
        stitchBind(backBtn, 'go_back');

        const continueBtn = stitchFindByText('button', ['continuer', 'continue', 'verify']);
        stitchBind(continueBtn, 'biometric_verify_otp');

        const biometricBtn = stitchFindByText('button', ['biom', 'fingerprint', 'empreinte']);
        stitchBind(biometricBtn, 'show_info', { message: 'Biometric authentication — Place your finger on the sensor.' });

        const resendBtn = stitchFindByText('button,a', ['renvoyer', 'resend']);
        stitchBind(resendBtn, 'show_info', { message: 'New SMS code sent! Check your phone.' });
      })();
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════
  // BRIDGE MESSAGE HANDLER
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _handleBridgeMessage(String rawMessage) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawMessage);
    } catch (_) {
      decoded = {'action': rawMessage};
    }

    final message = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'action': decoded.toString()};

    final action = message['action']?.toString();
    final payload = (message['payload'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    switch (action) {
      // ── Navigation: Auth ──
      case 'open_register':
        _navigateTo('/register1');
      case 'open_login':
        _navigateTo('/login1');

      // ── Navigation: Splash ──
      case 'open_splash2':
        _navigateTo('/splash2');
      case 'open_splash3':
        _navigateTo('/splash3');
      case 'open_splash4':
        _navigateTo('/splash4');

      // ── Navigation: Customer ──
      case 'open_product':
        _navigateTo('/customer/product');
      case 'select_and_open_product':
        final productId = payload['productId']?.toString();
        if (productId != null) {
          ref.read(productCatalogProvider.notifier).selectProduct(productId);
        }
        _navigateTo('/customer/product');
      case 'toggle_favorite':
        final favId = payload['productId']?.toString();
        if (favId != null) {
          ref.read(productCatalogProvider.notifier).toggleFavorite(favId);
          _showMessage('❤️ Favorite updated!');
        }
      case 'quick_add_to_cart':
        final addId = payload['productId']?.toString();
        if (addId != null) {
          ref.read(productCatalogProvider.notifier).addToCart(addId);
          _showMessage('✅ Added to cart!');
        }
      case 'update_cart_qty':
        final qtyPid = payload['productId']?.toString();
        final direction = payload['direction']?.toString();
        if (qtyPid != null && direction != null) {
          final catalog = ref.read(productCatalogProvider);
          final currentItem =
              catalog.cart.where((ci) => ci.product.id == qtyPid).firstOrNull;
          if (currentItem != null) {
            final newQty = direction == 'plus'
                ? currentItem.quantity + 1
                : currentItem.quantity - 1;
            ref
                .read(productCatalogProvider.notifier)
                .updateCartQuantity(qtyPid, newQty);
          }
          // Refresh the cart screen with updated data
          await _injectCartData();
        }
      case 'open_filters':
        _navigateTo('/customer/filters');
      case 'open_cart':
        _navigateTo('/customer/cart');
      case 'open_checkout_promos':
        _navigateTo('/customer/checkout-promos');
      case 'open_order_confirm':
        _navigateTo('/customer/order-confirm');
      case 'open_live_tracking':
        _navigateTo('/customer/live-tracking');
      case 'open_notifications':
        _navigateTo('/customer/notifications');
      case 'open_customer_home':
        _navigateTo('/customer/home');
      case 'open_ai_order':
        _navigateTo('/customer/ai-order');
      case 'open_ai_voice':
        _navigateTo('/customer/ai-voice');

      // ── Navigation: Driver ──
      case 'open_driver_dashboard':
        _navigateTo('/driver/dashboard');
      case 'open_active_job':
        _navigateTo('/driver/active-job');
      case 'open_driver_docs':
        _navigateTo('/driver/docs');
      case 'open_motorcycle_select':
        _navigateTo('/driver/motorcycle-select');
      case 'open_driver_rating':
        _navigateTo('/driver/rating');
      case 'open_driver_training':
        _navigateTo('/driver/training');
      case 'open_driver_sos':
        _navigateTo('/driver/sos');
      case 'open_driver_earnings':
        _navigateTo('/driver/earnings');
      case 'open_driver_profile':
        _navigateTo('/driver/profile');

      // ── Navigation: Admin ──
      case 'open_admin_console':
        _navigateTo('/admin/console');
      case 'open_admin_catalog':
        _navigateTo('/admin/catalog');
      case 'open_admin_analytics':
        _navigateTo('/admin/analytics');

      // ── Navigation: Utility ──
      case 'open_biometric_otp':
        _navigateTo('/biometric-otp');

      // ── Go Back (browser-like) ──
      case 'go_back':
        if (mounted) Navigator.of(context).maybePop();

      // ── Driver Actions (API calls) ──
      case 'driver_toggle_availability':
        await _driverToggleAvailability();
      case 'driver_accept_delivery':
        await _driverAcceptDelivery();
      case 'driver_start_delivery':
        await _driverStartDelivery();
      case 'driver_complete_delivery':
        await _driverCompleteDelivery();
      case 'driver_decline_delivery':
        _showMessage('Delivery declined. Waiting for next request...');
      case 'driver_submit_docs':
        _showMessage(
            '📄 Documents submitted for review. Please wait for admin approval.');
        _navigateTo('/driver/dashboard');
      case 'driver_confirm_motorcycle':
        _showMessage('🏍️ Motorcycle selection confirmed!');
        _navigateTo('/driver/dashboard');
      case 'driver_submit_rating':
        _showMessage('⭐ Thank you for your feedback!');
        _navigateTo('/driver/dashboard');
      case 'driver_sos_activated':
        _showMessage(
            '🚨 SOS ACTIVATED! Emergency services and admin have been notified. Stay safe.');

      // ── Admin Actions ──
      case 'admin_verify_driver':
        _showMessage(
            '✅ Driver verified and approved! They can now accept deliveries.');

      // ── Biometric/OTP ──
      case 'biometric_verify_otp':
        _showMessage('✅ OTP verified successfully!');
        final authState = ref.read(authStateProvider);
        if (authState.isAuthenticated) {
          final destination = _routeForRole(authState.user?.role);
          if (destination != null) _navigateTo(destination);
        }

      // ── Cart Actions ──
      case 'add_to_cart_and_go':
        // Read quantity from the product detail page and add to cart
        final selectedProd = ref.read(productCatalogProvider).selectedProduct;
        if (selectedProd != null) {
          int qty = 1;
          try {
            final qtyResult = await _controller.runJavaScriptReturningResult(
              "document.getElementById('product-qty')?.textContent || '1'",
            );
            qty = int.tryParse(qtyResult.toString().replaceAll('"', '')) ?? 1;
          } catch (_) {}
          ref
              .read(productCatalogProvider.notifier)
              .addToCart(selectedProd.id, quantity: qty);
        }
        _showMessage('✅ Added to cart!');
        _navigateTo('/customer/cart');
      case 'show_added_to_cart':
        _showMessage('✅ Item added to cart!');

      // ── Auth Actions ──
      case 'logout':
        await ref.read(authStateProvider.notifier).logout();
        if (mounted) _navigateTo('/login1');
      case 'login_submit':
        await _submitLogin(payload);
      case 'register_submit':
        await _submitRegistration(payload);

      // ── UI Feedback (no navigation) ──
      case 'show_info':
        _showMessage(payload['message']?.toString() ?? 'Information');
      case 'show_help':
        _showMessage(
            '📞 Help & Support: Call +216 70 000 000 or email support@nassib.tn');
      case 'show_coming_soon':
        _showMessage('🚀 This feature is coming soon!');

      // ── No-op (intentional) ──
      case 'noop':
        break;

      default:
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH HANDLERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _submitLogin(Map<String, dynamic> payload) async {
    if (_isActionLoading) return;

    final mode = (payload['mode'] ?? 'email').toString().trim().toLowerCase();
    var email = (payload['email'] ?? '').toString().trim();
    final phone = (payload['phone'] ?? '').toString().trim();
    final password = (payload['password'] ?? '').toString().trim();

    if (mode == 'phone') {
      email = phone;
    }

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await ref.read(authStateProvider.notifier).login(email, password);
      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        final destination = _routeForRole(authState.user?.role);
        if (destination == null) {
          _showMessage('Your role is not configured yet.');
          return;
        }
        Navigator.of(context)
            .pushNamedAndRemoveUntil(destination, (_) => false);
      } else {
        _showMessage(_cleanError(authState.error, fallback: 'Login failed.'));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _submitRegistration(Map<String, dynamic> payload) async {
    if (_isActionLoading) return;

    final name = (payload['name'] ?? '').toString().trim();
    final email = (payload['email'] ?? '').toString().trim();
    final password = (payload['password'] ?? '').toString().trim();
    final phone = (payload['phone'] ?? '').toString().trim();
    final license = (payload['license'] ?? '').toString().trim();
    final roleValue =
        (payload['role'] ?? 'client').toString().trim().toLowerCase();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please complete name, email, and password.');
      return;
    }

    if (roleValue == 'admin') {
      _showMessage('Admin registration requires manual approval.');
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      if (roleValue == 'driver') {
        if (phone.isEmpty || license.isEmpty) {
          _showMessage('Driver registration needs phone and license number.');
          return;
        }
        await ref.read(authStateProvider.notifier).registerDriver(
              email: email,
              password: password,
              name: name,
              phoneNumber: phone,
              licenseNumber: license,
            );
      } else {
        await ref.read(authStateProvider.notifier).registerCustomer(
              email: email,
              password: password,
              name: name,
            );
      }
      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        final destination =
            _routeForRole(authState.user?.role) ?? '/customer/home';
        Navigator.of(context)
            .pushNamedAndRemoveUntil(destination, (_) => false);
      } else {
        _showMessage(
          _cleanError(authState.error, fallback: 'Registration failed.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  String? _routeForRole(String? role) {
    final normalized = (role ?? '').toUpperCase();
    if (normalized == 'CUSTOMER') return '/customer/home';
    if (normalized == 'DRIVER') return '/driver/dashboard';
    if (normalized == 'ADMIN') return '/admin/console';
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // DRIVER ACTION METHODS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _driverToggleAvailability() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      await ref.read(driverAvailabilityProvider.notifier).toggleAvailability();
      if (!mounted) return;
      final avail = ref.read(driverAvailabilityProvider);
      _showMessage(avail.isAvailable
          ? '🟢 You are now online!'
          : '🔴 You are now offline.');
    } catch (e) {
      _showMessage('Failed to toggle availability.');
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _driverAcceptDelivery() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final service = DeliveryService();
      final available = await service.getAvailableDeliveries();
      if (available.isEmpty) {
        _showMessage('No deliveries available right now.');
        return;
      }
      await service.acceptDelivery(available.first.id);
      if (!mounted) return;
      _showMessage('✅ Delivery accepted! Navigate to pickup location.');
      _navigateTo('/driver/active-job');
    } catch (e) {
      _showMessage('Failed to accept delivery.');
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _driverStartDelivery() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final service = DeliveryService();
      final active = await service.getActiveDriverDeliveries();
      if (active.isEmpty) {
        _showMessage('No active delivery to start.');
        return;
      }
      await service.startDelivery(active.first.id);
      if (!mounted) return;
      _showMessage('🚀 Delivery started! Navigate to drop-off.');
    } catch (e) {
      _showMessage('Failed to start delivery.');
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _driverCompleteDelivery() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final service = DeliveryService();
      final active = await service.getActiveDriverDeliveries();
      if (active.isEmpty) {
        _showMessage('No active delivery to complete.');
        return;
      }
      await service.completeDelivery(active.first.id);
      if (!mounted) return;
      _showMessage('🎉 Delivery completed! Great job.');
      _navigateTo('/driver/rating');
    } catch (e) {
      _showMessage('Failed to complete delivery.');
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════

  void _navigateTo(String routeName) {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _cleanError(String? rawError, {required String fallback}) {
    if (rawError == null || rawError.isEmpty) return fallback;
    return rawError
        .replaceAll('Exception: ', '')
        .replaceAll('ValidationException: ', '')
        .replaceAll('AuthenticationException: ', '')
        .replaceAll('NetworkException: ', '')
        .trim();
  }
}
