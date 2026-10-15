import 'dart:async';
import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../services/supabase_service.dart';

enum SyncMode { ok, busy, off }

/// Global app state: products, loans, activity feed, staff, branches and Supabase real sync.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState I = AppState._();

  String role = 'branch';
  String currentUserFullName = 'Neema Julius';
  String currentBranchName = 'Mbezi Branch';
  String currentUserPhone = '+255 754 221 008';
  String? currentUserEmail = 'staff@lims.co.tz';

  void setUserProfile({
    required String fullName,
    required String userRole,
    required String branchName,
    required String phone,
    String? email,
  }) {
    currentUserFullName = fullName;
    role = userRole;
    currentBranchName = branchName;
    currentUserPhone = phone;
    currentUserEmail = email;
    notifyListeners();
  }

  bool get isAdmin => role == 'admin';
  bool get isBranchStaff => role == 'branch';
  final List<Product> products = List.from(demoProducts);
  final List<LoanAccount> loans = List.from(demoLoans);
  final List<ActivityItem> activity = List.from(demoActivity);
  final List<StaffMember> staff = List.from(demoStaff);
  final List<BranchInfo> branches = List.from(demoBranches);

  bool clockedIn = false;
  String? clockedInAt;

  SyncMode syncMode = SyncMode.ok;
  DateTime lastSync = DateTime.now();
  final List<Timer> _timers = [];
  bool _started = false;

  // ---------- sync ----------

  void startLoops() {
    if (_started) return;
    _started = true;
    // Keep the "Synced · Xs ago" label fresh.
    _timers.add(Timer.periodic(const Duration(seconds: 5), (_) {
      if (syncMode == SyncMode.ok) notifyListeners();
    }));
    // Periodic background real sync with Supabase every 60s
    _timers.add(Timer.periodic(const Duration(seconds: 60), (_) {
      if (syncMode != SyncMode.busy) {
        syncNow();
      }
    }));
  }

  String get syncLabel => switch (syncMode) {
        SyncMode.busy => 'Syncing with Supabase…',
        SyncMode.off => 'Offline · fallback active',
        SyncMode.ok => 'Synced · ${ago()}',
      };

  String ago() {
    final s = DateTime.now().difference(lastSync).inSeconds;
    if (s < 15) return 'just now';
    if (s < 60) return '${s}s ago';
    return '${s ~/ 60}m ago';
  }

  void setSync(SyncMode m) {
    syncMode = m;
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (syncMode == SyncMode.busy) return;
    setSync(SyncMode.busy);

    try {
      final supa = SupabaseService.instance;
      if (supa.isInitialized) {
        // Fetch live data concurrently from Supabase
        final results = await Future.wait([
          supa.fetchProducts().catchError((e) => <Product>[]),
          supa.fetchLoans().catchError((e) => <LoanAccount>[]),
          supa.fetchActivities().catchError((e) => <ActivityItem>[]),
          supa.fetchStaff().catchError((e) => <StaffMember>[]),
          supa.fetchBranches().catchError((e) => <BranchInfo>[]),
        ]);

        final pList = results[0] as List<Product>;
        final lList = results[1] as List<LoanAccount>;
        final aList = results[2] as List<ActivityItem>;
        final sList = results[3] as List<StaffMember>;
        final bList = results[4] as List<BranchInfo>;

        if (pList.isNotEmpty) {
          products
            ..clear()
            ..addAll(pList);
        }
        if (lList.isNotEmpty) {
          loans
            ..clear()
            ..addAll(lList);
        }
        if (aList.isNotEmpty) {
          activity
            ..clear()
            ..addAll(aList);
        }
        if (sList.isNotEmpty) {
          staff
            ..clear()
            ..addAll(sList);
        }
        if (bList.isNotEmpty) {
          branches
            ..clear()
            ..addAll(bList);
        }

        lastSync = DateTime.now();
        setSync(SyncMode.ok);
      } else {
        // Fallback simulated delay
        await Future.delayed(const Duration(milliseconds: 1000));
        lastSync = DateTime.now();
        setSync(SyncMode.ok);
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
      setSync(SyncMode.off);
    }
  }

  // ---------- data operations ----------

  Product? productById(int id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> toggleFav(int id) async {
    final p = productById(id);
    if (p == null) return;
    p.fav = !p.fav;
    notifyListeners();

    try {
      await SupabaseService.instance.toggleFavorite(id, !p.fav);
    } catch (e) {
      debugPrint('Error syncing fav to Supabase: $e');
    }
  }

  Future<void> adjustStock(int id, int delta) async {
    final p = productById(id);
    if (p == null) return;
    final newStock = (p.stock + delta).clamp(0, 99999);
    final newStatus = newStock == 0 ? 'out' : (newStock <= p.min ? 'low' : 'in');

    final updatedProduct = Product(
      id: p.id,
      name: p.name,
      variant: p.variant,
      sku: p.sku,
      price: p.price,
      stock: newStock,
      min: p.min,
      cat: p.cat,
      grad: p.grad,
      status: newStatus,
      soldToday: delta < 0 ? p.soldToday + delta.abs() : p.soldToday,
      onLoan: p.onLoan,
      fav: p.fav,
    );

    final idx = products.indexWhere((item) => item.id == id);
    if (idx != -1) {
      products[idx] = updatedProduct;
      notifyListeners();
    }

    try {
      await SupabaseService.instance.updateProductStock(id, newStock);
    } catch (e) {
      debugPrint('Error syncing stock update to Supabase: $e');
    }
  }

  Future<void> addActivity(ActivityItem a) async {
    activity.insert(0, a);
    if (activity.length > 15) activity.removeLast();
    notifyListeners();

    try {
      await SupabaseService.instance.logActivity(
        title: a.title,
        detail: a.detail,
        iconName: 'payments',
        colorKey: a.colorKey,
        timeLabel: a.time,
      );
    } catch (e) {
      debugPrint('Error syncing activity to Supabase: $e');
    }
  }

  Future<void> registerNewLoan({
    required String borrowerName,
    required String itemName,
    required String amount,
    required String dueInfo,
  }) async {
    final newLoan = LoanAccount(
      name: borrowerName,
      item: itemName,
      amount: amount,
      paid: 0,
      due: dueInfo,
      status: 'current',
      grad: [const Color(0xFF1B6EF3), const Color(0xFF0A49B8)],
    );
    loans.insert(0, newLoan);
    notifyListeners();

    try {
      await SupabaseService.instance.createLoan(
        borrowerName: borrowerName,
        itemName: itemName,
        amount: amount,
        paidPercent: 0,
        dueInfo: dueInfo,
        status: 'current',
      );
    } catch (e) {
      debugPrint('Error registering loan in Supabase: $e');
    }
  }

  Future<void> toggleClockIn() async {
    clockedIn = !clockedIn;
    clockedInAt = clockedIn ? nowLabel() : null;
    notifyListeners();

    try {
      await SupabaseService.instance.setClockInStatus(
        staffName: 'Neema',
        clockedIn: clockedIn,
        timeLabel: clockedInAt ?? '',
      );
    } catch (e) {
      debugPrint('Error toggling clock-in in Supabase: $e');
    }
  }

  int get totalStock => products.fold(0, (a, p) => a + p.stock);
  int get lowCount => products.where((p) => p.lowOrOut).length;

  String nowLabel() {
    final d = TimeOfDay.now();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }
}
