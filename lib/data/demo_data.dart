import 'package:flutter/material.dart';
import 'models.dart';

final List<Product> demoProducts = [
  Product(id: 1, name: 'iPhone 15 Pro Max', variant: '256GB · Natural Titanium', sku: 'IP15PM-256-NT', price: '3,850,000', stock: 24, min: 8, cat: 'phones', grad: [Color(0xFF1B6EF3), Color(0xFF0A49B8)], status: 'in', soldToday: 5, onLoan: 6, fav: true),
  Product(id: 2, name: 'Galaxy S24 Ultra', variant: '256GB · Titanium Gray', sku: 'SGS24U-256-TG', price: '3,420,000', stock: 18, min: 6, cat: 'phones', grad: [Color(0xFF6366F1), Color(0xFF4338CA)], status: 'in', soldToday: 3, onLoan: 4, fav: false),
  Product(id: 3, name: 'Redmi Note 13 Pro', variant: '256GB · Midnight Black', sku: 'RN13P-256-MB', price: '985,000', stock: 42, min: 10, cat: 'phones', grad: [Color(0xFF0EA5E9), Color(0xFF0369A1)], status: 'in', soldToday: 8, onLoan: 2, fav: false),
  Product(id: 4, name: 'Tecno Camon 30 Premier', variant: '256GB · Serenity Blue', sku: 'TC30P-256-SB', price: '735,000', stock: 35, min: 10, cat: 'phones', grad: [Color(0xFF06B6D4), Color(0xFF0E7490)], status: 'in', soldToday: 6, onLoan: 3, fav: false),
  Product(id: 5, name: 'AirPods Pro (2nd Gen)', variant: 'USB-C · White', sku: 'APP2-USB-W', price: '430,000', stock: 5, min: 10, cat: 'acc', grad: [Color(0xFFF472B6), Color(0xFFDB2777)], status: 'low', soldToday: 4, onLoan: 0, fav: true),
  Product(id: 6, name: 'Galaxy A55', variant: '128GB · Awesome Navy', sku: 'SGA55-128-NV', price: '1,260,000', stock: 4, min: 8, cat: 'phones', grad: [Color(0xFF8B5CF6), Color(0xFF6D28D9)], status: 'low', soldToday: 2, onLoan: 1, fav: false),
  Product(id: 7, name: 'iPhone 15', variant: '128GB · Starlight', sku: 'IP15-128-ST', price: '2,950,000', stock: 16, min: 6, cat: 'phones', grad: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], status: 'in', soldToday: 4, onLoan: 2, fav: false),
  Product(id: 8, name: 'Infinix Zero 40', variant: '256GB · Stardust Silver', sku: 'IZ40-256-SS', price: '655,000', stock: 27, min: 10, cat: 'phones', grad: [Color(0xFF14B8A6), Color(0xFF0F766E)], status: 'in', soldToday: 7, onLoan: 1, fav: false),
  Product(id: 9, name: 'itel Vision 3 Plus', variant: '64GB · Blue', sku: 'IV3P-64-BL', price: '285,000', stock: 0, min: 8, cat: 'phones', grad: [Color(0xFF94A3B8), Color(0xFF64748B)], status: 'out', soldToday: 0, onLoan: 0, fav: false),
  Product(id: 10, name: 'Power Bank 20,000mAh', variant: '22.5W · Black', sku: 'PB20K-22W-BK', price: '89,000', stock: 53, min: 15, cat: 'acc', grad: [Color(0xFFF59E0B), Color(0xFFD97706)], status: 'in', soldToday: 9, onLoan: 0, fav: false),
  Product(id: 11, name: 'Smart Watch X2', variant: 'AMOLED · 46mm', sku: 'SWX2-AM-46', price: '210,000', stock: 12, min: 6, cat: 'acc', grad: [Color(0xFFEC4899), Color(0xFFBE185D)], status: 'in', soldToday: 3, onLoan: 0, fav: false),
  Product(id: 12, name: 'HP Laptop 15s', variant: 'Ryzen 5 · 8GB / 512GB', sku: 'HPL15S-R5-8512', price: '2,150,000', stock: 6, min: 4, cat: 'laptops', grad: [Color(0xFF64748B), Color(0xFF334155)], status: 'in', soldToday: 1, onLoan: 1, fav: false),
];

final List<LoanAccount> demoLoans = [
  LoanAccount(name: 'John Mwalimu', item: 'iPhone 15 Pro Max', amount: '2,400,000', paid: 60, due: 'Due in 4 days', status: 'current', grad: [Color(0xFF1B6EF3), Color(0xFF0A49B8)]),
  LoanAccount(name: 'Amina Komba', item: 'Galaxy S24 Ultra', amount: '1,850,000', paid: 35, due: 'Overdue 2 days', status: 'overdue', grad: [Color(0xFFF472B6), Color(0xFFDB2777)]),
  LoanAccount(name: 'Peter Msechu', item: 'Redmi Note 12', amount: '620,000', paid: 80, due: 'Due in 12 days', status: 'current', grad: [Color(0xFF0EA5E9), Color(0xFF0369A1)]),
  LoanAccount(name: 'Neema Lyimo', item: 'iPhone 15', amount: '2,900,000', paid: 45, due: 'Due in 6 days', status: 'current', grad: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
  LoanAccount(name: 'Baraka Mushi', item: 'Tecno Camon 30', amount: '540,000', paid: 20, due: 'Overdue 5 days', status: 'overdue', grad: [Color(0xFFF59E0B), Color(0xFFD97706)]),
];

final List<ActivityItem> demoActivity = [
  ActivityItem(icon: Icons.payments_outlined, colorKey: 'green', title: 'Sale completed — iPhone 15 Pro Max', detail: 'TZS 3,850,000 · Cash', time: '10:42 AM'),
  ActivityItem(icon: Icons.favorite_border, colorKey: 'pink', title: 'Loan disbursed — John Mwalimu', detail: 'TZS 2,400,000 · 6 months', time: '9:15 AM'),
  ActivityItem(icon: Icons.download_rounded, colorKey: 'blue', title: 'Stock received — 20 units', detail: 'From Dar es Salaam Hub', time: '8:30 AM'),
  ActivityItem(icon: Icons.swap_horiz_rounded, colorKey: 'violet', title: 'Transfer sent — 5 units', detail: 'To Kariakoo Branch', time: 'Yesterday'),
];

final Map<int, List<HistoryEvent>> demoHistory = {
  1: [
    HistoryEvent(title: 'Received 20 units', detail: 'From Dar es Salaam Hub · PO #4521', time: 'Today · 8:30 AM', type: 'receive'),
    HistoryEvent(title: 'Sold 3 units', detail: 'Cash sale · Receipt #1042', time: 'Today · 10:42 AM', type: 'sale'),
    HistoryEvent(title: 'Transferred 5 units', detail: 'To Kariakoo Branch', time: 'Yesterday · 4:15 PM', type: 'transfer'),
    HistoryEvent(title: 'Stock counted', detail: 'Physical count matched system', time: 'Yesterday · 6:00 PM', type: 'count'),
  ],
  5: [
    HistoryEvent(title: 'Low stock alert', detail: 'Dropped below minimum level (10)', time: 'Today · 9:05 AM', type: 'alert'),
    HistoryEvent(title: 'Sold 4 units', detail: 'Card sale · Receipt #1038', time: 'Today · 9:40 AM', type: 'sale'),
    HistoryEvent(title: 'Received 12 units', detail: 'From Dar es Salaam Hub · PO #4498', time: '2 days ago', type: 'receive'),
  ],
};

final List<StaffMember> demoStaff = [
  StaffMember(name: 'Neema Julius', role: 'Store Manager', note: 'Clocked in · 08:02', status: 'green', grad: [Color(0xFF1B6EF3), Color(0xFF0A49B8)]),
  StaffMember(name: 'Baraka Mushi', role: 'Sales Associate', note: 'Clocked in · 08:11', status: 'green', grad: [Color(0xFF0EA5E9), Color(0xFF0369A1)]),
  StaffMember(name: 'Amina Komba', role: 'Sales Associate', note: 'Late · 09:15', status: 'amber', grad: [Color(0xFFF472B6), Color(0xFFDB2777)]),
  StaffMember(name: 'Peter Msechu', role: 'Warehouse', note: 'On break', status: 'blue', grad: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
  StaffMember(name: 'Zawadi Nnaji', role: 'Cashier', note: 'Absent today', status: 'gray', grad: [Color(0xFF94A3B8), Color(0xFF64748B)]),
];

final List<BranchInfo> demoBranches = [
  BranchInfo(name: 'Mbezi Branch', sales: 'TZS 4.85M', low: 12, status: 'green'),
  BranchInfo(name: 'Kariakoo Branch', sales: 'TZS 3.92M', low: 5, status: 'green'),
  BranchInfo(name: 'Mwanza Branch', sales: 'TZS 2.71M', low: 8, status: 'amber'),
  BranchInfo(name: 'Arusha Branch', sales: 'TZS 2.34M', low: 3, status: 'green'),
  BranchInfo(name: 'Dodoma Branch', sales: 'TZS 1.88M', low: 0, status: 'green'),
  BranchInfo(name: 'Zanzibar Branch', sales: 'TZS 1.42M', low: 6, status: 'pink'),
];

final List<AlertItem> demoAlerts = [
  AlertItem(colorKey: 'pink', icon: Icons.favorite_border, title: 'Overdue loan — Amina Komba', detail: 'TZS 1.85M · 2 days overdue'),
  AlertItem(colorKey: 'amber', icon: Icons.warning_amber_rounded, title: 'Galaxy A55 below minimum', detail: '4 left at Mbezi Branch'),
  AlertItem(colorKey: 'blue', icon: Icons.sync_rounded, title: 'Zanzibar Branch sync delayed', detail: 'Last sync 12 minutes ago'),
  AlertItem(colorKey: 'green', icon: Icons.check_rounded, title: 'Daily close completed', detail: 'Arusha Branch · TZS 2.1M'),
];

/// Per-product inventory history; falls back to generated entries.
List<HistoryEvent> historyFor(Product p) {
  final h = demoHistory[p.id];
  if (h != null) return h;
  return [
    HistoryEvent(title: 'Received ${p.stock - 6 < 4 ? 4 : p.stock - 6} units', detail: 'From Dar es Salaam Hub · PO #4490', time: '2 days ago', type: 'receive'),
    HistoryEvent(title: 'Sold ${1 + (p.id % 4)} units', detail: 'Card sale · Receipt #10${30 + p.id}', time: 'Yesterday', type: 'sale'),
    HistoryEvent(title: 'Stock counted', detail: 'Physical count matched system', time: '3 days ago', type: 'count'),
  ];
}
