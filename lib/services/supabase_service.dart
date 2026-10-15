import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../data/models.dart';

/// Central Supabase client and service for LIMS.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static String get supabaseUrl => AppEnv.supabaseUrl;
  static String get supabaseAnonKey => AppEnv.supabaseAnonKey;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  SupabaseClient get client => Supabase.instance.client;

  /// Initializes Supabase Flutter SDK
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
  }

  // ===================== AUTH & PROFILES =====================

  /// Authenticates user against Supabase `profiles` table by phone or email
  Future<Map<String, dynamic>?> login({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim();
    try {
      final res = await client
          .from('profiles')
          .select()
          .or('phone.eq.$cleanId,email.eq.$cleanId')
          .maybeSingle();

      if (res != null) {
        final storedPassword = res['password_hash'] as String?;
        if (storedPassword == null || storedPassword == password.trim()) {
          return res;
        } else {
          throw Exception('Nenosiri si sahihi (Incorrect password)');
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in via Supabase: $e');
      rethrow;
    }
  }

  /// Sends a lightweight keep-alive ping to reset Supabase 7-day inactivity pause
  Future<bool> pingKeepAlive() async {
    try {
      await client.from('products').select('id').limit(1);
      debugPrint('Supabase keep-alive ping success: project is active');
      return true;
    } catch (e) {
      debugPrint('Supabase keep-alive ping failed: $e');
      return false;
    }
  }

  // ===================== PRODUCTS =====================

  Future<List<Product>> fetchProducts() async {
    try {
      final res = await client
          .from('products')
          .select()
          .order('id', ascending: true);
      return (res as List).map((row) => Product.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching products from Supabase: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int id, bool currentFav) async {
    try {
      await client
          .from('products')
          .update({'is_favorite': !currentFav})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error toggling favorite on Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(int id, int newStock) async {
    try {
      final status = newStock == 0 ? 'out' : (newStock <= 5 ? 'low' : 'in');
      await client.from('products').update({
        'stock': newStock,
        'status': status,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error updating stock on Supabase: $e');
      rethrow;
    }
  }

  // ===================== LOANS =====================

  Future<List<LoanAccount>> fetchLoans() async {
    try {
      final res =
          await client.from('loans').select().order('id', ascending: true);
      return (res as List).map((row) => LoanAccount.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching loans from Supabase: $e');
      rethrow;
    }
  }

  Future<void> createLoan({
    required String borrowerName,
    required String itemName,
    required String amount,
    int paidPercent = 0,
    required String dueInfo,
    String status = 'current',
  }) async {
    try {
      await client.from('loans').insert({
        'borrower_name': borrowerName,
        'item_name': itemName,
        'amount': amount,
        'paid_percent': paidPercent,
        'due_info': dueInfo,
        'status': status,
      });
    } catch (e) {
      debugPrint('Error creating loan on Supabase: $e');
      rethrow;
    }
  }

  // ===================== ACTIVITIES =====================

  Future<List<ActivityItem>> fetchActivities() async {
    try {
      final res = await client
          .from('activities')
          .select()
          .order('created_at', ascending: false)
          .limit(20);
      return (res as List).map((row) => ActivityItem.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching activities from Supabase: $e');
      rethrow;
    }
  }

  Future<void> logActivity({
    required String title,
    required String detail,
    String iconName = 'payments',
    String colorKey = 'green',
    String timeLabel = 'Just now',
  }) async {
    try {
      await client.from('activities').insert({
        'title': title,
        'detail': detail,
        'icon_name': iconName,
        'color_key': colorKey,
        'time_label': timeLabel,
      });
    } catch (e) {
      debugPrint('Error logging activity to Supabase: $e');
    }
  }

  // ===================== STAFF & CLOCK IN =====================

  Future<List<StaffMember>> fetchStaff() async {
    try {
      final res =
          await client.from('staff').select().order('id', ascending: true);
      return (res as List).map((row) => StaffMember.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching staff from Supabase: $e');
      rethrow;
    }
  }

  Future<void> setClockInStatus({
    required String staffName,
    required bool clockedIn,
    required String timeLabel,
  }) async {
    try {
      await client.from('staff').update({
        'clocked_in': clockedIn,
        'note': clockedIn ? 'Clocked in · $timeLabel' : 'Clocked out',
        'status': clockedIn ? 'green' : 'gray',
        'clocked_in_at': clockedIn ? DateTime.now().toIso8601String() : null,
      }).ilike('name', '%$staffName%');
    } catch (e) {
      debugPrint('Error updating staff clock-in on Supabase: $e');
    }
  }

  // ===================== BRANCHES =====================

  Future<List<BranchInfo>> fetchBranches() async {
    try {
      final res = await client
          .from('branches')
          .select()
          .order('created_at', ascending: true);
      return (res as List).map((row) => BranchInfo.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching branches from Supabase: $e');
      rethrow;
    }
  }

  // ===================== HISTORY =====================

  Future<List<HistoryEvent>> fetchProductHistory(int productId) async {
    try {
      final res = await client
          .from('product_history')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return (res as List).map((row) => HistoryEvent.fromMap(row)).toList();
    } catch (e) {
      debugPrint('Error fetching product history from Supabase: $e');
      return [];
    }
  }
}
