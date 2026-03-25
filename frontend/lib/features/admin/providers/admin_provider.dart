import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../../core/utils/storage_service.dart';

// ═══════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════

class PendingDriver {
  final String id;
  final String name;
  final String licenseNumber;
  final String vehicleModel;
  final String submittedAgo;
  final String status; // 'new', 'pending', 'in_review'
  final String? imageUrl;

  const PendingDriver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.vehicleModel,
    required this.submittedAgo,
    required this.status,
    this.imageUrl,
  });
}

class AdminDashboardStats {
  final int dailyOrders;
  final double dailyOrdersTrend; // percentage change
  final int activeDrivers;
  final int pendingVerifications;
  final double totalRevenue;
  final double revenueTrend;
  final int fraudAlerts;
  final double deliveryEfficiency; // percentage

  const AdminDashboardStats({
    this.dailyOrders = 1240,
    this.dailyOrdersTrend = 12.0,
    this.activeDrivers = 356,
    this.pendingVerifications = 12,
    this.totalRevenue = 3450.0,
    this.revenueTrend = 12.0,
    this.fraudAlerts = 5,
    this.deliveryEfficiency = 94.0,
  });
}

class AdminCatalogProduct {
  final String id;
  final String name;
  final String unit;
  final String category;
  final int stock;
  final String stockStatus; // 'in_stock', 'low_stock', 'out_of_stock'
  final double price;
  final String? imageUrl;

  const AdminCatalogProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.stock,
    required this.stockStatus,
    required this.price,
    this.imageUrl,
  });
}

class AdminState {
  final AdminDashboardStats stats;
  final List<PendingDriver> pendingDrivers;
  final List<AdminCatalogProduct> catalogProducts;
  final String? selectedDriverId;
  final bool isLoading;

  const AdminState({
    this.stats = const AdminDashboardStats(),
    this.pendingDrivers = const [],
    this.catalogProducts = const [],
    this.selectedDriverId,
    this.isLoading = false,
  });

  AdminState copyWith({
    AdminDashboardStats? stats,
    List<PendingDriver>? pendingDrivers,
    List<AdminCatalogProduct>? catalogProducts,
    String? selectedDriverId,
    bool? isLoading,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      pendingDrivers: pendingDrivers ?? this.pendingDrivers,
      catalogProducts: catalogProducts ?? this.catalogProducts,
      selectedDriverId: selectedDriverId ?? this.selectedDriverId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════

class AdminStateNotifier extends StateNotifier<AdminState> {
  AdminStateNotifier() : super(const AdminState()) {
    _loadInitialData();
  }

  Future<Map<String, String>> _authHeaders({bool jsonContent = false}) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Not authenticated');

    return {
      if (jsonContent) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeToMap(String body) {
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected response format');
  }

  Future<Map<String, String>> _resolveMerchantForProduct() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/catalog/merchants'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load merchants: ${response.body}');
    }
    final decoded = json.decode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      throw Exception(
        'No merchants in database. From backend/: run npm run seed:catalog',
      );
    }
    final m = decoded[0] as Map<String, dynamic>;
    final id = m['id'] as String? ?? m['_id']?.toString();
    final region = (m['region'] as String?) ?? 'TND';
    if (id == null || id.isEmpty) {
      throw Exception('Invalid merchant list from API');
    }
    return {'id': id, 'region': region};
  }

  Future<List<String>> _categoryIdsForLabel(String categoryLabel) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/catalog/categories'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) return [];
    final decoded = json.decode(response.body);
    if (decoded is! List<dynamic>) return [];
    final want = categoryLabel.trim().toLowerCase();
    if (want.isEmpty) return [];
    final exact = <String>[];
    final fuzzy = <String>[];
    for (final raw in decoded) {
      if (raw is! Map<String, dynamic>) continue;
      final name = (raw['name'] as String?)?.toLowerCase() ?? '';
      final slug = (raw['slug'] as String?)?.toLowerCase() ?? '';
      final id = raw['_id']?.toString() ?? raw['id'] as String?;
      if (id == null) continue;
      if (name == want || slug == want) {
        exact.add(id);
      } else if (name.contains(want) || slug.contains(want)) {
        fuzzy.add(id);
      }
    }
    return exact.isNotEmpty ? exact : fuzzy;
  }

  void _loadInitialData() {
    state = state.copyWith(
      stats: const AdminDashboardStats(),
      pendingDrivers: _samplePendingDrivers,
      catalogProducts: _sampleCatalogProducts,
    );
  }

  // ── Dashboard ──

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/dashboard'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = _decodeToMap(response.body);

        // Pull analytics in parallel for richer dashboard stats.
        final analytics = await Future.wait([
          fetchRevenueAnalytics(period: 'daily'),
          fetchFraudAnalytics(),
        ]);

        final revenue = analytics[0];
        final fraud = analytics[1];

        final completedDeliveries =
            (revenue['summary']?['completedDeliveries'] as num?)?.toInt() ?? 0;
        final totalRevenue = (revenue['summary']?['totalRevenue'] as num?)?.toDouble() ?? 0.0;
        final fraudAlerts = (fraud['summary']?['cancelledDeliveries'] as num?)?.toInt() ?? 0;

        state = state.copyWith(
          stats: AdminDashboardStats(
            dailyOrders: completedDeliveries,
            activeDrivers: data['users']?['drivers']?['verified'] ?? 0,
            pendingVerifications: data['users']?['drivers']?['pending'] ?? 0,
            totalRevenue: totalRevenue,
            fraudAlerts: fraudAlerts,
          ),
          isLoading: false,
        );
      } else {
        throw Exception('Failed to load dashboard: ${response.body}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // ── Driver Verification ──

  void selectDriver(String driverId) {
    state = state.copyWith(selectedDriverId: driverId);
  }

  Future<void> verifyDriver(String driverId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/drivers/$driverId/verify'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final updated = state.pendingDrivers
            .where((d) => d.id != driverId)
            .toList();
        state = state.copyWith(
          pendingDrivers: updated,
          stats: AdminDashboardStats(
            dailyOrders: state.stats.dailyOrders,
            dailyOrdersTrend: state.stats.dailyOrdersTrend,
            activeDrivers: state.stats.activeDrivers + 1,
            pendingVerifications: state.stats.pendingVerifications - 1,
            totalRevenue: state.stats.totalRevenue,
            revenueTrend: state.stats.revenueTrend,
            fraudAlerts: state.stats.fraudAlerts,
            deliveryEfficiency: state.stats.deliveryEfficiency,
          ),
        );
      } else {
        throw Exception('Failed to verify driver: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectDriver(String driverId, {String reason = 'Admin decision'}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/drivers/$driverId/reject'),
        headers: await _authHeaders(jsonContent: true),
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final updated = state.pendingDrivers
            .where((d) => d.id != driverId)
            .toList();
        state = state.copyWith(
          pendingDrivers: updated,
          stats: AdminDashboardStats(
            dailyOrders: state.stats.dailyOrders,
            dailyOrdersTrend: state.stats.dailyOrdersTrend,
            activeDrivers: state.stats.activeDrivers,
            pendingVerifications: state.stats.pendingVerifications - 1,
            totalRevenue: state.stats.totalRevenue,
            revenueTrend: state.stats.revenueTrend,
            fraudAlerts: state.stats.fraudAlerts,
            deliveryEfficiency: state.stats.deliveryEfficiency,
          ),
        );
      } else {
        throw Exception('Failed to reject driver: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Catalog Management ──

  Future<void> addProduct(AdminCatalogProduct product) async {
    try {
      final merchant = await _resolveMerchantForProduct();
      final categoryIds = await _categoryIdsForLabel(product.category);
      if (categoryIds.isEmpty) {
        throw Exception(
          'No category matched "${product.category}". '
          'Use a label that matches a seeded category name or slug (run npm run seed:catalog).',
        );
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/catalog/products'),
        headers: await _authHeaders(jsonContent: true),
        body: json.encode({
          'name': product.name,
          'description': 'Product description',
          'price': product.price,
          'stock': product.stock,
          'merchantId': merchant['id'],
          'categoryIds': categoryIds,
          'tags': [product.category.toLowerCase()],
          'images': product.imageUrl != null ? [product.imageUrl] : [],
          'relatedProductIds': [],
          'regions': [merchant['region'] ?? 'TND'],
          'isActive': product.stockStatus != 'out_of_stock',
        }),
      );

      if (response.statusCode == 201) {
        final updated = [...state.catalogProducts, product];
        state = state.copyWith(catalogProducts: updated);
      } else {
        throw Exception('Failed to create product: ${response.body}');
      }
    } catch (e) {
      // Log error (use proper logger in production)
      rethrow;
    }
  }

  Future<void> updateProduct(AdminCatalogProduct product) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/catalog/products/${product.id}'),
        headers: await _authHeaders(jsonContent: true),
        body: json.encode({
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'tags': [product.category.toLowerCase()],
          'images': product.imageUrl != null ? [product.imageUrl] : [],
          'isActive': product.stockStatus != 'out_of_stock',
        }),
      );

      if (response.statusCode == 200) {
        final updated = state.catalogProducts.map((p) {
          return p.id == product.id ? product : p;
        }).toList();
        state = state.copyWith(catalogProducts: updated);
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      // Log error (use proper logger in production)
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/catalog/products/$productId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final updated = state.catalogProducts
            .where((p) => p.id != productId)
            .toList();
        state = state.copyWith(catalogProducts: updated);
      } else {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      // Log error (use proper logger in production)
      rethrow;
    }
  }

  // ── Analytics & Reports ──

  Future<Map<String, dynamic>> fetchFraudAnalytics() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/admin/analytics/fraud'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load fraud analytics: ${response.body}');
    }

    return _decodeToMap(response.body);
  }

  Future<Map<String, dynamic>> fetchRevenueAnalytics({String period = 'daily'}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/admin/analytics/revenue')
        .replace(queryParameters: {'period': period});
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to load revenue analytics: ${response.body}');
    }

    return _decodeToMap(response.body);
  }

  Future<Map<String, dynamic>> fetchDeliveriesReport({String period = 'weekly'}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/admin/reports/deliveries')
        .replace(queryParameters: {'period': period});
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to load deliveries report: ${response.body}');
    }

    return _decodeToMap(response.body);
  }

  Future<Map<String, dynamic>> fetchDriversReport({String period = 'monthly'}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/admin/reports/drivers')
        .replace(queryParameters: {'period': period});
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to load drivers report: ${response.body}');
    }

    return _decodeToMap(response.body);
  }

  Future<void> refreshAnalyticsOverview() async {
    final results = await Future.wait([
      fetchRevenueAnalytics(period: 'daily'),
      fetchFraudAnalytics(),
    ]);

    final revenue = results[0];
    final fraud = results[1];

    final totalRevenue = (revenue['summary']?['totalRevenue'] as num?)?.toDouble() ?? 0;
    final completedDeliveries =
        (revenue['summary']?['completedDeliveries'] as num?)?.toInt() ?? state.stats.dailyOrders;
    final fraudAlerts =
        (fraud['summary']?['cancelledDeliveries'] as num?)?.toInt() ?? state.stats.fraudAlerts;
    final riskScore = (fraud['riskScore'] as num?)?.toDouble() ?? 0;
    final efficiency = (100 - riskScore).clamp(0, 100).toDouble();

    state = state.copyWith(
      stats: AdminDashboardStats(
        dailyOrders: completedDeliveries,
        dailyOrdersTrend: state.stats.dailyOrdersTrend,
        activeDrivers: state.stats.activeDrivers,
        pendingVerifications: state.stats.pendingVerifications,
        totalRevenue: totalRevenue,
        revenueTrend: state.stats.revenueTrend,
        fraudAlerts: fraudAlerts,
        deliveryEfficiency: efficiency,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SAMPLE DATA
  // ═══════════════════════════════════════════════════════════════

  static const _samplePendingDrivers = <PendingDriver>[
    PendingDriver(
      id: 'drv_001',
      name: 'Ahmed Ben Ali',
      licenseNumber: '19283746',
      vehicleModel: 'Yamaha YBR',
      submittedAgo: '2h ago',
      status: 'new',
    ),
    PendingDriver(
      id: 'drv_002',
      name: 'Fatma Jaziri',
      licenseNumber: '82736451',
      vehicleModel: 'Sym Symphony',
      submittedAgo: '5h ago',
      status: 'pending',
    ),
    PendingDriver(
      id: 'drv_003',
      name: 'Khaled M.',
      licenseNumber: '99887766',
      vehicleModel: 'Forza 300',
      submittedAgo: '8h ago',
      status: 'in_review',
    ),
  ];

  static const _sampleCatalogProducts = <AdminCatalogProduct>[
    AdminCatalogProduct(
      id: 'cat_001',
      name: 'Harissa du Cap Bon',
      unit: '70g tube',
      category: 'Spices',
      stock: 145,
      stockStatus: 'in_stock',
      price: 2.800,
    ),
    AdminCatalogProduct(
      id: 'cat_002',
      name: 'Zitouna Virgin Oil',
      unit: '1L Bottle',
      category: 'Grocery',
      stock: 12,
      stockStatus: 'low_stock',
      price: 18.500,
    ),
    AdminCatalogProduct(
      id: 'cat_003',
      name: 'Fresh Mangoes',
      unit: '1kg',
      category: 'Fresh Produce',
      stock: 85,
      stockStatus: 'in_stock',
      price: 8.900,
    ),
    AdminCatalogProduct(
      id: 'cat_004',
      name: 'Deglet Nour Dates',
      unit: '500g Box',
      category: 'Grocery',
      stock: 0,
      stockStatus: 'out_of_stock',
      price: 12.500,
    ),
    AdminCatalogProduct(
      id: 'cat_005',
      name: 'Local Tomatoes',
      unit: '1kg',
      category: 'Fresh Produce',
      stock: 200,
      stockStatus: 'in_stock',
      price: 3.200,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════

final adminStateProvider =
    StateNotifierProvider<AdminStateNotifier, AdminState>(
  (ref) => AdminStateNotifier(),
);
