import 'package:flutter/material.dart';

Color hexToColor(String? hex, [Color fallback = const Color(0xFF1B6EF3)]) {
  if (hex == null || hex.isEmpty) return fallback;
  final cleanHex = hex.replaceAll('#', '').trim();
  if (cleanHex.length == 6) {
    return Color(int.parse('0xFF$cleanHex'));
  } else if (cleanHex.length == 8) {
    return Color(int.parse('0x$cleanHex'));
  }
  return fallback;
}

IconData iconFromName(String? name) {
  switch (name) {
    case 'favorite':
      return Icons.favorite_border;
    case 'download':
      return Icons.download_rounded;
    case 'swap':
      return Icons.swap_horiz_rounded;
    case 'sync':
      return Icons.sync_rounded;
    case 'check':
      return Icons.check_rounded;
    case 'warning':
      return Icons.warning_amber_rounded;
    case 'payments':
    default:
      return Icons.payments_outlined;
  }
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.variant,
    required this.sku,
    required this.price,
    required this.stock,
    required this.min,
    required this.cat,
    required this.grad,
    required this.status,
    required this.soldToday,
    required this.onLoan,
    required this.fav,
  });

  final int id;
  final String name;
  final String variant;
  final String sku;
  final String price;
  final int stock;
  final int min;
  final String cat;
  final String status;
  final int soldToday;
  final int onLoan;
  final List<Color> grad;
  bool fav;

  bool get lowOrOut => status == 'low' || status == 'out';

  factory Product.fromMap(Map<String, dynamic> map) {
    final gStart = hexToColor(map['gradient_start'] as String?, const Color(0xFF1B6EF3));
    final gEnd = hexToColor(map['gradient_end'] as String?, const Color(0xFF0A49B8));

    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      variant: map['variant'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      price: map['price'] as String? ?? '0',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      min: (map['min_stock'] as num?)?.toInt() ?? 5,
      cat: map['category'] as String? ?? 'phones',
      status: map['status'] as String? ?? 'in',
      soldToday: (map['sold_today'] as num?)?.toInt() ?? 0,
      onLoan: (map['on_loan'] as num?)?.toInt() ?? 0,
      fav: map['is_favorite'] as bool? ?? false,
      grad: [gStart, gEnd],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'variant': variant,
        'sku': sku,
        'price': price,
        'stock': stock,
        'min_stock': min,
        'category': cat,
        'status': status,
        'sold_today': soldToday,
        'on_loan': onLoan,
        'is_favorite': fav,
      };
}

class LoanAccount {
  LoanAccount({
    required this.name,
    required this.item,
    required this.amount,
    required this.paid,
    required this.due,
    required this.status,
    required this.grad,
  });

  final String name;
  final String item;
  final String amount;
  final int paid;
  final String due;
  final String status;
  final List<Color> grad;

  factory LoanAccount.fromMap(Map<String, dynamic> map) {
    return LoanAccount(
      name: map['borrower_name'] as String? ?? '',
      item: map['item_name'] as String? ?? '',
      amount: map['amount'] as String? ?? '0',
      paid: (map['paid_percent'] as num?)?.toInt() ?? 0,
      due: map['due_info'] as String? ?? '',
      status: map['status'] as String? ?? 'current',
      grad: [const Color(0xFF1B6EF3), const Color(0xFF0A49B8)],
    );
  }

  Map<String, dynamic> toMap() => {
        'borrower_name': name,
        'item_name': item,
        'amount': amount,
        'paid_percent': paid,
        'due_info': due,
        'status': status,
      };
}

class ActivityItem {
  ActivityItem({
    required this.icon,
    required this.colorKey,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final String colorKey;
  final String title;
  final String detail;
  final String time;

  factory ActivityItem.fromMap(Map<String, dynamic> map) {
    return ActivityItem(
      icon: iconFromName(map['icon_name'] as String?),
      colorKey: map['color_key'] as String? ?? 'green',
      title: map['title'] as String? ?? '',
      detail: map['detail'] as String? ?? '',
      time: map['time_label'] as String? ?? 'Just now',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'detail': detail,
        'color_key': colorKey,
        'time_label': time,
      };
}

class HistoryEvent {
  HistoryEvent({
    required this.title,
    required this.detail,
    required this.time,
    required this.type,
  });

  final String title;
  final String detail;
  final String time;
  final String type;

  factory HistoryEvent.fromMap(Map<String, dynamic> map) {
    return HistoryEvent(
      title: map['title'] as String? ?? '',
      detail: map['detail'] as String? ?? '',
      time: map['time_label'] as String? ?? '',
      type: map['event_type'] as String? ?? 'receive',
    );
  }
}

class StaffMember {
  StaffMember({
    required this.name,
    required this.role,
    required this.note,
    required this.status,
    required this.grad,
  });

  final String name;
  final String role;
  final String note;
  final String status;
  final List<Color> grad;

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      note: map['note'] as String? ?? '',
      status: map['status'] as String? ?? 'green',
      grad: [const Color(0xFF1B6EF3), const Color(0xFF0A49B8)],
    );
  }
}

class BranchInfo {
  BranchInfo({
    required this.name,
    required this.sales,
    required this.low,
    required this.status,
  });

  final String name;
  final String sales;
  final int low;
  final String status;

  factory BranchInfo.fromMap(Map<String, dynamic> map) {
    return BranchInfo(
      name: map['name'] as String? ?? '',
      sales: map['sales'] as String? ?? 'TZS 0',
      low: (map['low_stock'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'green',
    );
  }
}

class AlertItem {
  AlertItem({
    required this.colorKey,
    required this.icon,
    required this.title,
    required this.detail,
  });

  final String colorKey;
  final IconData icon;
  final String title;
  final String detail;
}

/// Formats a raw amount string (e.g. "3,850,000") as a compact TZS figure.
String fmtM(String s) {
  final n = int.tryParse(s.replaceAll(',', '')) ?? 0;
  if (n >= 1000000) {
    var v = (n / 1000000).toStringAsFixed(2);
    v = v.replaceAll(RegExp(r'\.?0+$'), '');
    return 'TZS ${v}M';
  }
  if (n >= 1000) return 'TZS ${(n / 1000).round()}K';
  return 'TZS $n';
}

/// Formats an integer with thousands separators.
String fmtInt(num n) =>
    n.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
