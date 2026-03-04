import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported app languages
enum AppLanguage {
  english('English', 'en', false),
  french('Français', 'fr', false),
  arabic('العربية', 'ar', true),
  derja('تونسي', 'tn', true); // Tunisian Derja — distinct code 'tn'

  const AppLanguage(this.displayName, this.code, this.isRtl);
  final String displayName;
  final String code;
  final bool isRtl;
}

/// Holds the currently selected language
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);

  void setLanguage(AppLanguage lang) {
    state = lang;
  }

  void setFromString(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized.contains('derja') ||
        normalized.contains('tounsi') ||
        normalized.contains('تونسي')) {
      state = AppLanguage.derja;
    } else if (normalized.contains('arab') || normalized.contains('عرب')) {
      state = AppLanguage.arabic;
    } else if (normalized.contains('fran') || normalized.contains('français')) {
      state = AppLanguage.french;
    } else {
      state = AppLanguage.english;
    }
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// Complete translation map for UI elements across all screens.
/// Keys are English originals, values map language codes to translations.
/// Codes: 'fr' = French, 'ar' = Arabic, 'tn' = Tunisian Derja
const Map<String, Map<String, String>> uiTranslations = {
  // ─── Navigation labels ──────────────────────────────────────
  'Home': {'fr': 'Accueil', 'ar': 'الرئيسية', 'tn': 'الدار'},
  'Orders': {'fr': 'Commandes', 'ar': 'الطلبات', 'tn': 'الطلبات'},
  'Profile': {'fr': 'Profil', 'ar': 'الحساب', 'tn': 'الحساب'},
  'Dashboard': {'fr': 'Tableau de bord', 'ar': 'لوحة القيادة', 'tn': 'لوحة التحكم'},
  'Wallet': {'fr': 'Portefeuille', 'ar': 'المحفظة', 'tn': 'الفلوس'},
  'Earnings': {'fr': 'Revenus', 'ar': 'الأرباح', 'tn': 'المدخول'},
  'Ratings': {'fr': 'Évaluations', 'ar': 'التقييمات', 'tn': 'التقييمات'},
  'Activity': {'fr': 'Activité', 'ar': 'النشاط', 'tn': 'النشاط'},
  'Account': {'fr': 'Compte', 'ar': 'الحساب', 'tn': 'الحساب'},
  'Market': {'fr': 'Marché', 'ar': 'السوق', 'tn': 'السوق'},
  'Smart Order': {'fr': 'Commande IA', 'ar': 'طلب ذكي', 'tn': 'طلب ذكي'},
  'Delivery': {'fr': 'Livraison', 'ar': 'التوصيل', 'tn': 'التوصيل'},
  'Training': {'fr': 'Formation', 'ar': 'التدريب', 'tn': 'التدريب'},
  'Docs': {'fr': 'Documents', 'ar': 'الوثائق', 'tn': 'الوثائق'},
  'Settings': {'fr': 'Paramètres', 'ar': 'الإعدادات', 'tn': 'الإعدادات'},
  'Catalog': {'fr': 'Catalogue', 'ar': 'الكتالوج', 'tn': 'الكتالوج'},
  'Drivers': {'fr': 'Chauffeurs', 'ar': 'السائقين', 'tn': 'الشوفيرية'},
  'Cart': {'fr': 'Panier', 'ar': 'السلة', 'tn': 'السلّة'},
  'Search': {'fr': 'Recherche', 'ar': 'البحث', 'tn': 'البحث'},

  // ─── Auth & Login ───────────────────────────────────────────
  'Merhba bik!': {'fr': 'Bienvenue !', 'ar': 'مرحبا بك!', 'tn': 'مرحبا بيك!'},
  'Log in to start your ride or delivery': {
    'fr': 'Connectez-vous pour commencer',
    'ar': 'سجّل الدخول لبدء رحلتك أو التوصيل',
    'tn': 'ادخل باش تبدا الرحلة ولّا التوصيل',
  },
  'Phone Number': {
    'fr': 'Numéro de téléphone',
    'ar': 'رقم الهاتف',
    'tn': 'نمرو التليفون',
  },
  'Email': {'fr': 'E-mail', 'ar': 'البريد الإلكتروني', 'tn': 'الإيمايل'},
  'Password': {'fr': 'Mot de passe', 'ar': 'كلمة المرور', 'tn': 'كلمة السر'},
  'Continue': {'fr': 'Continuer', 'ar': 'متابعة', 'tn': 'كمّل'},
  'Register now': {'fr': "S'inscrire", 'ar': 'سجّل الآن', 'tn': 'سجّل توّا'},
  "Don't have an account?": {
    'fr': "Vous n'avez pas de compte ?",
    'ar': 'ليس لديك حساب؟',
    'tn': 'ماعندكش حساب؟',
  },
  'Choose role during registration.': {
    'fr': "Choisissez votre rôle lors de l'inscription.",
    'ar': 'اختر دورك أثناء التسجيل.',
    'tn': 'اختار الرول متاعك وقت التسجيل.',
  },
  'Use email or phone number with your password.': {
    'fr': 'Utilisez votre email ou téléphone avec votre mot de passe.',
    'ar': 'استخدم بريدك أو رقم هاتفك مع كلمة المرور.',
    'tn': 'استعمل الإيمايل ولّا النمرو مع كلمة السر.',
  },
  'Create your account': {
    'fr': 'Créer votre compte',
    'ar': 'أنشئ حسابك',
    'tn': 'اخلق الحساب متاعك',
  },
  'Full Name': {'fr': 'Nom complet', 'ar': 'الاسم الكامل', 'tn': 'الاسم الكامل'},
  'Already have an account?': {
    'fr': 'Vous avez déjà un compte ?',
    'ar': 'لديك حساب؟',
    'tn': 'عندك حساب؟',
  },
  'Sign in': {'fr': 'Se connecter', 'ar': 'تسجيل الدخول', 'tn': 'ادخل'},
  'I am a Customer': {'fr': 'Je suis un client', 'ar': 'أنا زبون', 'tn': 'أنا كليون'},
  'I am a Driver': {
    'fr': 'Je suis un chauffeur',
    'ar': 'أنا سائق',
    'tn': 'أنا شوفير',
  },

  // ─── Customer Home ──────────────────────────────────────────
  'Welcome': {'fr': 'Bienvenue', 'ar': 'مرحبا', 'tn': 'مرحبا'},
  'Categories': {'fr': 'Catégories', 'ar': 'الأقسام', 'tn': 'الأقسام'},
  'View All': {'fr': 'Voir tout', 'ar': 'عرض الكل', 'tn': 'شوف الكل'},
  'Grocery': {'fr': 'Épicerie', 'ar': 'بقالة', 'tn': 'عطّار'},
  'Vegetables': {'fr': 'Légumes', 'ar': 'خضروات', 'tn': 'خضرة'},
  'Spices': {'fr': 'Épices', 'ar': 'بهارات', 'tn': 'بهارات'},
  'Beverages': {'fr': 'Boissons', 'ar': 'مشروبات', 'tn': 'مشروبات'},
  'Bakery': {'fr': 'Boulangerie', 'ar': 'مخبز', 'tn': 'خبّاز'},
  'Special Offer': {'fr': 'Offre Spéciale', 'ar': 'عرض خاص', 'tn': 'عرض خاص'},
  'Free Delivery on your 1st order!': {
    'fr': 'Livraison gratuite sur votre 1ère commande !',
    'ar': 'توصيل مجاني على طلبك الأول!',
    'tn': 'توصيل بلاش على أوّل طلبية!',
  },
  'Order Now': {'fr': 'Commander', 'ar': 'اطلب الآن', 'tn': 'اطلب توّا'},
  'Popular in Tunis': {
    'fr': 'Populaire à Tunis',
    'ar': 'الأكثر شعبية في تونس',
    'tn': 'اللي يتّطلب برشا في تونس',
  },

  // ─── Product Details ────────────────────────────────────────
  'Description': {'fr': 'Description', 'ar': 'الوصف', 'tn': 'الوصف'},
  'Frequently Bought Together': {
    'fr': 'Souvent acheté ensemble',
    'ar': 'يُشترى معاً',
    'tn': 'يتّشرا مع بعضهم',
  },
  'View all': {'fr': 'Voir tout', 'ar': 'عرض الكل', 'tn': 'شوف الكل'},

  // ─── Cart & Checkout ────────────────────────────────────────
  'Checkout': {'fr': 'Paiement', 'ar': 'الدفع', 'tn': 'الخلاص'},
  'Delivery Location': {
    'fr': 'Adresse de livraison',
    'ar': 'عنوان التوصيل',
    'tn': 'عنوان التوصيل',
  },
  'Order Summary': {
    'fr': 'Résumé de la commande',
    'ar': 'ملخص الطلب',
    'tn': 'ملخص الطلبية',
  },
  'Payment Method': {
    'fr': 'Mode de paiement',
    'ar': 'طريقة الدفع',
    'tn': 'كيفاش تخلص',
  },
  'Cash on Delivery': {
    'fr': 'Paiement à la livraison',
    'ar': 'الدفع عند الاستلام',
    'tn': 'تخلص كيف يوصلك',
  },
  'Pay when you receive': {
    'fr': 'Payez à la réception',
    'ar': 'ادفع عند الاستلام',
    'tn': 'خلّص كيف تستلم',
  },
  'Coming Soon': {'fr': 'Bientôt disponible', 'ar': 'قريباً', 'tn': 'قريب'},
  'Card Payment': {'fr': 'Carte bancaire', 'ar': 'بطاقة بنكية', 'tn': 'كارتة بنكية'},
  'Subtotal': {'fr': 'Sous-total', 'ar': 'المجموع الفرعي', 'tn': 'المجموع'},
  'Delivery Fee': {
    'fr': 'Frais de livraison',
    'ar': 'رسوم التوصيل',
    'tn': 'مصاريف التوصيل',
  },
  'Total': {'fr': 'Total', 'ar': 'المجموع الكلي', 'tn': 'المجموع الكلّي'},
  'Default': {'fr': 'Par défaut', 'ar': 'افتراضي', 'tn': 'الأساسي'},

  // ─── Order Tracking ─────────────────────────────────────────
  'On the Way': {'fr': 'En route', 'ar': 'في الطريق', 'tn': 'في الطريق'},
  'Live': {'fr': 'En direct', 'ar': 'مباشر', 'tn': 'مباشر'},
  'Placed': {'fr': 'Passée', 'ar': 'تم الطلب', 'tn': 'تطلبت'},
  'Picked': {'fr': 'Récupérée', 'ar': 'تم الاستلام', 'tn': 'تلمّت'},
  'Way': {'fr': 'Route', 'ar': 'في الطريق', 'tn': 'في الطريق'},
  'Done': {'fr': 'Livrée', 'ar': 'تم التوصيل', 'tn': 'وصلت'},
  'Help': {'fr': 'Aide', 'ar': 'مساعدة', 'tn': 'عاونّي'},
  'Add': {'fr': 'Ajouter', 'ar': 'أضف', 'tn': 'زيد'},

  // ─── Action Buttons ─────────────────────────────────────────
  'Accept': {'fr': 'Accepter', 'ar': 'قبول', 'tn': 'اقبل'},
  'Decline': {'fr': 'Refuser', 'ar': 'رفض', 'tn': 'ارفض'},
  'Confirm Order': {
    'fr': 'Confirmer la commande',
    'ar': 'تأكيد الطلب',
    'tn': 'أكّد الطلبية',
  },
  'Cancel Order': {
    'fr': 'Annuler la commande',
    'ar': 'إلغاء الطلب',
    'tn': 'الغي الطلبية',
  },
  'Add to Cart': {
    'fr': 'Ajouter au panier',
    'ar': 'أضف إلى السلة',
    'tn': 'زيدها للسلّة',
  },
  'Confirm Selection': {
    'fr': 'Confirmer la sélection',
    'ar': 'تأكيد الاختيار',
    'tn': 'أكّد الاختيار',
  },
  'Submit Documents': {
    'fr': 'Soumettre les documents',
    'ar': 'تقديم الوثائق',
    'tn': 'ابعث الوثائق',
  },
  'Complete Ride': {
    'fr': 'Terminer la course',
    'ar': 'إنهاء الرحلة',
    'tn': 'كمّل الرحلة',
  },
  'Request Payout': {
    'fr': 'Demander un paiement',
    'ar': 'طلب دفعة',
    'tn': 'اطلب الخلاص',
  },
  'Log Out': {'fr': 'Déconnexion', 'ar': 'تسجيل الخروج', 'tn': 'اخرج'},
  'SOS': {'fr': 'SOS', 'ar': 'طوارئ', 'tn': 'طوارئ'},
  'Call Admin': {
    'fr': "Appeler l'admin",
    'ar': 'اتصل بالمسؤول',
    'tn': 'عيّط للأدمين',
  },
  'Report Issue': {
    'fr': 'Signaler un problème',
    'ar': 'الإبلاغ عن مشكلة',
    'tn': 'بلّغ على مشكلة',
  },
  'Edit Order': {
    'fr': 'Modifier la commande',
    'ar': 'تعديل الطلب',
    'tn': 'بدّل الطلبية',
  },
  'Details': {'fr': 'Détails', 'ar': 'تفاصيل', 'tn': 'تفاصيل'},
  'Review': {'fr': 'Examiner', 'ar': 'مراجعة', 'tn': 'راجع'},

  // ─── Driver Screens ─────────────────────────────────────────
  'Driver Partner': {
    'fr': 'Partenaire chauffeur',
    'ar': 'شريك سائق',
    'tn': 'شريك شوفير',
  },
  'You are Online': {
    'fr': 'Vous êtes en ligne',
    'ar': 'أنت متصل',
    'tn': 'أنت كونيكتي',
  },
  'Receiving requests nearby...': {
    'fr': 'Réception des demandes à proximité...',
    'ar': 'استقبال الطلبات القريبة...',
    'tn': 'راك تستقبل في طلبات قريبة...',
  },
  "Today's Earnings": {
    'fr': "Revenus d'aujourd'hui",
    'ar': 'أرباح اليوم',
    'tn': 'مدخول اليوم',
  },
  'Jobs Completed': {
    'fr': 'Livraisons effectuées',
    'ar': 'مهام مكتملة',
    'tn': 'خدمات كمّلتهم',
  },
  'Incoming Request': {
    'fr': 'Nouvelle demande',
    'ar': 'طلب وارد',
    'tn': 'طلبية جديدة',
  },
  'New': {'fr': 'Nouveau', 'ar': 'جديد', 'tn': 'جديد'},
  'COD Amount': {
    'fr': 'Montant contre remboursement',
    'ar': 'مبلغ الدفع عند الاستلام',
    'tn': 'فلوس الخلاص',
  },
  'Pick Up': {'fr': 'Point de retrait', 'ar': 'نقطة الاستلام', 'tn': 'وين تاخذها'},
  'Drop Off': {
    'fr': 'Point de livraison',
    'ar': 'نقطة التسليم',
    'tn': 'وين توصّلها',
  },
  'My Earnings': {'fr': 'Mes revenus', 'ar': 'أرباحي', 'tn': 'المدخول متاعي'},
  'Available Balance': {
    'fr': 'Solde disponible',
    'ar': 'الرصيد المتاح',
    'tn': 'الفلوس المتوفرة',
  },
  'vs last week': {
    'fr': 'vs semaine dernière',
    'ar': 'مقارنة بالأسبوع الماضي',
    'tn': 'مقارنة بالجمعة الفاتت',
  },
  'Today': {'fr': "Aujourd'hui", 'ar': 'اليوم', 'tn': 'اليوم'},
  'This Week': {'fr': 'Cette semaine', 'ar': 'هذا الأسبوع', 'tn': 'هالجمعة'},
  'This Month': {'fr': 'Ce mois', 'ar': 'هذا الشهر', 'tn': 'هالشهر'},
  'Trips': {'fr': 'Trajets', 'ar': 'رحلات', 'tn': 'رحلات'},
  'Recent Transactions': {
    'fr': 'Transactions récentes',
    'ar': 'المعاملات الأخيرة',
    'tn': 'آخر المعاملات',
  },
  'Avg TND': {'fr': 'Moy. TND', 'ar': 'متوسط TND', 'tn': 'معدل TND'},
  'Peak Hours Bonus': {
    'fr': 'Bonus heures de pointe',
    'ar': 'مكافأة ساعات الذروة',
    'tn': 'بونيس وقت الزحمة',
  },
  'Payout to Bank': {
    'fr': 'Virement bancaire',
    'ar': 'تحويل بنكي',
    'tn': 'تحويل للبنك',
  },
  'Bonus': {'fr': 'Bonus', 'ar': 'مكافأة', 'tn': 'بونيس'},
  'Yesterday': {'fr': 'Hier', 'ar': 'أمس', 'tn': 'البارح'},
  'My Profile': {'fr': 'Mon profil', 'ar': 'ملفي الشخصي', 'tn': 'البروفيل متاعي'},
  'Verified': {'fr': 'Vérifié', 'ar': 'موثّق', 'tn': 'متأكّد'},
  'Total Trips': {
    'fr': 'Total des trajets',
    'ar': 'إجمالي الرحلات',
    'tn': 'مجموع الرحلات',
  },
  'Months Active': {'fr': 'Mois actifs', 'ar': 'الأشهر النشطة', 'tn': 'أشهر خدمة'},
  'TND Earned': {'fr': 'TND gagnés', 'ar': 'TND مكتسبة', 'tn': 'TND كسبتهم'},
  'Vehicle': {'fr': 'Véhicule', 'ar': 'المركبة', 'tn': 'الموتور'},
  'Documents & Verification': {
    'fr': 'Documents et vérification',
    'ar': 'الوثائق والتحقق',
    'tn': 'الوثائق والتحقق',
  },
  'Training Hub': {
    'fr': 'Centre de formation',
    'ar': 'مركز التدريب',
    'tn': 'مركز التدريب',
  },
  'Language': {'fr': 'Langue', 'ar': 'اللغة', 'tn': 'اللغة'},
  'Help & Support': {
    'fr': 'Aide et support',
    'ar': 'المساعدة والدعم',
    'tn': 'عاونّي',
  },
  'About Nassib': {
    'fr': 'À propos de Nassib',
    'ar': 'حول نصيب',
    'tn': 'على نصيب',
  },

  // ─── Admin Screens ──────────────────────────────────────────
  'Daily Orders': {
    'fr': 'Commandes du jour',
    'ar': 'طلبات اليوم',
    'tn': 'طلبات اليوم',
  },
  'Active Drivers': {
    'fr': 'Chauffeurs actifs',
    'ar': 'سائقين نشطين',
    'tn': 'شوفيرية خدّامين',
  },
  'Pending': {'fr': 'En attente', 'ar': 'قيد الانتظار', 'tn': 'مستنّي'},
  'Catalog Management': {
    'fr': 'Gestion du catalogue',
    'ar': 'إدارة الكتالوج',
    'tn': 'إدارة الكتالوج',
  },
  'Manage vehicle types & pricing': {
    'fr': 'Gérer les types de véhicules et prix',
    'ar': 'إدارة أنواع المركبات والأسعار',
    'tn': 'كنترول الموتورات والأسعار',
  },
  'Verification Queue': {
    'fr': "File d'attente de vérification",
    'ar': 'طابور التحقق',
    'tn': 'طابور التحقق',
  },
  'Live Map': {
    'fr': 'Carte en direct',
    'ar': 'الخريطة المباشرة',
    'tn': 'الخريطة المباشرة',
  },
  'All': {'fr': 'Tout', 'ar': 'الكل', 'tn': 'الكل'},
  'Fresh Produce': {
    'fr': 'Produits frais',
    'ar': 'منتجات طازجة',
    'tn': 'خضرة فريش',
  },
  'In Stock': {'fr': 'En stock', 'ar': 'متوفر', 'tn': 'موجود'},
  'Low Stock': {'fr': 'Stock faible', 'ar': 'مخزون منخفض', 'tn': 'قليل'},
  'Out of Stock': {
    'fr': 'Rupture de stock',
    'ar': 'نفد المخزون',
    'tn': 'ما فمّاش',
  },

  // ─── Status Messages ────────────────────────────────────────
  'Online': {'fr': 'En ligne', 'ar': 'متصل', 'tn': 'كونيكتي'},
  'Offline': {'fr': 'Hors ligne', 'ar': 'غير متصل', 'tn': 'ديكونيكتي'},
  'In Review': {'fr': 'En examen', 'ar': 'قيد المراجعة', 'tn': 'تحت المراجعة'},
  'vs yesterday': {
    'fr': 'vs hier',
    'ar': 'مقارنة بالأمس',
    'tn': 'مقارنة بالبارح',
  },

  // ─── Form Placeholders ──────────────────────────────────────
  'Search couscous, harissa...': {
    'fr': 'Rechercher couscous, harissa...',
    'ar': 'ابحث كسكسي، هريسة...',
    'tn': 'قلّب على كسكسي، هريسة...',
  },
  'Search products, SKUs...': {
    'fr': 'Rechercher produits, SKU...',
    'ar': 'ابحث عن منتجات...',
    'tn': 'قلّب على منتجات...',
  },
  'you@example.com': {
    'fr': 'vous@exemple.com',
    'ar': 'بريدك@مثال.com',
    'tn': 'الإيمايل متاعك',
  },
  'Minimum 6 characters': {
    'fr': 'Minimum 6 caractères',
    'ar': 'على الأقل 6 أحرف',
    'tn': 'على الأقل 6 حروف',
  },

  // ─── Splash Screens ─────────────────────────────────────────
  'Choose your language': {
    'fr': 'Choisissez votre langue',
    'ar': 'اختر لغتك',
    'tn': 'اختار اللغة متاعك',
  },
  'Get Started': {'fr': 'Commencer', 'ar': 'ابدأ', 'tn': 'يلّا نبداو'},
  'Next': {'fr': 'Suivant', 'ar': 'التالي', 'tn': 'أكمل'},
  'Skip': {'fr': 'Passer', 'ar': 'تخطي', 'tn': 'سكيبي'},
};
