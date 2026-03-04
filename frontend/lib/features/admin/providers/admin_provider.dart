import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // TODO: Call backend GET /admin/dashboard
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      stats: const AdminDashboardStats(),
      isLoading: false,
    );
  }

  // ── Driver Verification ──

  void selectDriver(String driverId) {
    state = state.copyWith(selectedDriverId: driverId);
  }

  Future<void> verifyDriver(String driverId) async {
    // TODO: Call backend POST /admin/drivers/{id}/verify
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
  }

  Future<void> rejectDriver(String driverId) async {
    // TODO: Call backend POST /admin/drivers/{id}/reject
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
  }

  // ── Catalog Management ──

  Future<void> addProduct(AdminCatalogProduct product) async {
    // TODO: Call backend POST /catalog/products
    final updated = [...state.catalogProducts, product];
    state = state.copyWith(catalogProducts: updated);
  }

  Future<void> updateProduct(AdminCatalogProduct product) async {
    // TODO: Call backend PATCH /catalog/products/{id}
    final updated = state.catalogProducts.map((p) {
      return p.id == product.id ? product : p;
    }).toList();
    state = state.copyWith(catalogProducts: updated);
  }

  Future<void> deleteProduct(String productId) async {
    // TODO: Call backend DELETE /catalog/products/{id}
    final updated = state.catalogProducts
        .where((p) => p.id != productId)
        .toList();
    state = state.copyWith(catalogProducts: updated);
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
