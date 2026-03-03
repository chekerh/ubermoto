# UberMoto Stitch Screen Plan

> Comprehensive mapping of every screen, every interactive element, and its destination.

---

## Navigation Architecture

### User Flows

#### Onboarding Flow
```
Splash 1 (Language Select) → Splash 2 (Feature Preview) → Splash 3 (Feature Preview) → Splash 4 (Feature Preview) → Login
```

#### Customer Flow
```
Login → Customer Home → Product Details → Cart → Checkout (Promos) → Order Confirm → Live Tracking
                      → Filters & Recs
                      → AI Smart Ordering (Derja)
                      → AI Voice Command
                      → Notifications & Reorder
                      → Live Tracking
```

#### Driver Flow
```
Login → Driver Dashboard → Active Delivery Job → (Complete → Dashboard)
                         → Document Verification → Training Hub
                         → Motorcycle Selection → Dashboard
                         → Rating & Feedback → Dashboard
                         → Navigation & SOS → Dashboard
                         → Earnings (Splash 2 repurposed)
                         → Profile (Splash 3 repurposed)
```

#### Admin Flow
```
Login → Admin Console → Catalog Management
                      → Analytics & Fraud Control
                      → Driver Verification Queue (within Console)
```

---

## Screen-by-Screen Button Map

### 1. `/splash1` — Language Selection
| Element | Type | Action |
|---------|------|--------|
| Language radios (Derja/Arabic/French/English) | radio | Sets app locale |
| Double-tap anywhere | gesture | Navigate to `/splash2` |

### 2. `/splash2` — Feature Preview: Driver Earnings
| Element | Type | Destination |
|---------|------|-------------|
| Back button (←) | button | Go back (`/splash1`) |
| Help button (?) | button | Show help dialog |
| Request Payout | button | Show info snackbar |
| View All (transactions) | link | Show info snackbar |
| Week selector dropdown | dropdown | UI-only toggle |
| Bottom nav: Home | link | `/splash3` |
| Bottom nav: Earnings | link | Active (current) |
| Bottom nav: Scanner | link | Show info snackbar |
| Bottom nav: Activity | link | `/splash4` |
| Bottom nav: Profile | link | `/splash3` |
| Double-tap | gesture | Navigate to `/splash3` |

### 3. `/splash3` — Feature Preview: User Profile
| Element | Type | Destination |
|---------|------|-------------|
| Edit button (pencil) | button | Show info snackbar |
| Camera button | button | Show info snackbar |
| Saved Places: Home | row | Show info snackbar |
| Saved Places: Work | row | Show info snackbar |
| App Language | row | Show language picker |
| Help & Support | row | Show info snackbar |
| About | row | Show info snackbar |
| Log Out | row | `/login1` |
| Bottom nav: Home | link | `/splash2` |
| Bottom nav: Trips | link | `/splash4` |
| Bottom nav: Wallet | link | `/splash2` |
| Bottom nav: Account | link | Active (current) |
| Double-tap | gesture | Navigate to `/splash4` |

### 4. `/splash4` — Feature Preview: Order History
| Element | Type | Destination |
|---------|------|-------------|
| Back button (←) | button | `/splash3` |
| Filter button | button | Show info snackbar |
| Reorder buttons (×2) | button | Show info snackbar |
| Bottom nav: Home | link | `/splash2` |
| Bottom nav: Orders | link | Active (current) |
| Bottom nav: Motorcycle (FAB) | button | Show info snackbar |
| Bottom nav: Wallet | link | `/splash2` |
| Bottom nav: Account | link | `/splash3` |
| Double-tap | gesture | Navigate to `/login1` |

### 5. `/login1` & `/login2` — Login
| Element | Type | Destination |
|---------|------|-------------|
| Phone tab | tab | Toggle to phone input |
| Email tab | tab | Toggle to email input |
| Continue button | button | API: Login → role-based redirect |
| Register link | link | `/register1` |

### 6. `/register1` & `/register2` — Registration
| Element | Type | Destination |
|---------|------|-------------|
| Name/Phone/Email/Password/License fields | input | Form data |
| Role radios (Client/Driver/Admin) | radio | Role selection |
| Submit button (Suivant) | button | API: Register → role-based redirect |
| Login link (Se connecter) | link | `/login1` |

### 7. `/customer/home` — Customer Dashboard
| Element | Type | Destination |
|---------|------|-------------|
| Profile avatar | button | `/customer/notifications` |
| Filter button (tune) | button | `/customer/filters` |
| "Commander" button | button | `/customer/product` |
| Favorite buttons (×3) | button | `/customer/product` |
| Category links (×6) | link | `/customer/filters` |
| Search input | input | `/customer/filters` |
| Bottom nav: Home | link | Active (current) |
| Bottom nav: Smart Order | link | `/customer/ai-order` |
| Bottom nav: FAB (motorcycle) | button | `/customer/ai-voice` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 8. `/customer/product` — Product Details (Harissa)
| Element | Type | Destination |
|---------|------|-------------|
| Back button (←) | button | Go back |
| Cart button (shopping_bag) | button | `/customer/cart` |
| Zoom button | button | UI-only |
| Quantity ± buttons | button | UI-only |
| Add to Cart button | button | `/customer/cart` |
| Quick-add buttons (×3) | button | Show added snackbar |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Market | link | `/customer/filters` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 9. `/customer/cart` — Cart & Checkout
| Element | Type | Destination |
|---------|------|-------------|
| Confirm Order button | button | `/customer/checkout-promos` |
| Payment radios (COD only) | radio | UI-only |
| Delivery address card | card | Show info snackbar |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Market | link | `/customer/filters` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 10. `/customer/checkout-promos` — Enhanced Checkout
| Element | Type | Destination |
|---------|------|-------------|
| Address radios (×3) | radio | UI-only |
| Promo code field + Apply | input+button | Show applied snackbar |
| Cash/Card payment | radio | UI-only (Card disabled) |
| Confirm Order button | button | `/customer/order-confirm` |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Smart Order | link | `/customer/ai-order` |
| Bottom nav: FAB | button | `/customer/ai-voice` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 11. `/customer/order-confirm` — Order Confirmation
| Element | Type | Destination |
|---------|------|-------------|
| Cancel Order button | button | `/customer/home` |
| Track button (if present) | button | `/customer/live-tracking` |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Market | link | `/customer/filters` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 12. `/customer/live-tracking` — Live Order Tracking
| Element | Type | Destination |
|---------|------|-------------|
| Help button | button | Show help dialog |
| Zoom in/out | button | UI-only |
| Center map | button | UI-only |
| Chat driver | button | Show coming-soon snackbar |
| Call driver | button | Show coming-soon snackbar |
| Add suggestion | button | `/customer/ai-order` |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Smart Order | link | `/customer/ai-order` |
| Bottom nav: FAB | button | `/customer/ai-voice` |
| Bottom nav: Orders | link | Active (current) |
| Bottom nav: Profile | link | `/customer/notifications` |

### 13. `/customer/filters` — Advanced Filters & Recommendations
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| Search input | input | UI-only filter |
| Filter tune icon | button | UI-only |
| Cart icon (shopping_bag) | button | `/customer/cart` |
| Filter chips (Filters/Price/4.5+/Discount/New) | button | UI-only toggle |
| Clear All | button | UI-only |
| Remove filter × buttons | button | UI-only |
| Favorite ❤️ buttons (×3) | button | Show added snackbar |
| Add to cart ➕ buttons (×3) | button | Show added snackbar |
| View All → | button | Show info snackbar |
| Add to cart 🛒 buttons (×2) | button | Show added snackbar |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Market | link | Active (current) |
| Bottom nav: FAB | button | `/customer/ai-voice` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 14. `/customer/ai-order` — AI Smart Ordering (Derja)
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| More options (⋮) | button | Show menu snackbar |
| Correction link ("Oulives") | button | UI-only |
| Edit Order button | button | UI-only |
| Add to Cart ✓ button | button | `/customer/cart` |
| Attachment ➕ button | button | Show coming-soon |
| Emoji 😊 button | button | UI-only |
| Voice mic 🎤 button | button | Show listening snackbar |
| Text input | input | Send message |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Smart Order | link | Active (current) |
| Bottom nav: FAB | button | `/customer/ai-voice` |
| Bottom nav: Activity | link | `/customer/live-tracking` |
| Bottom nav: Profile | link | `/customer/notifications` |

### 15. `/customer/ai-voice` — AI Voice Command
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| More options (⋮) | button | Show menu snackbar |
| Main mic 🎤 button | button | Show listening snackbar |
| "Add Bread" chip | button | Show added snackbar |
| "Confirm Order" chip | button | `/customer/order-confirm` |
| "Cancel" chip | button | Go back |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Orders | link | `/customer/live-tracking` |
| Bottom nav: FAB mic | button | Active (current) |
| Bottom nav: Wallet | link | Show coming-soon |
| Bottom nav: Account | link | `/customer/notifications` |

### 16. `/customer/notifications` — Notifications & Reorder Settings
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| Reorder ➕ buttons (×3) | button | `/customer/cart` |
| View All link | link | Show info snackbar |
| Notification toggles (Order/Smart/Promos) | toggle | UI-only |
| Bottom nav: Home | link | `/customer/home` |
| Bottom nav: Activity | link | `/customer/live-tracking` |
| Bottom nav: FAB | button | `/customer/ai-voice` |
| Bottom nav: Wallet | link | Show coming-soon |
| Bottom nav: Account | link | Active (current) |

### 17. `/driver/dashboard` — Driver Dashboard
| Element | Type | Destination |
|---------|------|-------------|
| Notifications bell 🔔 | button | Show info snackbar |
| Online/Offline toggle | toggle | API: Toggle availability |
| Decline delivery | button | Show declined snackbar |
| Accept delivery | button | API: Accept → `/driver/active-job` |
| Bottom nav: Dashboard | link | Active (current) |
| Bottom nav: Wallet | link | `/driver/earnings` |
| Bottom nav: Docs | link | `/driver/docs` |
| Bottom nav: Profile | link | `/driver/profile` |

### 18. `/driver/docs` — Document Verification
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/driver/dashboard` |
| Edit (National ID) | button | Show info snackbar |
| View (Driving License) | button | Show info snackbar |
| Upload (Motorcycle Reg) | button | Show coming-soon |
| Upload (Insurance) | button | Show coming-soon |
| Submit Documents (disabled) | button | API: Submit → snackbar |

### 19. `/driver/active-job` — Active Delivery Job
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/driver/dashboard` |
| Help button | button | Show help dialog |
| Recenter map 📍 | button | UI-only |
| Navigate 🧭 | button | Show directions snackbar |
| Chat customer 💬 | button | Show coming-soon |
| Call customer 📞 | button | Show coming-soon |
| Slide to Complete | slider | API: Complete → `/driver/dashboard` |
| Bottom nav: Delivery | link | Active (current) |
| Bottom nav: Earnings | link | `/driver/earnings` |
| Bottom nav: Ratings | link | `/driver/rating` |
| Bottom nav: Profile | link | `/driver/profile` |

### 20. `/driver/sos` — Navigation & Emergency SOS
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| SOS button | button | Show SOS activated snackbar |
| Zoom in/out | button | UI-only |
| Recenter 📍 | button | UI-only |
| Call Admin | button | Show calling snackbar |
| Report Issue | button | Show report form snackbar |
| Complete Ride | button | API: Complete → `/driver/dashboard` |
| Bottom nav: Home | link | `/driver/dashboard` |
| Bottom nav: Earnings | link | `/driver/earnings` |
| Bottom nav: Ratings | link | `/driver/rating` |
| Bottom nav: Profile | link | `/driver/profile` |

### 21. `/driver/rating` — Rating & Quality Feedback
| Element | Type | Destination |
|---------|------|-------------|
| Menu hamburger ☰ | button | Show menu snackbar |
| Notifications bell 🔔 | button | Show info snackbar |
| Star rating (1-5) | button | UI-only |
| Feedback tags (Ponctuel/Poli/etc) | button | UI-only toggle |
| Textarea (comment) | textarea | UI-only |
| "Envoyer l'avis" (Submit) | button | Show submitted → `/driver/dashboard` |
| "Passer" (Skip) | button | `/driver/dashboard` |
| Bottom nav: Accueil | link | `/driver/dashboard` |
| Bottom nav: Activité | link | `/driver/active-job` |
| Bottom nav: Paiement | link | `/driver/earnings` |
| Bottom nav: Compte | link | `/driver/profile` |

### 22. `/driver/training` — Training Hub
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/driver/dashboard` |
| Info button | button | Show info snackbar |
| "Commencer le Quiz" | button | Show quiz snackbar |
| "Voir tout" link | link | Show info snackbar |
| "Guide PDF" resource | link | Show coming-soon |
| "Support Chauffeur" resource | link | Show coming-soon |
| Video module cards (×3) | card | Show video snackbar |
| Bottom nav: Accueil | link | `/driver/dashboard` |
| Bottom nav: Revenus | link | `/driver/earnings` |
| Bottom nav: Formation | link | Active (current) |
| Bottom nav: Profil | link | `/driver/profile` |

### 23. `/driver/motorcycle-select` — Motorcycle Selection
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/driver/dashboard` |
| Swipeable motorcycle cards (×4) | slider | UI-only select |
| Confirm Selection → | button | `/driver/dashboard` |

### 24. `/driver/earnings` — Driver Earnings (splash2 repurposed)
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/driver/dashboard` |
| Help button | button | Show help dialog |
| Request Payout | button | Show payout snackbar |
| View All (transactions) | link | Show info snackbar |
| Bottom nav: Home | link | `/driver/dashboard` |
| Bottom nav: Earnings | link | Active (current) |
| Bottom nav: Scanner | link | Show coming-soon |
| Bottom nav: Activity | link | `/driver/active-job` |
| Bottom nav: Profile | link | `/driver/profile` |

### 25. `/driver/profile` — Driver Profile (splash3 repurposed)
| Element | Type | Destination |
|---------|------|-------------|
| Edit button | button | Show info snackbar |
| Camera button | button | Show coming-soon |
| Saved Places | rows | Show info snackbar |
| App Language | row | Show language picker |
| Help & Support | row | Show info snackbar |
| About | row | Show info snackbar |
| Log Out | row | Logout → `/login1` |
| Bottom nav: Home | link | `/driver/dashboard` |
| Bottom nav: Trips | link | `/driver/active-job` |
| Bottom nav: Wallet | link | `/driver/earnings` |
| Bottom nav: Account | link | Active (current) |

### 26. `/biometric-otp` — Biometric / OTP Authentication
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | Go back |
| Phone/email input | input | Phone/email entry |
| OTP inputs (×6) | input | OTP digits |
| "Continuer →" button | button | Verify OTP → role redirect |
| "Connexion Biométrique" button | button | Show biometric snackbar |
| "Renvoyer le code SMS" button | button | Show resent snackbar |

### 27. `/admin/console` — Admin Management Console
| Element | Type | Destination |
|---------|------|-------------|
| Menu hamburger ☰ | button | Show menu snackbar |
| Notifications bell 🔔 | button | Show info snackbar |
| Catalog Management shortcut → | button | `/admin/catalog` |
| View All (Verification Queue) | button | Show info snackbar |
| Details buttons (×3 drivers) | button | Show driver details snackbar |
| Review buttons (×2 drivers) | button | API: Verify → snackbar |
| Continue button (Khaled) | button | Show info snackbar |

### 28. `/admin/catalog` — Admin Catalog Management
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/admin/console` |
| More options (⋮) | button | Show menu snackbar |
| Search input | input | UI-only filter |
| Category filter chips (All/Grocery/Spices/etc) | button | UI-only toggle |
| Edit buttons (×5 products) | button | Show edit snackbar |
| FAB ➕ (add product) | button | Show add form snackbar |
| Bottom nav: Dashboard | link | `/admin/console` |
| Bottom nav: Catalog | link | Active (current) |
| Bottom nav: Orders | link | Show info snackbar |
| Bottom nav: Settings | link | Show info snackbar |

### 29. `/admin/analytics` — Admin Analytics & Fraud Control
| Element | Type | Destination |
|---------|------|-------------|
| Back button | button | `/admin/console` |
| Notifications bell 🔔 | button | Show info snackbar |
| View Report (Sales Trends) | button | Show info snackbar |
| Alert chevrons (Harissa/Fresh Milk) | button | Show alert details |
| View All (Recent Drivers) | link | Show info snackbar |
| Bottom nav: Dashboard | link | `/admin/console` |
| Bottom nav: Drivers | link | Show info snackbar |
| Bottom nav: Orders | link | Show info snackbar |
| Bottom nav: Settings | link | Show info snackbar |

---

## Missing Routes to Add

| Route | Asset | Purpose |
|-------|-------|---------|
| `/driver/earnings` | `ubermoto_splash_and_language_select_2/code.html` | Driver earnings dashboard |
| `/driver/profile` | `ubermoto_splash_and_language_select_3/code.html` | Driver profile & settings |

---

## Translation Strategy

1. **Splash 1**: User selects language → stored in Riverpod `languageProvider`
2. **Every subsequent screen**: On page load, inject CSS/JS to translate key labels via `_injectTranslations()`
3. **Translation map** covers: button labels, nav labels, status messages, form placeholders
4. **Supported languages**: English (default), French, Arabic, Tunisian Derja
5. **RTL support**: Arabic/Derja get `dir="rtl"` injected

---

## Dead-End Prevention Rules

1. Every back button navigates to logical parent or uses browser-like back
2. Every bottom nav item has a bound destination
3. Screens without bottom nav have explicit back buttons
4. All "coming soon" features show informative snackbar
5. No button is ever unresponsive — minimum: snackbar acknowledgment
6. Driver dashboard dynamically links to motorcycle-select, training, SOS based on content
7. Admin console links to both catalog AND analytics via chevrons and stats cards
8. Active delivery job has SOS button for emergencies
9. Driver docs has Continue/Next button leading to training
10. Completed delivery routes to rating screen for feedback

## Files Modified

| File | Changes |
|------|---------|
| `frontend/lib/stitch/stitch_viewer.dart` | Full rewrite: 30 screen bindings, 49 bridge actions, language injection, RTL support |
| `frontend/lib/features/settings/providers/language_provider.dart` | NEW: Language state management + translation map |
| `frontend/lib/main.dart` | Added `/driver/earnings` + `/driver/profile` routes, removed dead `nextRoute` entries |
| `STITCH_SCREEN_PLAN.md` | THIS FILE: Complete screen-by-screen button map |
