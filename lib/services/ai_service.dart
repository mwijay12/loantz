import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../data/demo_data.dart';

/// LIMS AI Assistant.
///
/// Tries the chat-completions API if configured via AppEnv.aiApiKey.
/// If omitted or on failure (offline, quota, invalid key…), it falls back
/// to the built-in rule-based assistant that answers from the live demo data.
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  static const endpoint = 'https://api.inceptionlabs.ai/v1/chat/completions';
  static const model = 'mercury-2.5';

  /// Asks the assistant a question. Never throws — always returns a reply
  /// (API answer or local fallback).
  Future<String> ask(String question) async {
    final apiKey = AppEnv.aiApiKey;
    if (apiKey.isNotEmpty) {
      try {
        final res = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': model,
                'reasoning_effort': 'low',
                'max_tokens': 400,
                'messages': [
                  {'role': 'system', 'content': _systemPrompt()},
                  {'role': 'user', 'content': question},
                ],
              }),
            )
            .timeout(const Duration(seconds: 14));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final choices = data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final msg = choices.first['message'];
            final content = msg is Map ? (msg['content'] ?? '') : '';
            final text = content.toString().trim();
            if (text.isNotEmpty) return text;
          }
        }
      } catch (_) {
        // Fall through to local fallback
      }
    }
    return fallbackReply(question);
  }

  String _systemPrompt() =>
      'You are the LIMS Assistant for a phone retail branch (Mbezi, Dar es '
      'Salaam). Live data: ${_contextSummary()} Reply briefly (max 4 short '
      'lines), friendly and concrete. Currency is TZS.';

  String _contextSummary() {
    final totalStock = demoProducts.fold<int>(0, (a, p) => a + p.stock);
    final low = demoProducts.where((p) => p.lowOrOut).length;
    return 'Branch: Mbezi (Dar es Salaam). Stock: $totalStock units across '
        '${demoProducts.length} models ($low low or out of stock). '
        "Today's sales: TZS 4.85M across 23 transactions (+12% vs yesterday; "
        'cash 3.24M, card 1.61M). Active loans: 86 worth TZS 96.2M, 3 overdue '
        '(largest: Amina Komba TZS 1.85M, 2 days), 14 repayments due this week. '
        'Expected drawer at close: TZS 1,240,000. Last transfer: 5 units to '
        'Kariakoo yesterday 4:15 PM. Pending inbound: 24 units from Dar es '
        'Salaam Hub PO #4521.';
  }

  /// Offline / API-failure replies — mirrors the web prototype's logic.
  String fallbackReply(String q) {
    final lower = q.toLowerCase();
    final totalStock = demoProducts.fold<int>(0, (a, p) => a + p.stock);
    final lowCount = demoProducts.where((p) => p.lowOrOut).length;
    final lowList = demoProducts
        .where((p) => p.lowOrOut)
        .take(3)
        .map((p) => '• <b>${p.name}</b> — ${p.stock == 0 ? 'out of stock' : '${p.stock} left (min ${p.min})'}')
        .join('<br>');
    if (lower.contains('low')) {
      return 'You have <b>$lowCount models</b> below minimum stock. Most urgent:<br>$lowList<br>Want me to raise a purchase order?';
    }
    if (lower.contains('sale') || lower.contains('revenue') || lower.contains('today')) {
      return "Today's sales stand at <b>TZS 4.85M</b> across <b>23 transactions</b> — 12% above yesterday.<br>Cash: 3.24M · Card: 1.61M.";
    }
    if (lower.contains('loan')) {
      return 'You have <b>86 active loans</b> worth <b>TZS 96.2M</b>.<br><b>3 are overdue</b> — highest: Amina Komba, TZS 1.85M (2 days). 14 repayments are due this week.';
    }
    if (lower.contains('transfer')) {
      return 'Last transfer: <b>5 units</b> sent to Kariakoo Branch yesterday at 4:15 PM. Pending inbound: <b>24 units</b> from Dar es Salaam Hub.';
    }
    if (lower.contains('close') || lower.contains('drawer')) {
      return 'Expected in drawer today: <b>TZS 1,240,000</b>. Cash sales 3.24M, card sales 1.61M, expenses 180K. Ready for daily close whenever you are.';
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('mambo') || lower.contains('habari')) {
      return 'Hello Neema! Ask me about stock, sales, loans or transfers — I have live numbers for Mbezi Branch.';
    }
    if (lower.contains('stock')) {
      return 'Total stock on hand: <b>$totalStock phones</b> across ${demoProducts.length} models. $lowCount models need attention.';
    }
    return 'Quick summary: <b>$totalStock phones</b> in stock · <b>TZS 4.85M</b> sales today · <b>86 active loans</b> · <b>$lowCount low-stock models</b>. Ask me anything specific!';
  }
}
