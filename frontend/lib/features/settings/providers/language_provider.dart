import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported app languages
enum AppLanguage {
  english('English', 'en', false),
  french('Français', 'fr', false),
  arabic('العربية', 'ar', true),
  derja('Derja', 'ar', true); // Tunisian Derja uses Arabic script/RTL

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
    if (normalized.contains('derja')) {
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

/// Translation map for UI elements across screens
/// Keys are English originals, values are maps of language code → translation
const Map<String, Map<String, String>> uiTranslations = {
  // Bottom nav labels
  'Home': {'fr': 'Accueil', 'ar': 'الرئيسية'},
  'Orders': {'fr': 'Commandes', 'ar': 'الطلبات'},
  'Profile': {'fr': 'Profil', 'ar': 'الحساب'},
  'Dashboard': {'fr': 'Tableau de bord', 'ar': 'لوحة القيادة'},
  'Wallet': {'fr': 'Portefeuille', 'ar': 'المحفظة'},
  'Earnings': {'fr': 'Revenus', 'ar': 'الأرباح'},
  'Ratings': {'fr': 'Évaluations', 'ar': 'التقييمات'},
  'Activity': {'fr': 'Activité', 'ar': 'النشاط'},
  'Account': {'fr': 'Compte', 'ar': 'الحساب'},
  'Market': {'fr': 'Marché', 'ar': 'السوق'},
  'Smart Order': {'fr': 'Commande IA', 'ar': 'طلب ذكي'},
  'Delivery': {'fr': 'Livraison', 'ar': 'التوصيل'},
  'Training': {'fr': 'Formation', 'ar': 'التدريب'},
  'Docs': {'fr': 'Documents', 'ar': 'الوثائق'},
  'Settings': {'fr': 'Paramètres', 'ar': 'الإعدادات'},
  'Catalog': {'fr': 'Catalogue', 'ar': 'الكتالوج'},
  'Drivers': {'fr': 'Chauffeurs', 'ar': 'السائقين'},

  // Action buttons
  'Accept': {'fr': 'Accepter', 'ar': 'قبول'},
  'Decline': {'fr': 'Refuser', 'ar': 'رفض'},
  'Confirm Order': {'fr': 'Confirmer la commande', 'ar': 'تأكيد الطلب'},
  'Cancel Order': {'fr': 'Annuler la commande', 'ar': 'إلغاء الطلب'},
  'Add to Cart': {'fr': 'Ajouter au panier', 'ar': 'أضف إلى السلة'},
  'Confirm Selection': {'fr': 'Confirmer la sélection', 'ar': 'تأكيد الاختيار'},
  'Submit Documents': {'fr': 'Soumettre les documents', 'ar': 'تقديم الوثائق'},
  'Complete Ride': {'fr': 'Terminer la course', 'ar': 'إنهاء الرحلة'},
  'Request Payout': {'fr': 'Demander un paiement', 'ar': 'طلب دفعة'},
  'Log Out': {'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
  'SOS': {'fr': 'SOS', 'ar': 'طوارئ'},
  'Call Admin': {'fr': 'Appeler l\'admin', 'ar': 'اتصل بالمسؤول'},
  'Report Issue': {'fr': 'Signaler un problème', 'ar': 'الإبلاغ عن مشكلة'},
  'View All': {'fr': 'Voir tout', 'ar': 'عرض الكل'},
  'Edit Order': {'fr': 'Modifier la commande', 'ar': 'تعديل الطلب'},

  // Status messages
  'Online': {'fr': 'En ligne', 'ar': 'متصل'},
  'Offline': {'fr': 'Hors ligne', 'ar': 'غير متصل'},
};
